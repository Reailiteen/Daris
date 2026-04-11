import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../controller/walkthrough_controller.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../../website_blocking/controller/website_blocking_controller.dart';
import '../../settings/controller/settings_controller.dart';
import '../../subjects/controller/subjects_controller.dart';
import '../../balance/controller/balance_controller.dart';
import '../../tasks/controller/tasks_controller.dart';
import '../../ai_questions/controller/ai_questions_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<AppSelectionController>(AppSelectionController());
    Get.put<StatisticsController>(StatisticsController());
    Get.put<WebsiteBlockingController>(WebsiteBlockingController());
    Get.put<SettingsController>(SettingsController());
    Get.put<SubjectsController>(SubjectsController());
    Get.put<BalanceController>(BalanceController());
    Get.put<TasksController>(TasksController());
    Get.put<AIQuestionsController>(AIQuestionsController());
    // Registered last so it can find the controllers above
    Get.put<WalkthroughController>(WalkthroughController());
  }
}
