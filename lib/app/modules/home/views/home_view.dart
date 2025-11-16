// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/home/controllers/home_controller.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';
import 'package:masjid_ku/app/routes/app_routes.dart';
import 'package:masjid_ku/core/constants/app_strings.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Get.isRegistered<ThemeProvider>()
            ? Obx(() {
                // Pastikan kita selalu mengakses observable variable di dalam Obx
                final themeProvider = Get.find<ThemeProvider>();
                final themeStatus = themeProvider.isDarkMode.value ? 'Gelap' : 'Terang';
                return Text('${AppStrings.homeTitle} ($themeStatus)');
              })
            : Text(AppStrings.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => controller.goToSettings(), // Navigasi ke Settings
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat datang di MasjidKu!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.goToSettings(),
              child: const Text('Buka Pengaturan Tema'),
            ),
            const SizedBox(height: 10), // Spasi antar tombol
            ElevatedButton( // <-- Tambahkan tombol ini
              onPressed: () => Get.toNamed(Routes.PENGAJIAN_SCHEDULES),
              child: const Text('Lihat Jadwal Pengajian'),
            ),
          ],
        ),
      ),
    );
  }
}