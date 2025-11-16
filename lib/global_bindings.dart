// lib/global_bindings.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/data/services/local_storage_service.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';

class GlobalBindings extends Bindings {
  // Simpan Future untuk setiap service
  Future<LocalStorageService>? _localStorageFuture;
  Future<ThemeProvider>? _themeProviderFuture;
  Future<SupabaseService>? _supabaseFuture;

  @override
  void dependencies() {
    // Daftarkan semua layanan asinkron
    // Urutan penting: LocalStorageService harus diinisialisasi terlebih dahulu
    // karena mungkin diperlukan oleh service lain
    
    // LocalStorageService - HARUS PERTAMA
    _localStorageFuture = Get.putAsync(() => LocalStorageService().init());
    
    // ThemeProvider
    _themeProviderFuture = Get.putAsync(() => ThemeProvider().init());
    
    // SupabaseService (optional)
    _supabaseFuture = Get.putAsync(() => SupabaseService().init());
  }

  // Metode baru untuk menunggu semua layanan asinkron selesai diinisialisasi
  Future<void> initializeServices() async {
    print("Initializing all global services...");
    
    // Inisialisasi LocalStorageService (penting untuk Hive) - HARUS PERTAMA
    try {
      if (_localStorageFuture == null) {
        throw Exception('LocalStorageService future is null');
      }
      
      final localStorageService = await _localStorageFuture!;
      print("LocalStorageService initialized successfully.");
      
      // Verifikasi bahwa LocalStorageService sudah terdaftar
      if (Get.isRegistered<LocalStorageService>()) {
        print("LocalStorageService is registered in GetX.");
        
        // Verifikasi bisa diakses
        try {
          final service = Get.find<LocalStorageService>();
          print("LocalStorageService can be accessed via Get.find()");
          print("Box is open: ${service.pengajianScheduleBox.isOpen}");
        } catch (e) {
          print("WARNING: LocalStorageService is registered but cannot be accessed: $e");
          // Coba daftarkan ulang
          Get.put(localStorageService, permanent: true);
          print("LocalStorageService re-registered.");
        }
      } else {
        print("WARNING: LocalStorageService is NOT registered in GetX!");
        // Daftarkan manual
        Get.put(localStorageService, permanent: true);
        print("LocalStorageService manually registered.");
      }
    } catch (e) {
      print('Error initializing LocalStorageService: $e');
      rethrow; // Re-throw karena LocalStorageService kritis
    }
    
    // Inisialisasi ThemeProvider (penting untuk tema)
    try {
      if (_themeProviderFuture != null) {
        await _themeProviderFuture!;
        print("ThemeProvider initialized successfully.");
      }
    } catch (e) {
      print('Error initializing ThemeProvider: $e');
      // Ini kritis, tapi kita akan handle di main
      rethrow;
    }
    
    // SupabaseService bisa optional
    try {
      if (_supabaseFuture != null) {
        await _supabaseFuture!;
        print("SupabaseService initialized successfully.");
      }
    } catch (e) {
      print('Error initializing SupabaseService: $e');
      print('Note: App will continue without Supabase.');
      // Tidak rethrow karena Supabase optional
    }
    
    print("All critical services initialized.");
  }
}