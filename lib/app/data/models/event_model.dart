// lib/app/data/models/event_model.dart
import 'package:hive/hive.dart';

part 'event_model.g.dart'; // Ini akan dibuat secara otomatis

@HiveType(typeId: 0) // typeId harus unik untuk setiap model Hive
class EventModel {
  @HiveField(0)
  String id; // Bisa pakai UUID atau timestamp sebagai ID
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  DateTime date;
  
  @HiveField(4)
  String speaker;
  
  @HiveField(5)
  String location; // Contoh: Nama masjid atau ruangan

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.speaker,
    required this.location,
  });
}