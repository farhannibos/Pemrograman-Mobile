import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart'; // Jika ada
import '/app/services/theme_service.dart';
import '/app/routes/app_routes.dart'; // Import AppRoutes

class HomeView extends GetView<HomeController> { // Atau StatelessWidget jika tanpa HomeController
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Masjid'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeService.themeMode == ThemeMode.dark 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeService.switchTheme();
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
                // Navigasi ke halaman event
                Get.toNamed(Routes.EVENTS);
              },
              child: Text('Lihat Acara Masjid (Hive)'),
            ),
            // ... widget lainnya
          ],
        ),
      ),
    );
  }
}