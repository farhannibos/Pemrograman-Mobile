// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/home/controllers/home_controller.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';
import 'package:masjid_ku/app/routes/app_routes.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart';
import 'package:masjid_ku/core/constants/app_strings.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Get.isRegistered<ThemeProvider>()
            ? Obx(() {
                // Pastikan kita selalu mengakses observable variable di dalam Obx
                final themeProvider = Get.find<ThemeProvider>();
                final themeStatus = themeProvider.isDarkMode.value
                    ? 'Gelap'
                    : 'Terang';
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.PENGAJIAN_SCHEDULES),
              child: const Text('Lihat Jadwal Pengajian (Lokal)'),
            ),
            const SizedBox(height: 10), // Spasi antar tombol
            ElevatedButton(
              // Cloud button: check Supabase readiness before navigating
              onPressed: () {
                if (!Get.isRegistered<SupabaseService>()) {
                  Get.snackbar('Cloud belum siap', 'Koneksi cloud belum tersedia. Silakan tunggu atau cek konfigurasi .env',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                final supabase = Get.find<SupabaseService>();
                // If supabase exists but not initialized, warn user
                if (!supabase.isInitialized) {
                  Get.snackbar('Cloud belum siap', 'Inisialisasi cloud masih berlangsung. Coba lagi sebentar.',
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                Get.toNamed(Routes.KHUTBAH_JUMAT_SCHEDULES);
              },
              child: const Text('Lihat Jadwal Khutbah Jumat (Cloud)'),
            ),
          ],
        ),
      ),
    );
  }
}
