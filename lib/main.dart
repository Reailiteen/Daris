import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'data/services/focus_flow_service.dart';
import 'features/authorization/view/onboarding_view.dart';
import 'features/authorization/bindings/authorization_binding.dart';
import 'features/home/view/home_view.dart';
import 'features/home/bindings/home_binding.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env from Flutter assets (works on all platforms: Android, iOS, Windows, web).
  try {
    await dotenv.load(fileName: '.env', mergeWith: {});
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // Initialize Services
  await Get.putAsync(() async => SupabaseService());
  await Get.putAsync(() async => FocusFlowService());
  
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/onboarding',
      getPages: [
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
