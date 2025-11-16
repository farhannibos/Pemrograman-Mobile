// lib/app/modules/khutbahjumatschedules/controllers/khutbah_jumat_schedule_controller.dart
import 'package:flutter/material.dart'; // Untuk Get.snackbar colors
import 'package:get/get.dart';
import 'package:masjid_ku/app/data/models/khutbah_jumat_schedule_model.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart';

class KhutbahJumatScheduleController extends GetxController {
  final KhutbahJumatScheduleProvider _provider = Get.find<KhutbahJumatScheduleProvider>();

  // Observable list untuk menampilkan jadwal khutbah di UI
  final RxList<KhutbahJumatScheduleModel> khutbahSchedules = <KhutbahJumatScheduleModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadKhutbahJumatSchedules();
  }

  void loadKhutbahJumatSchedules() async {
    isLoading.value = true;
    try {
      final data = await _provider.getKhutbahJumatSchedules();
      khutbahSchedules.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal khutbah Jumat: $e',
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Error loading khutbah jumat schedules: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Tambahkan metode refresh untuk FAb atau Pull-to-refresh
  Future<void> refreshSchedules() async {
    loadKhutbahJumatSchedules();
  }
}