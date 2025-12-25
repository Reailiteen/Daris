import 'package:get/get.dart';
import '../controller/authorization_controller.dart';

class AuthorizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthorizationController>(() => AuthorizationController());
  }
}
