import 'package:get/get.dart';
import '../../../data/services/focus_flow_service.dart';
import '../../../data/models/blocked_website.dart';

class WebsiteBlockingController extends GetxController {
  final FocusFlowService _service = Get.find<FocusFlowService>();

  final RxList<BlockedWebsite> blockedWebsites = <BlockedWebsite>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWebsites();
  }

  Future<void> loadWebsites() async {
    isLoading.value = true;
    blockedWebsites.value = await _service.loadBlockedWebsites();
    isLoading.value = false;
  }

  Future<void> addWebsite(BlockedWebsite website) async {
    blockedWebsites.add(website);
    await _service.saveBlockedWebsites(blockedWebsites);
  }

  Future<void> removeWebsite(String id) async {
    blockedWebsites.removeWhere((w) => w.id == id);
    await _service.saveBlockedWebsites(blockedWebsites);
  }

  Future<void> toggleWebsite(String id) async {
    final index = blockedWebsites.indexWhere((w) => w.id == id);
    if (index != -1) {
      final w = blockedWebsites[index];
      blockedWebsites[index] = BlockedWebsite(
        id: w.id,
        domain: w.domain,
        displayName: w.displayName,
        iconName: w.iconName,
        isEnabled: !w.isEnabled,
        category: w.category,
      );
      await _service.saveBlockedWebsites(blockedWebsites);
    }
  }
}
