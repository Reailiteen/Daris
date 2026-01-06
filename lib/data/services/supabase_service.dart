import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  final _supabase = Supabase.instance.client;

  // MARK: - Auth
  
  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // MARK: - Profile
  
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  // MARK: - Sports
  
  Future<List<Map<String, dynamic>>> getSports() async {
    final response = await _supabase
        .from('sports')
        .select()
        .eq('is_enabled', true);
    return List<Map<String, dynamic>>.from(response);
  }

  // MARK: - Activities
  
  Future<void> logActivity(Map<String, dynamic> sessionData, List<Map<String, dynamic>> metrics) async {
    final sessionResponse = await _supabase
        .from('activity_sessions')
        .insert(sessionData)
        .select()
        .single();
    
    final sessionId = sessionResponse['id'];
    
    if (metrics.isNotEmpty) {
      final metricsWithSession = metrics.map((m) => {...m, 'session_id': sessionId}).toList();
      await _supabase.from('activity_metrics').insert(metricsWithSession);
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
