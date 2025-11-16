// lib/app/modules/settings/bindings/settings_binding.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Instansiasi SettingsController agar tersedia di SettingsView
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}