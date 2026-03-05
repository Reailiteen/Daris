import 'package:get/get.dart';
import '../controller/ai_questions_controller.dart';

class AIQuestionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AIQuestionsController>(AIQuestionsController());
  }
}
