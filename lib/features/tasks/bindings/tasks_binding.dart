import 'package:get/get.dart';
import '../controller/tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TasksController>(TasksController());
  }
}
