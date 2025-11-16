// lib/app/data/models/pengajian_schedule_model.dart
class PengajianScheduleModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String speaker;
  final DateTime createdAt;
  final String? userId; // ID user yang membuat jadwal ini

  PengajianScheduleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.speaker,
    required this.createdAt,
    this.userId,
  });

  // Convert to Map untuk penyimpanan (jika diperlukan)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'speaker': speaker,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from Map (jika diperlukan)
  factory PengajianScheduleModel.fromMap(Map<String, dynamic> map) {
    return PengajianScheduleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      speaker: map['speaker'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      userId: map['userId'] as String?,
    );
  }
}

