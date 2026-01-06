import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../../website_blocking/controller/website_blocking_controller.dart';
import '../../activities/controller/activity_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AppSelectionController>(() => AppSelectionController());
    Get.lazyPut<StatisticsController>(() => StatisticsController());
    Get.lazyPut<WebsiteBlockingController>(() => WebsiteBlockingController());
    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
