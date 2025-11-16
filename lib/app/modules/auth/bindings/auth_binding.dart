// lib/app/modules/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/auth/controllers/auth_controller.dart';
import 'package:masjid_ku/app/modules/auth/providers/auth_provider.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Registrasi AuthProvider sebagai layanan
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(),
    );
    // Instansiasi AuthController
    Get.lazyPut<AuthController>(
      () => AuthController(),
    );
  }
}