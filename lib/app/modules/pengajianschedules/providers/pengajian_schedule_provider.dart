// lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:masjid_ku/app/data/models/pengajian_schedule_model.dart';
import 'package:masjid_ku/app/data/services/local_storage_service.dart'; // Import LocalStorageService

class PengajianScheduleProvider extends GetxService {
  LocalStorageService? _localStorageService;
  
  // Method untuk mendapatkan LocalStorageService
  // Menunggu service siap dengan polling jika belum terdaftar
  Future<LocalStorageService> _getLocalStorageService() async {
    if (_localStorageService != null) {
      return _localStorageService!;
    }
    
    // Tunggu maksimal 3 detik untuk service terdaftar
    const maxWaitTime = Duration(seconds: 3);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < maxWaitTime) {
      if (Get.isRegistered<LocalStorageService>()) {
        try {
          _localStorageService = Get.find<LocalStorageService>();
          print('LocalStorageService found successfully');
          return _localStorageService!;
        } catch (e) {
          print('Error finding LocalStorageService: $e');
        }
      }
      
      // Tunggu sebentar sebelum cek lagi
      await Future.delayed(checkInterval);
    }
    
    // Jika masih belum ditemukan setelah timeout
    if (Get.isRegistered<LocalStorageService>()) {
      try {
        _localStorageService = Get.find<LocalStorageService>();
        return _localStorageService!;
      } catch (e) {
        throw Exception('LocalStorageService is registered but cannot be accessed: $e');
      }
    }
    
    throw Exception('LocalStorageService not found after waiting. Make sure it is initialized in GlobalBindings.');
  }

  static const String _dummyDataAddedKey = 'dummy_pengajian_added'; // Key untuk flag SharedPreferences

  // --- Metode untuk SharedPreferences Flag ---
  // Cek apakah data dummy sudah pernah ditambahkan
  Future<bool> hasDummyDataBeenAdded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dummyDataAddedKey) ?? false; // Default ke false jika belum ada
  }

  // Set flag bahwa data dummy sudah ditambahkan
  Future<void> setDummyDataAdded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dummyDataAddedKey, true);
    print("Flag 'dummy_pengajian_added' has been set to true.");
  }
  // --- Akhir Metode SharedPreferences Flag ---


  // --- Metode untuk Hive (CRUD) ---
  // Mendapatkan semua jadwal pengajian dari Hive, diurutkan berdasarkan createdAt (terbaru di atas)
  List<PengajianScheduleModel> getPengajianSchedules() {
    final List<PengajianScheduleModel> schedules = [];
    
    try {
      // Gunakan synchronous access jika service sudah tersedia
      if (_localStorageService == null) {
        if (!Get.isRegistered<LocalStorageService>()) {
          print('Warning: LocalStorageService not registered yet');
          return schedules;
        }
        _localStorageService = Get.find<LocalStorageService>();
      }
      
      final box = _localStorageService!.pengajianScheduleBox;
      
      // Pastikan box terbuka
      if (!box.isOpen) {
        print('Warning: Hive box is not open');
        return schedules;
      }
      
      print('Reading from Hive box. Box contains ${box.length} items');
      
      // Iterasi semua values di box dan konversi Map ke Model
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value is Map) {
            final mapData = Map<String, dynamic>.from(value);
            print('Reading item with key: $key, data: $mapData');
            schedules.add(PengajianScheduleModel.fromMap(mapData));
          } else {
            print('Warning: Item with key $key is not a Map, type: ${value.runtimeType}');
          }
        } catch (e) {
          print('Error converting map to PengajianScheduleModel for key $key: $e');
        }
      }
      
      print('Successfully loaded ${schedules.length} schedules from Hive');
      
      // Urutkan dari yang terbaru ke terlama
      schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return schedules;
    } catch (e, stackTrace) {
      print('Error getting pengajian schedules: $e');
      print('Stack trace: $stackTrace');
      return schedules;
    }
  }

  // Menambahkan jadwal pengajian baru ke Hive
  Future<void> addPengajianSchedule(PengajianScheduleModel schedule) async {
    try {
      // Pastikan LocalStorageService tersedia
      final service = await _getLocalStorageService();
      final box = service.pengajianScheduleBox;
      
      // Pastikan box terbuka
      if (!box.isOpen) {
        throw Exception('Hive box is not open');
      }
      
      // Konversi ke Map
      final mapData = schedule.toMap();
      print('Saving to Hive: ${schedule.title}');
      print('Map data: $mapData');
      
      // Simpan sebagai Map karena tidak ada Hive adapter
      await box.put(schedule.id, mapData);
      
      // Verifikasi data tersimpan
      final savedData = box.get(schedule.id);
      if (savedData == null) {
        throw Exception('Data tidak tersimpan ke Hive');
      }
      
      print('Pengajian schedule added to Hive successfully: ${schedule.title} (ID: ${schedule.id})');
      print('Box now contains ${box.length} items');
    } catch (e, stackTrace) {
      print('Error adding pengajian schedule to Hive: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Menghapus jadwal pengajian dari Hive berdasarkan ID
  Future<void> deletePengajianSchedule(String id) async {
    final service = await _getLocalStorageService();
    final box = service.pengajianScheduleBox;
    await box.delete(id);
    print('Pengajian schedule deleted from Hive: $id');
  }

  // Mengupdate jadwal pengajian di Hive
  Future<void> updatePengajianSchedule(PengajianScheduleModel updatedSchedule) async {
    final service = await _getLocalStorageService();
    final box = service.pengajianScheduleBox;
    if (box.containsKey(updatedSchedule.id)) {
      await box.put(updatedSchedule.id, updatedSchedule.toMap());
      print('Pengajian schedule updated in Hive: ${updatedSchedule.title} (ID: ${updatedSchedule.id})');
    } else {
      print('Pengajian schedule with ID ${updatedSchedule.id} not found in Hive for update.');
    }
  }

  // Menghapus semua jadwal pengajian dari Hive
  Future<void> clearAllPengajianSchedules() async {
    final service = await _getLocalStorageService();
    final box = service.pengajianScheduleBox;
    await box.clear();
    print("Cleared all Pengajian schedules from Hive.");
  }
  // --- Akhir Metode Hive (CRUD) ---
}