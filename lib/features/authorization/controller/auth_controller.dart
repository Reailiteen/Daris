import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/focus_flow_service.dart';
import '../../../data/services/supabase_service.dart';

class AuthController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final FocusFlowService _focusFlowService = Get.find<FocusFlowService>();

  /// Email of the currently signed-in user (or empty string).
  String get currentUserEmail => _supabaseService.currentUser?.email ?? '';

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  // Onboarding wizard state
  final RxInt onboardingStep = 0.obs;
  final RxInt weeklyScreenTimeMinutes = 120.obs;
  final RxString activityFocus = 'mixed'.obs;
  final RxList<String> blockingCategories = <String>[].obs;

  // Validation helpers
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must contain an uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // MARK: - Registration

  Future<void> register(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _supabaseService.signUp(email: email, password: password);
      Get.offAllNamed('/email-verification', arguments: {'email': email});
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - Sign In

  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _supabaseService.signIn(email: email, password: password);
      await _navigateAfterAuth();
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Sign in failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - Email Verification

  Future<void> resendVerificationEmail(String email) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _supabaseService.resendVerificationEmail(email);
    } catch (_) {
      errorMessage.value = 'Failed to resend email. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkEmailVerified() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _supabaseService.refreshSession();
      final user = _supabaseService.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        await _navigateAfterAuth();
      } else {
        errorMessage.value =
            'Email not yet verified. Please click the link in your inbox.';
      }
    } catch (_) {
      errorMessage.value =
          'Could not verify status. Please open the link in your email first.';
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - Onboarding Wizard

  Future<void> loadUserSettings() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    try {
      final settings = await _supabaseService.getUserSettings(user.id);
      if (settings != null) {
        weeklyScreenTimeMinutes.value =
            settings['weekly_screen_time_minutes'] as int? ?? 120;
        activityFocus.value =
            settings['activity_focus'] as String? ?? 'mixed';
        final cats = settings['blocking_categories'];
        if (cats is List) {
          blockingCategories.assignAll(cats.cast<String>());
        }
      }
    } catch (_) {
      // Use defaults if loading fails
    }
  }

  Future<void> saveStepAndAdvance() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('Not authenticated');
      await _supabaseService.saveUserSettings(
        userId: user.id,
        weeklyScreenTimeMinutes: weeklyScreenTimeMinutes.value,
        activityFocus: activityFocus.value,
        blockingCategories: blockingCategories.toList(),
      );
      onboardingStep.value++;
    } catch (_) {
      errorMessage.value = 'Failed to save. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> finishOnboarding() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('Not authenticated');
      await _supabaseService.saveUserSettings(
        userId: user.id,
        weeklyScreenTimeMinutes: weeklyScreenTimeMinutes.value,
        activityFocus: activityFocus.value,
        blockingCategories: blockingCategories.toList(),
      );
      await _supabaseService.completeOnboarding(user.id);
      Get.offAllNamed('/onboarding');
    } catch (_) {
      errorMessage.value = 'Failed to save settings. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBlockingCategory(String category) {
    if (blockingCategories.contains(category)) {
      blockingCategories.remove(category);
    } else {
      blockingCategories.add(category);
    }
  }

  // MARK: - Private Navigation

  Future<void> _navigateAfterAuth() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    // A1: unverified email — redirect with email pre-filled for resend
    if (user.emailConfirmedAt == null) {
      Get.offAllNamed('/email-verification',
          arguments: {'email': user.email ?? ''});
      return;
    }

    try {
      final profile = await _supabaseService.getProfile(user.id);
      if (profile == null || profile['onboarding_complete'] != true) {
        Get.offAllNamed('/onboarding-wizard');
        return;
      }
    } catch (_) {
      Get.offAllNamed('/onboarding-wizard');
      return;
    }

    // Onboarding complete — check FamilyControls to skip the auth screen if
    // the user has already granted it (common for returning users).
    try {
      final isAuthorized =
          await _focusFlowService.checkAuthorizationStatus();
      if (isAuthorized) {
        Get.offAllNamed('/home');
        return;
      }
    } catch (_) {
      // Platform channel unavailable (e.g. on non-iOS dev builds) — fall through.
    }

    Get.offAllNamed('/onboarding');
  }
}
