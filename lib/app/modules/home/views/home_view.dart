// lib/app/modules/home/views/home_view.dart (Hanya bagian AppBar yang diubah)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/home/controllers/home_controller.dart';
import 'package:masjid_ku/core/constants/app_strings.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';
import 'package:masjid_ku/app/modules/auth/controllers/auth_controller.dart'; // <-- Import AuthController
import 'package:masjid_ku/app/routes/app_routes.dart'; // Import Routes

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Get.find<ThemeProvider>(); 
    final AuthController authController = Get.find<AuthController>(); // <-- Dapatkan AuthController

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          '${AppStrings.homeTitle} (${themeProvider.isDarkMode.value ? 'Gelap' : 'Terang'})',
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => controller.goToSettings(),
          ),
          Obx(() { // <-- Obx untuk bereaksi terhadap status login
            if (authController.user.value != null) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => authController.logout(), // <-- Tombol Logout
              );
            }
            return const SizedBox.shrink(); // Sembunyikan tombol logout jika belum login
          }),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text( // Tampilkan info user jika login
              authController.user.value != null ? 'Anda login sebagai: ${authController.user.value?.email}' : 'Anda belum login.',
              style: TextStyle(fontSize: 18, color: Get.theme.textTheme.bodyMedium?.color),
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.goToSettings(),
              child: const Text('Buka Pengaturan Tema'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.PENGAJIAN_SCHEDULES),
              child: const Text('Lihat Jadwal Pengajian (Lokal)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.KHUTBAH_JUMAT_SCHEDULES),
              child: const Text('Lihat Jadwal Khutbah Jumat (Cloud)'),
            ),
          ],
        ),
      ),
    );
  }
}