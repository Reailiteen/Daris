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

  // MARK: - Subjects

  Future<List<Map<String, dynamic>>> getSubjects(String userId) async {
    final response = await _supabase
        .from('subjects')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> insertSubject({
    required String userId,
    required String name,
    DateTime? examDate,
    String? materialNotes,
  }) async {
    final payload = {
      'user_id': userId,
      'name': name,
      if (examDate != null) 'exam_date': examDate.toIso8601String().split('T')[0],
      if (materialNotes != null) 'material_notes': materialNotes,
    };
    final response = await _supabase
        .from('subjects')
        .insert(payload)
        .select()
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> deleteSubject(String subjectId) async {
    await _supabase.from('subjects').delete().eq('id', subjectId);
  }

  // MARK: - Study Tasks

  Future<List<Map<String, dynamic>>> getTasks(String userId) async {
    final response = await _supabase
        .from('study_tasks')
        .select()
        .eq('user_id', userId)
        .eq('is_completed', false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> insertTask({
    required String userId,
    required String title,
    required String difficulty,
    required int rewardMinutes,
    String? subjectId,
  }) async {
    final payload = {
      'user_id': userId,
      'title': title,
      'difficulty': difficulty,
      'reward_minutes': rewardMinutes,
      if (subjectId != null) 'subject_id': subjectId,
    };
    final response = await _supabase
        .from('study_tasks')
        .insert(payload)
        .select()
        .single();
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> completeTask(String taskId) async {
    await _supabase.from('study_tasks').update({
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase.from('study_tasks').delete().eq('id', taskId);
  }

  // MARK: - Screen Time Earnings

  Future<void> addEarning({
    required String userId,
    required String source,
    required int minutes,
    required DateTime weekStart,
  }) async {
    await _supabase.from('screen_time_earnings').insert({
      'user_id': userId,
      'source': source,
      'minutes_earned': minutes,
      'week_start': weekStart.toIso8601String().split('T')[0],
    });
  }

  Future<int> getWeeklyEarnings(String userId, DateTime weekStart) async {
    final weekStartStr = weekStart.toIso8601String().split('T')[0];
    final response = await _supabase
        .from('screen_time_earnings')
        .select('minutes_earned')
        .eq('user_id', userId)
        .eq('week_start', weekStartStr);
    final rows = response as List;
    return rows.fold<int>(
      0,
      (sum, row) => sum + (row['minutes_earned'] as int),
    );
  }
}
