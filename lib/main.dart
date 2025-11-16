// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart'; // <-- Pastikan import SupabaseService di sini
import 'package:masjid_ku/app/routes/app_pages.dart';
import 'package:masjid_ku/core/themes/app_theme.dart';
import 'package:masjid_ku/global_bindings.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  print("Main: Starting global service initialization...");
  final globalBindings = GlobalBindings();
  globalBindings.dependencies(); 

  try {
    await globalBindings.initializeServices();
    print("Main: All global services (including SupabaseService) initialized successfully.");
    
    // VERIFIKASI EKSTRA: Coba Get.find() SupabaseService secara eksplisit di sini
    if (Get.isRegistered<SupabaseService>()) {
      print("Main: SupabaseService is confirmed to be registered with GetX.");
      // Jika berhasil, Anda bisa melakukan pengecekan dasar
      final SupabaseService supabaseService = Get.find();
      print("Main: Supabase client instance obtained: ${supabaseService.supabaseClient != null ? 'OK' : 'NULL'}");
    } else {
      print("Main: ERROR: SupabaseService is NOT registered with GetX after initialization!");
      // Jika ini terjadi, ada masalah fundamental. Kita bisa menghentikan aplikasi.
      return; 
    }
    
  } catch (e, stackTrace) {
    print('Main: FATAL ERROR during global service initialization: $e');
    print('Main: Stack Trace: $stackTrace');
    // Tampilkan pesan error ke pengguna dan hentikan aplikasi
    runApp(ErrorApp(errorMessage: 'Aplikasi gagal memulai: $e')); // Tampilkan error screen
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Get.find<ThemeProvider>();
    
    return Obx(() {
      final ThemeMode currentThemeMode = themeProvider.isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
      
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

// Tambahkan widget ini untuk menampilkan error jika inisialisasi gagal
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Error Aplikasi')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Terjadi kesalahan fatal saat memulai aplikasi:\n\n$errorMessage\n\nSilakan coba lagi nanti atau hubungi dukungan.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}