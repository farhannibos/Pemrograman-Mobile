import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import ini
import '/app/routes/app_pages.dart'; // Sesuaikan dengan path routes Anda
import '/app/services/theme_service.dart'; // Import ThemeService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi ThemeService sebelum aplikasi berjalan
  await Get.putAsync(() => ThemeService().init());
  
  // Opsional: Atur orientasi potrait saja
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    GetMaterialApp(
      title: "Aplikasi Masjid",
      initialRoute: AppPages.INITIAL, // Sesuaikan dengan initial route Anda
      getPages: AppPages.routes,
      // Terapkan tema dari ThemeService
      theme: ThemeData.light(), // Tema terang default
      darkTheme: ThemeData.dark(), // Tema gelap default
      themeMode: Get.find<ThemeService>().themeMode, // Menggunakan themeMode dari service
    ),
  );
}