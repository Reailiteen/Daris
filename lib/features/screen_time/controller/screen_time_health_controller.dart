import 'package:get/get.dart';

import '../../../data/services/focus_flow_service.dart';

class ScreenTimeHealthController extends GetxController {
  final FocusFlowService _service = Get.find<FocusFlowService>();

  final RxBool isLoading = false.obs;
  final RxBool isAuthorized = false.obs;
  final RxInt selectedApps = 0.obs;
  final RxBool unlockActive = false.obs;
  final RxInt remainingMinutes = 0.obs;

  bool get isHealthy => isAuthorized.value && selectedApps.value > 0;
  String get healthLabel {
    if (!isAuthorized.value) return 'Setup needed';
    if (selectedApps.value == 0) return 'Choose apps';
    if (unlockActive.value) return 'Unlock active';
    return 'Protection healthy';
  }

  @override
  void onInit() {
    super.onInit();
    refreshHealth();
  }

  Future<void> refreshHealth() async {
    isLoading.value = true;
    try {
      isAuthorized.value = await _service.checkAuthorizationStatus();
      selectedApps.value = await _service.getSelectedAppsCount();
      final status = await _service.getScreenTimeStatus();
      unlockActive.value = status['isActive'] == true;
      remainingMinutes.value =
          (status['remainingMinutes'] as num?)?.toInt() ?? 0;
    } finally {
      isLoading.value = false;
    }
  }
}
