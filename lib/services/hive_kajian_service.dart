import 'package:hive/hive.dart';
import '../models/kajian_hive_model.dart';

class HiveKajianService {
  static const String boxName = 'kajianBox';
  late Box<KajianHiveModel> kajianBox;

  // Initialize Hive
  Future<void> init() async {
    await Hive.openBox<KajianHiveModel>(boxName);
    kajianBox = Hive.box<KajianHiveModel>(boxName);
  }

  // ===== BASIC CRUD OPERATIONS =====

  // Add kajian
  Future<void> addKajian(KajianHiveModel kajian) async {
    await kajianBox.put(kajian.id, kajian);
  }

  // Get all kajian
  List<KajianHiveModel> getAllKajian() {
    return kajianBox.values.toList();
  }

  // Get kajian by ID
  KajianHiveModel? getKajianById(String id) {
    return kajianBox.get(id);
  }

  // Update kajian
  Future<void> updateKajian(KajianHiveModel kajian) async {
    await kajianBox.put(kajian.id, kajian);
  }

  // Delete kajian
  Future<void> deleteKajian(String id) async {
    await kajianBox.delete(id);
  }

  // Clear all data
  Future<void> clearAll() async {
    await kajianBox.clear();
  }

  // Get count
  int getKajianCount() {
    return kajianBox.length;
  }

  // Check if empty
  bool isEmpty() {
    return kajianBox.isEmpty;
  }
}