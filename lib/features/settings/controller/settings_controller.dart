import 'package:get/get.dart';

class SettingsController extends GetxController {
  // final FocusFlowService _service = Get.find<FocusFlowService>();

  final RxBool notificationsEnabled = true.obs;

  Future<void> revokeAuthorization() async {
    // Platform channel call for revoking
    // Note: iOS FamilyControls doesn't have a direct 'revoke' via API that's standard,
    // usually users do it in Settings, but the ViewModel had a revoke method.
  }
}
