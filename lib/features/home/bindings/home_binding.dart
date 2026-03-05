import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../../website_blocking/controller/website_blocking_controller.dart';
import '../../settings/controller/settings_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<AppSelectionController>(AppSelectionController());
    Get.put<StatisticsController>(StatisticsController());
    Get.put<WebsiteBlockingController>(WebsiteBlockingController());
    Get.put<SettingsController>(SettingsController());
  }
}
