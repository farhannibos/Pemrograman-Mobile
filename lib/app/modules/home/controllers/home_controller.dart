// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/routes/app_routes.dart';

class HomeController extends GetxController {
  // Metode untuk navigasi ke halaman pengaturan
  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }
}