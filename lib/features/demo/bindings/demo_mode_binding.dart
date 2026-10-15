import 'package:get/get.dart';
import '../controller/demo_mode_controller.dart';

class DemoModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DemoModeController());
  }
}
