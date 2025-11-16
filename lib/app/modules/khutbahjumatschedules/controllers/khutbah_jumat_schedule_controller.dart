// lib/app/modules/khutbahjumatschedules/controllers/khutbah_jumat_schedule_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk DateFormat
import 'package:masjid_ku/app/data/models/khutbah_jumat_schedule_model.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart';
import 'package:uuid/uuid.dart'; // Untuk membuat ID unik jika dibutuhkan

class KhutbahJumatScheduleController extends GetxController {
  final KhutbahJumatScheduleProvider _provider = Get.find<KhutbahJumatScheduleProvider>();
  final Uuid _uuid = const Uuid(); // Untuk ID unik jika di-generate di client

  final RxList<KhutbahJumatScheduleModel> khutbahSchedules = <KhutbahJumatScheduleModel>[].obs;
  final RxBool isLoading = true.obs;

  // Controllers untuk form input
  final TextEditingController khatibNameController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController timeController = TextEditingController(); // Untuk input waktu (string)
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null); // Untuk input tanggal

  @override
  void onInit() {
    super.onInit();
    loadKhutbahJumatSchedules();
  }

  // Metode untuk membersihkan controller form saat tidak digunakan
  @override
  void onClose() {
    khatibNameController.dispose();
    topicController.dispose();
    timeController.dispose();
    super.onClose();
  }

  Future<void> loadKhutbahJumatSchedules() async {
    isLoading.value = true;
    try {
      final data = await _provider.getKhutbahJumatSchedules();
      khutbahSchedules.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal khutbah Jumat dari cloud: $e',
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Error loading khutbah jumat schedules: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSchedules() async {
    await loadKhutbahJumatSchedules();
  }

  // --- Metode Baru: Menampilkan Dialog Tambah Khutbah Jumat ---
  void showAddKhutbahDialog() {
    // Reset form field
    khatibNameController.clear();
    topicController.clear();
    timeController.clear();
    selectedDate.value = null; // Reset tanggal
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tambah Jadwal Khutbah Jumat Baru", style: Get.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: khatibNameController, decoration: const InputDecoration(labelText: 'Nama Khatib')),
              TextField(controller: topicController, decoration: const InputDecoration(labelText: 'Topik Khutbah (Opsional)')),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Waktu (misal: 12:00 atau 12:00:00) (Opsional)', helperText: 'Format: HH:MM atau HH:MM:SS')),
              const SizedBox(height: 10),
              // Tombol untuk memilih tanggal
              Obx(() => ListTile(
                    title: Text(selectedDate.value == null
                        ? 'Pilih Tanggal'
                        : 'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate.value!)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null && picked != selectedDate.value) {
                        selectedDate.value = picked;
                      }
                    },
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => addKhutbahJumat(), // Panggil metode add
                child: const Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Metode Baru: Menambahkan Khutbah Jumat ke Supabase ---
  void addKhutbahJumat() async {
    if (khatibNameController.text.isEmpty || selectedDate.value == null) {
      Get.snackbar('Validasi', 'Nama Khatib dan Tanggal harus diisi.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.back(); // Tutup bottom sheet
    isLoading.value = true;
    try {
      final newSchedule = KhutbahJumatScheduleModel(
        // Supabase akan generate ID, jadi kita bisa pakai placeholder atau ID client jika Supabase tidak generate
        // Untuk tabel kita yang pakai uuid_generate_v4() default, ID ini akan diabaikan oleh Supabase saat insert
        id: _uuid.v4(), 
        date: selectedDate.value!,
        khatibName: khatibNameController.text,
        topic: topicController.text.isNotEmpty ? topicController.text : null,
        time: timeController.text.isNotEmpty ? timeController.text : null,
        createdAt: DateTime.now(),
      );
      await _provider.addKhutbahSchedule(newSchedule);
      loadKhutbahJumatSchedules(); // Muat ulang data setelah menambah
      Get.snackbar('Sukses', 'Jadwal khutbah Jumat berhasil ditambahkan.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan jadwal khutbah Jumat: $e',
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Error in addKhutbahJumat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Metode Baru: Menghapus Khutbah Jumat dari Supabase ---
  void deleteKhutbahJumat(String id) {
    Get.defaultDialog(
      title: "Hapus Jadwal",
      middleText: "Anda yakin ingin menghapus jadwal khutbah Jumat ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Tutup dialog konfirmasi
        isLoading.value = true;
        try {
          await _provider.deleteKhutbahSchedule(id);
          loadKhutbahJumatSchedules(); // Muat ulang data setelah menghapus
          Get.snackbar('Sukses', 'Jadwal khutbah Jumat berhasil dihapus.',
              backgroundColor: Colors.green, colorText: Colors.white);
        } catch (e) {
          Get.snackbar('Error', 'Gagal menghapus jadwal khutbah Jumat: $e',
              backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
          print("Error in deleteKhutbahJumat: $e");
        } finally {
          isLoading.value = false;
        }
      },
    );
  }
}