import 'package:get/get.dart';
import '../../../data/services/focus_flow_service.dart';
import '../../../data/models/session_statistic.dart';
import 'dart:convert';

class StatisticsController extends GetxController {
  final FocusFlowService _service = Get.find<FocusFlowService>();

  final RxList<SessionStatistic> allSessions = <SessionStatistic>[].obs;
  final RxInt dayStreak = 0.obs;
  final RxDouble avgDuration = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      final String? jsonStr = await _service.getStatistics();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        allSessions.value = list.map((e) => SessionStatistic.fromJson(e)).toList();
        _calculateMetics();
      }
    } catch (e) {
      print("Error loading stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMetics() {
    // Placeholder for metric calculation
    dayStreak.value = 0; // Logic from StatisticsViewModel.swift could be ported here
    if (allSessions.isNotEmpty) {
      final totalSec = allSessions.fold(0, (sum, s) => sum + s.duration.inSeconds);
      avgDuration.value = totalSec / allSessions.length;
    }
  }
}
