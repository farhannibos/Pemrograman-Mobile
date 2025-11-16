// lib/app/data/services/local_storage_service.dart
import 'package:flutter/foundation.dart' show kIsWeb; // <-- Import kIsWeb
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart'; // Tetap import untuk non-web

class LocalStorageService extends GetxService {
  // Gunakan Box biasa karena model belum memiliki Hive adapter
  // Data akan disimpan sebagai Map dan dikonversi ke Model saat dibaca
  late Box _pengajianScheduleBox;
  Box get pengajianScheduleBox => _pengajianScheduleBox;

  Future<LocalStorageService> init() async {
    print("LocalStorageService: Starting init()...");
    try {
      if (kIsWeb) {
        // --- PERBAIKAN UNTUK WEB ---
        // Untuk web, Hive.initFlutter() cukup dipanggil tanpa argumen.
        // Ini akan menggunakan IndexedDB di browser secara otomatis.
        await Hive.initFlutter();
        print("LocalStorageService: Hive initialized for WEB platform.");
      } else {
        // --- UNTUK PLATFORM NON-WEB (Android, iOS, Desktop) ---
        // Gunakan path_provider untuk mendapatkan direktori dokumen aplikasi.
        final appDocumentDir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(appDocumentDir.path);
        print("LocalStorageService: Hive initialized for non-WEB platform at ${appDocumentDir.path}");
      }
      
      // Catatan: Model PengajianScheduleModel belum memiliki Hive adapter
      // Data akan disimpan sebagai Map menggunakan toMap() dan dikonversi kembali menggunakan fromMap()
      // Buka box untuk jadwal pengajian (tanpa type parameter karena tidak ada adapter)
      _pengajianScheduleBox = await Hive.openBox('pengajian_schedule_box');
      print("LocalStorageService: Pengajian Schedule Box Opened. Contains ${_pengajianScheduleBox.length} items.");
      
      print("LocalStorageService: Init() completed successfully.");
      return this; // Mengembalikan instance service setelah berhasil diinisialisasi
    } catch (e, stackTrace) { // Menangkap stack trace untuk debugging lebih baik
      print("LocalStorageService: FATAL ERROR during init(): $e");
      print("Stack Trace: $stackTrace");
      rethrow; // Sangat penting: lempar ulang error agar GetX tahu inisialisasi gagal
    }
  }

  @override
  void onClose() {
    // Hanya tutup box jika memang sudah terbuka
    if (_pengajianScheduleBox.isOpen) {
      _pengajianScheduleBox.close();
      print("LocalStorageService: Pengajian Schedule Box Closed.");
    }
    super.onClose();
  }
}