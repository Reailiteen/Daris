import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  final _supabase = Supabase.instance.client;

  // MARK: - Auth

  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // DEMO ONLY: the UI intentionally collects no password. Supabase's
  // password provider still requires one internally, so both operations use
  // this public, non-secret credential. Do not ship this authentication mode
  // to real users: anyone who knows an email can access that account.
  static const _demoAuthPassword = 'focus-flow-demo-only-2026';

  Future<AuthResponse> signUp({required String email}) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: _demoAuthPassword,
    );
  }

  Future<AuthResponse> signIn({required String email}) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: _demoAuthPassword,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
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

  Future<void> updateProfileDisplayName(String userId, String name) async {
    await _supabase
        .from('profiles')
        .update({
          'display_name': name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> completeOnboarding(String userId) async {
    await _supabase
        .from('profiles')
        .update({
          'onboarding_complete': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> markWalkthroughComplete(String userId) async {
    await _supabase
        .from('profiles')
        .update({
          'walkthrough_complete': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
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
      await _supabase
          .from('user_settings')
          .update(payload)
          .eq('user_id', userId);
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
    String? syllabusBook,
    String? syllabusFilePath,
    String? materialNotes,
    DateTime? examDate,
    int numQuizzes = 0,
    int numAssignments = 0,
    int numMidterms = 0,
    int numFinals = 0,
    int numProjects = 0,
  }) async {
    final payload = {
      'user_id': userId,
      'name': name,
      if (syllabusBook != null && syllabusBook.isNotEmpty)
        'syllabus_book': syllabusBook,
      if (syllabusFilePath != null) 'syllabus_file_path': syllabusFilePath,
      if (materialNotes != null) 'material_notes': materialNotes,
      if (examDate != null)
        'exam_date': examDate.toIso8601String().split('T')[0],
      'num_quizzes': numQuizzes,
      'num_assignments': numAssignments,
      'num_midterms': numMidterms,
      'num_finals': numFinals,
      'num_projects': numProjects,
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

  Future<void> updateSubject({
    required String subjectId,
    required String name,
    String? syllabusBook,
    String? materialNotes,
  }) async {
    await _supabase
        .from('subjects')
        .update({
          'name': name,
          'syllabus_book': syllabusBook,
          'material_notes': materialNotes,
        })
        .eq('id', subjectId);
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
    await _supabase
        .from('study_tasks')
        .update({
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', taskId);
  }

  Future<Map<String, dynamic>?> completeTaskAndRecordEarning({
    required String taskId,
    required DateTime weekStart,
  }) async {
    final response = await _supabase.rpc(
      'complete_study_task_and_earn',
      params: {'p_task_id': taskId, 'p_week_start': _dateOnly(weekStart)},
    );
    return response == null ? null : Map<String, dynamic>.from(response as Map);
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

  Future<void> recordSpend({
    required String userId,
    required int minutes,
    required DateTime weekStart,
  }) async {
    await _supabase.from('screen_time_spends').insert({
      'user_id': userId,
      'minutes_spent': minutes,
      'week_start': _dateOnly(weekStart),
    });
  }

  Future<int> getWeeklyWalletBalance({
    required String userId,
    required DateTime weekStart,
  }) async {
    final start = _dateOnly(weekStart);
    final earnings = await _supabase
        .from('screen_time_earnings')
        .select('minutes_earned')
        .eq('user_id', userId)
        .eq('week_start', start);
    final spends = await _supabase
        .from('screen_time_spends')
        .select('minutes_spent')
        .eq('user_id', userId)
        .eq('week_start', start);
    final earned = (earnings as List).fold<int>(
      0,
      (total, row) => total + ((row['minutes_earned'] as num?)?.toInt() ?? 0),
    );
    final spent = (spends as List).fold<int>(
      0,
      (total, row) => total + ((row['minutes_spent'] as num?)?.toInt() ?? 0),
    );
    return (earned - spent).clamp(0, 1 << 31);
  }

  String _dateOnly(DateTime value) => DateTime(
    value.year,
    value.month,
    value.day,
  ).toIso8601String().split('T').first;

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
