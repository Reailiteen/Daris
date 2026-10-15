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
  final RxList<Map<String, dynamic>> onboardingSubjects =
      <Map<String, dynamic>>[].obs;

  // Validation helpers
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email address';
    return null;
  }

  // MARK: - Registration

  /// Returns a user-friendly message from an AuthException (handles JSON message / known codes).
  static String _authExceptionMessage(AuthException e) {
    final msg = e.message;
    // Supabase sometimes returns JSON in message
    if (msg.trim().startsWith('{')) {
      try {
        final map = jsonDecode(msg) as Map<String, dynamic>;
        final message = map['message'] as String? ?? msg;
        return message;
      } catch (_) {
        /* fall through to raw message */
      }
    }
    return msg;
  }

  Future<void> register(String email) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _supabaseService.signUp(email: email);
      if (response.session == null) {
        errorMessage.value =
            'Demo email-only auth requires email confirmation to be disabled in Supabase.';
        return;
      }
      await _navigateAfterAuth();
    } on AuthException catch (e) {
      errorMessage.value = _authExceptionMessage(e);
    } catch (_) {
      errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - Sign In

  Future<void> signIn(String email) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _supabaseService.signIn(email: email);
      if (response.session == null) {
        errorMessage.value =
            'Sign in did not create a session. Please try again.';
        return;
      }
      await _navigateAfterAuth();
    } on AuthException catch (e) {
      errorMessage.value = _authExceptionMessage(e);
    } catch (_) {
      errorMessage.value = 'Sign in failed. Please try again.';
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
          user.id,
          firstName.value.trim(),
        );
      }

      await _supabaseService.completeOnboarding(user.id);
      Get.offAllNamed('/home', arguments: {'showTutorial': true});
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
      final isAuthorized = await _focusFlowService.checkAuthorizationStatus();
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
