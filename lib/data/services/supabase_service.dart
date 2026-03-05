import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  final _supabase = Supabase.instance.client;

  // MARK: - Auth

  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> resendVerificationEmail(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  Future<void> refreshSession() async {
    await _supabase.auth.refreshSession();
  }

  // MARK: - Profile

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<void> completeOnboarding(String userId) async {
    await _supabase.from('profiles').update({
      'onboarding_complete': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // MARK: - User Settings

  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    final response = await _supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> saveUserSettings({
    required String userId,
    required int weeklyScreenTimeMinutes,
    required List<String> blockingCategories,
  }) async {
    final payload = {
      'weekly_screen_time_minutes': weeklyScreenTimeMinutes,
      'blocking_categories': blockingCategories,
      'updated_at': DateTime.now().toIso8601String(),
    };
    final existing = await getUserSettings(userId);
    if (existing != null) {
      await _supabase.from('user_settings').update(payload).eq('user_id', userId);
    } else {
      await _supabase.from('user_settings').insert({
        'user_id': userId,
        ...payload,
      });
    }
  }

  // MARK: - Focus Cycles
  
  Future<Map<String, dynamic>?> getActiveFocusCycle(String userId) async {
    final response = await _supabase
        .from('focus_cycles')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .maybeSingle();
    return response;
  }

  // MARK: - Screen Budget
  
  Future<Map<String, dynamic>?> getScreenBudget(String cycleId) async {
    final response = await _supabase
        .from('screen_budgets')
        .select()
        .eq('cycle_id', cycleId)
        .single();
    return response;
  }
}
