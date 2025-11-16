// lib/global_bindings.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/data/services/local_storage_service.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';

class GlobalBindings extends Bindings {
  // List untuk menyimpan Future dari setiap proses inisialisasi asinkron
  final List<Future<void>> _initializationFutures = [];

  @override
  void dependencies() {
    // Daftarkan semua layanan asinkron dan tambahkan Future-nya ke list
    // Urutan penting: LocalStorageService harus diinisialisasi terlebih dahulu
    // karena mungkin diperlukan oleh service lain
    _initializationFutures.add(Get.putAsync(() => LocalStorageService().init()));
    _initializationFutures.add(Get.putAsync(() => ThemeProvider().init()));
    _initializationFutures.add(Get.putAsync(() => SupabaseService().init()));
  }

  // Metode baru untuk menunggu semua layanan asinkron selesai diinisialisasi
  Future<void> initializeServices() async {
    print("Initializing all global services...");
    
    // Inisialisasi LocalStorageService (penting untuk Hive) - HARUS PERTAMA
    try {
      await _initializationFutures[0]; // LocalStorageService (index 0 sekarang)
      print("LocalStorageService initialized successfully.");
      
      // Verifikasi bahwa LocalStorageService sudah terdaftar
      if (Get.isRegistered<LocalStorageService>()) {
        print("LocalStorageService is registered in GetX.");
      } else {
        print("WARNING: LocalStorageService is NOT registered in GetX!");
      }
    } catch (e) {
      print('Error initializing LocalStorageService: $e');
      rethrow; // Re-throw karena LocalStorageService kritis
    }
    
    // Inisialisasi ThemeProvider (penting untuk tema)
    try {
      await _initializationFutures[1]; // ThemeProvider (index 1 sekarang)
      print("ThemeProvider initialized successfully.");
    } catch (e) {
      print('Error initializing ThemeProvider: $e');
      // Ini kritis, tapi kita akan handle di main
      rethrow;
    }
    
    // SupabaseService bisa optional
    try {
      await _initializationFutures[2]; // SupabaseService (index 2 sekarang)
      print("SupabaseService initialized successfully.");
    } catch (e) {
      print('Error initializing SupabaseService: $e');
      print('Note: App will continue without Supabase.');
      // Tidak rethrow karena Supabase optional
    }
    
    print("All critical services initialized.");
  }
}