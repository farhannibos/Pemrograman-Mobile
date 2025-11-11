// lib/app/modules/home/bindings/home_binding.dart
import 'package:get/get.dart';

import '../controllers/home_controller.dart'; // Import HomeController

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}