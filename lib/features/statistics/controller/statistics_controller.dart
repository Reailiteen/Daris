import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/models/core_models.dart';

class StatisticsController extends GetxController {
  final SupabaseService _supabase = Get.find<SupabaseService>();

  final RxList<ActivitySession> allSessions = <ActivitySession>[].obs;
  final Rxn<ScreenBudget> currentBudget = Rxn<ScreenBudget>();
  final RxInt dayStreak = 0.obs;
  final RxString totalFocusTime = '0m'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    isLoading.value = true;
    try {
      // 1. Fetch Cycle & Budget
      final cycleData = await _supabase.getActiveFocusCycle(userId);
      if (cycleData != null) {
        final cycleId = cycleData['id'];
        final budgetData = await _supabase.getScreenBudget(cycleId);
        if (budgetData != null) {
          currentBudget.value = ScreenBudget.fromJson(budgetData);
        }
      }

      // 2. Fetch Sessions for calculation (simplified for now)
      // In a real app, you'd fetch sessions from the DB
      // allSessions.value = ...
      
      _calculateMetrics();
    } catch (e) {
      print("Error loading stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMetrics() {
    // Placeholder for actual calculation logic
    totalFocusTime.value = allSessions.isEmpty ? '0m' : '${allSessions.length * 30}m';
    dayStreak.value = allSessions.length > 5 ? 7 : 0; 
  }
}
