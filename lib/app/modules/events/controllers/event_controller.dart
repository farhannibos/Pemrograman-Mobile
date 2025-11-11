// lib/app/modules/events/controllers/event_controller.dart
import 'package:get/get.dart';
import '/app/data/models/event_model.dart';
import '/app/data/repositories/event_repository.dart';
import 'package:uuid/uuid.dart'; // Untuk menghasilkan ID unik (tambahkan di pubspec.yaml jika belum)

class EventController extends GetxController {
  final EventRepository _eventRepository = Get.find<EventRepository>();
  final events = <EventModel>[].obs; // Data event yang diobservasi

  @override
  void onInit() {
    super.onInit();
    fetchEvents(); // Ambil event saat controller diinisialisasi
  }

  void fetchEvents() {
    // Mengukur waktu baca
    _eventRepository.measureExecutionTime(() async {
      final fetchedEvents = _eventRepository.getAllEvents();
      events.assignAll(fetchedEvents); // Perbarui list events yang diobservasi
    }, 'Hive Read All Events');
  }

  void addEvent(String title, String description, DateTime date, String speaker, String location) async {
    const uuid = Uuid();
    final newEvent = EventModel(
      id: uuid.v4(), // Generate ID unik
      title: title,
      description: description,
      date: date,
      speaker: speaker,
      location: location,
    );
    // Mengukur waktu tulis
    await _eventRepository.measureExecutionTime(() async {
      await _eventRepository.addEvent(newEvent);
    }, 'Hive Add Event');
    fetchEvents(); // Refresh daftar event
    Get.back(); // Kembali setelah menambahkan
  }

  void updateEvent(String id, String title, String description, DateTime date, String speaker, String location) async {
    final updatedEvent = EventModel(
      id: id,
      title: title,
      description: description,
      date: date,
      speaker: speaker,
      location: location,
    );
    // Mengukur waktu update
    await _eventRepository.measureExecutionTime(() async {
      await _eventRepository.updateEvent(updatedEvent);
    }, 'Hive Update Event');
    fetchEvents(); // Refresh daftar event
    Get.back(); // Kembali setelah update
  }

  void deleteEvent(String id) async {
    // Mengukur waktu hapus
    await _eventRepository.measureExecutionTime(() async {
      await _eventRepository.deleteEvent(id);
    }, 'Hive Delete Event');
    fetchEvents(); // Refresh daftar event
  }

  void clearAllEvents() async {
    await _eventRepository.clearAllEvents();
    fetchEvents();
  }
}