import 'dart:convert';

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
  final RxString firstName = ''.obs;
  final RxInt weeklyScreenTimeMinutes = 120.obs;
  final RxList<String> blockingCategories = <String>[].obs;
  // Each map: {name, syllabusBook, numQuizzes, numAssignments, numMidterms, numFinals, numProjects}
  final RxList<Map<String, dynamic>> onboardingSubjects = <Map<String, dynamic>>[].obs;

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

  /// Returns a user-friendly message from an AuthException (handles JSON message / known codes).
  static String _authExceptionMessage(AuthException e) {
    String msg = e.message;
    if (e.code == 'unexpected_failure' ||
        msg.toLowerCase().contains('confirmation email')) {
      return 'We couldn\'t send the confirmation email. Your account may still have been created—check your inbox or try signing in.';
    }
    // Supabase sometimes returns JSON in message
    if (msg.trim().startsWith('{')) {
      try {
        final map = jsonDecode(msg) as Map<String, dynamic>;
        final code = map['code'] as String?;
        final message = map['message'] as String? ?? msg;
        if (code == 'unexpected_failure' && message.toLowerCase().contains('email')) {
          return 'We couldn\'t send the confirmation email. Check your inbox or try signing in—your account may already exist.';
        }
        return message;
      } catch (_) {
        /* fall through to raw message */
      }
    }
    return msg;
  }

  Future<void> register(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _supabaseService.signUp(email: email, password: password);
      Get.offAllNamed('/email-verification', arguments: {'email': email});
    } on AuthException catch (e) {
      errorMessage.value = _authExceptionMessage(e);
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
      errorMessage.value = _authExceptionMessage(e);
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
        final cats = settings['blocking_categories'];
        if (cats is List) {
          blockingCategories.assignAll(cats.cast<String>());
        }
      }
    } catch (_) {
      // Use defaults if loading fails
    }
  }

  void advanceStep() {
    errorMessage.value = null;
    onboardingStep.value++;
  }

  void addOnboardingSubject(Map<String, dynamic> subject) {
    onboardingSubjects.add(subject);
  }

  void removeOnboardingSubject(int index) {
    onboardingSubjects.removeAt(index);
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
        blockingCategories: blockingCategories.toList(),
      );

      if (firstName.value.trim().isNotEmpty) {
        await _supabaseService.updateProfileDisplayName(
            user.id, firstName.value.trim());
      }

      for (final s in onboardingSubjects) {
        try {
          await _supabaseService.insertSubject(
            userId: user.id,
            name: s['name'] as String,
            syllabusBook: s['syllabusBook'] as String?,
            numQuizzes: (s['numQuizzes'] as int?) ?? 0,
            numAssignments: (s['numAssignments'] as int?) ?? 0,
            numMidterms: (s['numMidterms'] as int?) ?? 0,
            numFinals: (s['numFinals'] as int?) ?? 0,
            numProjects: (s['numProjects'] as int?) ?? 0,
          );
        } catch (_) {}
      }

      await _supabaseService.completeOnboarding(user.id);
      Get.offAllNamed('/onboarding');
    } catch (_) {
      errorMessage.value = 'Failed to save settings. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Keep for backward compatibility (no-op — saving now happens only in finishOnboarding)
  Future<void> saveStepAndAdvance() async => advanceStep();

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
