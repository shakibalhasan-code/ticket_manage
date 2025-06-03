import 'package:get/get.dart';
import 'package:workflowx/controllers/home_controller.dart';
import 'package:workflowx/controllers/report_details_controller.dart';
import '../../../core/themes/theme_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    ); // Use fenix: true to recreate the controller if needed
    Get.lazyPut<MainHomeController>(
      () => MainHomeController(),
      fenix: true,
    ); // Use fenix: true to recreate the controller if needed
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
  }
}
