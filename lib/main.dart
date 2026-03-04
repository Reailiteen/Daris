import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'data/services/focus_flow_service.dart';
import 'data/services/supabase_service.dart';
import 'features/authorization/bindings/auth_binding.dart';
import 'features/authorization/bindings/authorization_binding.dart';
import 'features/authorization/view/email_verification_view.dart';
import 'features/authorization/view/landing_view.dart';
import 'features/authorization/view/login_view.dart';
import 'features/authorization/view/onboarding_view.dart';
import 'features/authorization/view/onboarding_wizard_view.dart';
import 'features/authorization/view/register_view.dart';
import 'features/home/bindings/home_binding.dart';
import 'features/home/view/home_view.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env', mergeWith: {});
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await Get.putAsync(() async => SupabaseService());
  await Get.putAsync(() async => FocusFlowService());

  final initialRoute = await _resolveInitialRoute();

  runApp(FocusFlowApp(initialRoute: initialRoute));
}

/// Determines the correct entry point based on the current auth + onboarding state.
Future<String> _resolveInitialRoute() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return '/landing';

  // A1: email not yet verified
  if (user.emailConfirmedAt == null) return '/email-verification';

  // Check onboarding completion
  bool onboardingDone = false;
  try {
    final profile = await supabase
        .from('profiles')
        .select('onboarding_complete')
        .eq('id', user.id)
        .single();
    onboardingDone = profile['onboarding_complete'] == true;
  } catch (_) {
    // Fall through to wizard if profile fetch fails
  }

  if (!onboardingDone) return '/onboarding-wizard';

  // Onboarding complete — check FamilyControls so returning users skip
  // the authorization screen entirely.
  try {
    final focusFlowService = Get.find<FocusFlowService>();
    final isAuthorized = await focusFlowService.checkAuthorizationStatus();
    if (isAuthorized) return '/home';
  } catch (_) {
    // Platform channel unavailable on non-iOS builds — fall through.
  }

  return '/onboarding';
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: '/landing',
          page: () => const LandingView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/email-verification',
          page: () => const EmailVerificationView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/onboarding-wizard',
          page: () => const OnboardingWizardView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingView(),
          binding: AuthorizationBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
      ],
    );
  }
}
