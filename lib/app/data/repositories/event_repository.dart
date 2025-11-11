// lib/app/data/repositories/event_repository.dart
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/app/data/models/event_model.dart'; // Import EventModel

class EventRepository extends GetxService {
  late Box<EventModel> _eventBox;
  final String _boxName = 'events'; // Nama box (tabel) Hive

  // Metode inisialisasi untuk EventRepository
  Future<EventRepository> init() async {
    // Membuka box Hive
    _eventBox = await Hive.openBox<EventModel>(_boxName);
    return this;
  }

  // CREATE: Menambahkan event baru
  Future<void> addEvent(EventModel event) async {
    await _eventBox.put(event.id, event); // Menggunakan id sebagai kunci
    // Atau bisa juga: await _eventBox.add(event); jika tidak perlu kunci spesifik
  }

  // READ: Mengambil semua event
  List<EventModel> getAllEvents() {
    return _eventBox.values.toList();
  }

  // READ: Mengambil event berdasarkan ID
  EventModel? getEventById(String id) {
    return _eventBox.get(id);
  }

  // UPDATE: Memperbarui event
  Future<void> updateEvent(EventModel event) async {
    await _eventBox.put(event.id, event); // Menulis ulang event dengan ID yang sama
  }

  // DELETE: Menghapus event berdasarkan ID
  Future<void> deleteEvent(String id) async {
    await _eventBox.delete(id);
  }

  // DELETE ALL: Menghapus semua event (untuk testing/reset)
  Future<void> clearAllEvents() async {
    await _eventBox.clear();
  }

  // Merekam waktu eksekusi
  Future<T> measureExecutionTime<T>(Future<T> Function() operation, String operationName) async {
    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();
    print('[$operationName] took ${stopwatch.elapsedMicroseconds} µs');
    return result;
  }
}