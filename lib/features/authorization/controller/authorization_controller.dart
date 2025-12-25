import 'package:get/get.dart';
import '../../../data/services/focus_flow_service.dart';

class AuthorizationController extends GetxController {
  final FocusFlowService _service = Get.find<FocusFlowService>();

  final RxBool isAuthorized = false.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  bool _isRequesting = false; // Prevent concurrent requests

  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  Future<void> checkStatus() async {
    try {
      isAuthorized.value = await _service.checkAuthorizationStatus();
      if (isAuthorized.value) {
        // If authorized, go to home
        Get.offAllNamed('/home');
      }
    } catch (e) {
      // Silently handle check status errors
      print("Error checking authorization status: $e");
    }
  }

  Future<void> requestAuth() async {
    // Prevent concurrent authorization requests
    if (_isRequesting || isLoading.value) {
      return;
    }
    
    _isRequesting = true;
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      await _service.requestAuthorization();
      // Status will be checked again after return
      await checkStatus();
    } catch (e) {
      // Only show user-friendly error messages
      final errorStr = e.toString();
      if (errorStr.contains('helper application')) {
        errorMessage.value = 'DeviceActivityMonitorExtension is not configured. Please set up the extension in Xcode.';
      } else {
        errorMessage.value = 'Failed to request authorization. Please try again.';
      }
    } finally {
      isLoading.value = false;
      _isRequesting = false;
    }
  }
}
