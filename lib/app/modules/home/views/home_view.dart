import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '/app/services/theme_service.dart'; // Import ThemeService

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Dapatkan instance ThemeService
    final ThemeService themeService = Get.find<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Masjid'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              // Tampilkan ikon berdasarkan tema saat ini
              themeService.themeMode == ThemeMode.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Panggil switchTheme untuk mengganti tema
              themeService.switchTheme();
              // Opsional: Perbarui UI secara manual jika tidak menggunakan Obx untuk tema
              // Get.forceAppUpdate(); // Bisa menyebabkan reload seluruh aplikasi
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat Datang di Aplikasi Masjid!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Contoh navigasi ke halaman lain
                // Get.toNamed(Routes.PRAYER_TIMES);
              },
              child: Text('Lihat Jadwal Sholat'),
            ),
            // Anda bisa menambahkan widget lain di sini
          ],
        ),
      ),
    );
  }
}