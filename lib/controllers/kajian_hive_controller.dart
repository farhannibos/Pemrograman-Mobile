import 'package:get/get.dart';
import '../services/hive_kajian_service.dart';
import '../models/kajian_hive_model.dart';

class KajianHiveController extends GetxController {
  final HiveKajianService hiveService = Get.find();
  final RxList<KajianHiveModel> kajianList = <KajianHiveModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadKajianFromHive();
  }

  Future<void> loadKajianFromHive() async {
    isLoading.value = true;
    try {
      final data = hiveService.getAllKajian();
      kajianList.assignAll(data);
      print('📂 Loaded ${data.length} kajian from Hive');
    } catch (e) {
      print('❌ Error loading kajian from Hive: $e');
    }
    isLoading.value = false;
  }

  Future<void> addKajian(KajianHiveModel kajian) async {
    try {
      await hiveService.addKajian(kajian);
      await loadKajianFromHive(); // Reload dari Hive
      print('✅ Kajian added to Hive: ${kajian.title}');
    } catch (e) {
      print('❌ Error adding kajian to Hive: $e');
      rethrow;
    }
  }

  Future<void> updateKajian(KajianHiveModel kajian) async {
    try {
      await hiveService.updateKajian(kajian);
      await loadKajianFromHive(); // Reload dari Hive
      print('✅ Kajian updated in Hive: ${kajian.title}');
    } catch (e) {
      print('❌ Error updating kajian in Hive: $e');
      rethrow;
    }
  }

  Future<void> deleteKajian(String id) async {
    try {
      await hiveService.deleteKajian(id);
      await loadKajianFromHive(); // Reload dari Hive
      print('✅ Kajian deleted from Hive: $id');
    } catch (e) {
      print('❌ Error deleting kajian from Hive: $e');
      rethrow;
    }
  }

  int getTotalKajian() {
    return kajianList.length;
  }

  // Clear all data untuk testing
  Future<void> clearAllKajian() async {
    try {
      await hiveService.clearAll();
      kajianList.clear();
      print('✅ All kajian cleared from Hive');
    } catch (e) {
      print('❌ Error clearing kajian from Hive: $e');
    }
  }
}