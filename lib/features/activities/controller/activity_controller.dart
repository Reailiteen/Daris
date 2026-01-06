import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/models/core_models.dart';

class ActivityController extends GetxController {
  final SupabaseService _supabase = Get.find<SupabaseService>();

  final RxList<Sport> sports = <Sport>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSports();
  }

  Future<void> loadSports() async {
    isLoading.value = true;
    try {
      final data = await _supabase.getSports();
      sports.value = data.map((json) => Sport.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load activities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startAndLogActivity(Sport sport, Duration duration) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    final sessionData = {
      'user_id': userId,
      'sport_id': sport.id,
      'start_time': DateTime.now().toIso8601String(),
      'end_time': DateTime.now().add(duration).toIso8601String(),
      'source': 'manual',
    };

    try {
      await _supabase.logActivity(sessionData, []);
      Get.snackbar('Success', '${sport.name} activity logged!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log activity: $e');
    }
  }
}
