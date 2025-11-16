// lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:masjid_ku/app/data/models/pengajian_schedule_model.dart';
import 'package:masjid_ku/app/data/services/local_storage_service.dart'; // Import LocalStorageService

class PengajianScheduleProvider extends GetxService {
  // Lazy getter untuk LocalStorageService
  // Menggunakan Get.find() saat diperlukan, bukan di constructor
  LocalStorageService get _localStorageService {
    if (!Get.isRegistered<LocalStorageService>()) {
      throw Exception('LocalStorageService not found. Make sure it is initialized in GlobalBindings.');
    }
    return Get.find<LocalStorageService>();
  }

  // Getter untuk Hive Box jadwal pengajian
  // Menggunakan box dari LocalStorageService yang sudah dibuka
  Box get _box {
    try {
      return _localStorageService.pengajianScheduleBox;
    } catch (e) {
      throw Exception('Failed to access pengajianScheduleBox: $e');
    }
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
      // Pastikan box terbuka
      if (!_box.isOpen) {
        print('Warning: Hive box is not open');
        return schedules;
      }
      
      print('Reading from Hive box. Box contains ${_box.length} items');
      
      // Iterasi semua values di box dan konversi Map ke Model
      for (var key in _box.keys) {
        try {
          final value = _box.get(key);
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
      // Pastikan box terbuka
      if (!_box.isOpen) {
        throw Exception('Hive box is not open');
      }
      
      // Konversi ke Map
      final mapData = schedule.toMap();
      print('Saving to Hive: ${schedule.title}');
      print('Map data: $mapData');
      
      // Simpan sebagai Map karena tidak ada Hive adapter
      await _box.put(schedule.id, mapData);
      
      // Verifikasi data tersimpan
      final savedData = _box.get(schedule.id);
      if (savedData == null) {
        throw Exception('Data tidak tersimpan ke Hive');
      }
      
      print('Pengajian schedule added to Hive successfully: ${schedule.title} (ID: ${schedule.id})');
      print('Box now contains ${_box.length} items');
    } catch (e, stackTrace) {
      print('Error adding pengajian schedule to Hive: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Menghapus jadwal pengajian dari Hive berdasarkan ID
  Future<void> deletePengajianSchedule(String id) async {
    await _box.delete(id);
    print('Pengajian schedule deleted from Hive: $id');
  }

  // Mengupdate jadwal pengajian di Hive
  Future<void> updatePengajianSchedule(PengajianScheduleModel updatedSchedule) async {
    if (_box.containsKey(updatedSchedule.id)) {
      await _box.put(updatedSchedule.id, updatedSchedule.toMap());
      print('Pengajian schedule updated in Hive: ${updatedSchedule.title} (ID: ${updatedSchedule.id})');
    } else {
      print('Pengajian schedule with ID ${updatedSchedule.id} not found in Hive for update.');
    }
  }

  // Menghapus semua jadwal pengajian dari Hive
  Future<void> clearAllPengajianSchedules() async {
    await _box.clear();
    print("Cleared all Pengajian schedules from Hive.");
  }
  // --- Akhir Metode Hive (CRUD) ---
}