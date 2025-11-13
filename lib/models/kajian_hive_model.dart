import 'package:hive/hive.dart';

part 'kajian_hive_model.g.dart'; // File yang akan digenerate

@HiveType(typeId: 0)
class KajianHiveModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final String pemateri;
  
  @HiveField(5)
  final String lokasi;

  KajianHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.pemateri,
    required this.lokasi,
  });

  // Format date untuk display
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'pemateri': pemateri,
      'lokasi': lokasi,
    };
  }
}