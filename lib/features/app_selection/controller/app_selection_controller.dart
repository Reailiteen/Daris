import 'package:get/get.dart';
import '../../../data/services/focus_flow_service.dart';

class AppSelectionController extends GetxController {
  final FocusFlowService _service = Get.find<FocusFlowService>();

  final RxInt totalSelectedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCount();
  }

  Future<void> _loadCount() async {
    totalSelectedCount.value = await _service.getSelectedAppsCount();
  }

  Future<void> openPicker() async {
    await _service.presentAppPicker();
    // After picker returns, reload count
    await _loadCount();
  }
}
