// lib/app/data/models/khutbah_jumat_schedule_model.dart
class KhutbahJumatScheduleModel {
  final String id;
  final DateTime date;
  final String khatibName;
  final String? topic;
  final String? time;
  final DateTime createdAt;
  final String? userId; // ID user yang membuat jadwal ini

  KhutbahJumatScheduleModel({
    required this.id,
    required this.date,
    required this.khatibName,
    this.topic,
    this.time,
    required this.createdAt,
    this.userId,
  });

  factory KhutbahJumatScheduleModel.fromJson(Map<String, dynamic> json) {
    return KhutbahJumatScheduleModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      khatibName: json['khatib_name'] as String,
      topic: json['topic'] as String?,
      time: json['time'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'khatib_name': khatibName,
      'topic': topic,
      'time': time,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}