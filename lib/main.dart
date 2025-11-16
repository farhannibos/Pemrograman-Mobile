// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- Tambahkan import ini
import 'package:masjid_ku/app/routes/app_pages.dart';
import 'package:masjid_ku/core/themes/app_theme.dart';
import 'package:masjid_ku/global_bindings.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter bindings sudah diinisialisasi

  // --- Tambahkan inisialisasi locale data untuk intl ---
  // Ini harus dipanggil sebelum DateFormat digunakan di mana pun.
  await initializeDateFormatting('id_ID', null);
  // --- Akhir inisialisasi locale data ---

  try {
    // Inisialisasi global bindings
    final globalBindings = GlobalBindings();
    globalBindings.dependencies(); // Ini mendaftarkan layanan asinkron ke GetX
    
    // Tunggu semua layanan asinkron selesai diinisialisasi
    await globalBindings.initializeServices(); // Panggil metode baru ini
  } catch (e, stackTrace) {
    print('Error during global service initialization: $e');
    print('Stack trace: $stackTrace');
    // Jangan return, tetap jalankan aplikasi dengan fallback
    // Aplikasi akan menggunakan default theme jika ThemeProvider gagal
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan ThemeProvider sudah terdaftar sebelum menggunakan Obx
    if (!Get.isRegistered<ThemeProvider>()) {
      // Jika belum terdaftar, gunakan default theme
      return GetMaterialApp(
        title: "MasjidKu",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
      );
    }
    
    // Jika sudah terdaftar, gunakan Obx untuk reactive updates
    final themeProvider = Get.find<ThemeProvider>();
    
    return Obx(() {
      // Pastikan kita selalu mengakses observable variable di dalam Obx
      final ThemeMode currentThemeMode = themeProvider.isDarkMode.value 
          ? ThemeMode.dark 
          : ThemeMode.light;
      
      return GetMaterialApp(
        title: "MasjidKu",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: currentThemeMode,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}