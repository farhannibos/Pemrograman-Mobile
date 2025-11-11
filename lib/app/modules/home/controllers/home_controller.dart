// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Contoh reaktif counter
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}