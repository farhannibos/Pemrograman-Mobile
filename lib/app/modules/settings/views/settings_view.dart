// lib/app/modules/settings/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/settings/controllers/settings_controller.dart';
import 'package:masjid_ku/core/constants/app_strings.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bungkus seluruh Scaffold dengan Obx.
    // Ini akan memastikan bahwa seluruh halaman SettingsView akan dibangun ulang
    // ketika nilai isDarkMode dari controller berubah, sehingga tema baru diterapkan.
    return Obx(() { // <-- Tambahkan Obx di sini
      // Akses isDarkMode di sini agar Obx bisa mendengarkan perubahannya
      final bool currentIsDarkMode = controller.isDarkMode.value; 

      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.settingsTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                title: const Text(AppStrings.switchTheme),
                trailing: Switch(
                  // Sekarang Switch juga bisa menggunakan currentIsDarkMode
                  value: currentIsDarkMode, 
                  onChanged: (newValue) {
                    controller.toggleTheme();
                  },
                ),
              ),
              // Anda bisa menambahkan opsi pengaturan lain di sini
            ],
          ),
        ),
      );
    }); // <-- Tutup Obx di sini
  }
}