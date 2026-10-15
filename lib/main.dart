import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'data/services/focus_flow_service.dart';
import 'data/services/fireworks_service.dart';
import 'data/services/supabase_service.dart';
import 'features/authorization/bindings/auth_binding.dart';
import 'features/authorization/bindings/authorization_binding.dart';
import 'features/authorization/view/landing_view.dart';
import 'features/authorization/view/login_view.dart';
import 'features/authorization/view/onboarding_view.dart';
import 'features/authorization/view/onboarding_wizard_view.dart';
import 'features/authorization/view/register_view.dart';
import 'features/ai_questions/bindings/ai_questions_binding.dart';
import 'features/ai_questions/view/ai_questions_view.dart';
import 'features/tasks/bindings/tasks_binding.dart';
import 'features/tasks/view/tasks_view.dart';
import 'features/home/bindings/home_binding.dart';
import 'features/home/view/home_view.dart';
import 'features/demo/bindings/demo_mode_binding.dart';

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
    url:
        dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ??
        dotenv.env['SUPABASE_URL'] ??
        '',
    anonKey:
        dotenv.env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        '',
  );

  // Restore session so currentUser is available before resolving route
  try {
    await Supabase.instance.client.auth.refreshSession().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('Session refresh timed out'),
    );
  } catch (e) {
    debugPrint('Session refresh: $e');
  }

  await Get.putAsync(() async => SupabaseService());
  await Get.putAsync(() async => FocusFlowService());
  await Get.putAsync(() async => FireworksService());

  final initialRoute = await _resolveInitialRoute();
  _resolvedRoute = initialRoute;

  runApp(const FocusFlowApp());
}

/// Determines the correct entry point based on the current auth + onboarding state.
Future<String> _resolveInitialRoute() async {
  try {
    return await _resolveInitialRouteImpl().timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint('Initial route resolution timed out');
        return '/landing';
      },
    );
  } catch (e, st) {
    debugPrint('Initial route error: $e $st');
    return '/landing';
  }
}

Future<String> _resolveInitialRouteImpl() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return '/landing';

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

/// Resolved route from main(); bootstrap uses this to navigate so bindings run.
String _resolvedRoute = '/landing';

class _BootstrapPage extends StatelessWidget {
  const _BootstrapPage();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute == '/') {
        Get.offAllNamed(_resolvedRoute);
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Daris',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const _BootstrapPage()),
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
        GetPage(
          name: '/demo',
          page: () => const HomeView(demo: true),
          binding: DemoModeBinding(),
        ),
        GetPage(
          name: '/ai-questions',
          page: () => const AIQuestionsView(),
          binding: AIQuestionsBinding(),
        ),
        GetPage(
          name: '/tasks',
          page: () => const TasksView(),
          binding: TasksBinding(),
        ),
      ],
    );
  }
}
