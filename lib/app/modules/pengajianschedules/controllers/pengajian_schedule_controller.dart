// lib/app/modules/pengajianschedules/controllers/pengajian_schedule_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:masjid_ku/app/data/models/pengajian_schedule_model.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart';
import 'package:uuid/uuid.dart'; // Untuk membuat ID unik

class PengajianScheduleController extends GetxController {
  final PengajianScheduleProvider _provider =
      Get.find<PengajianScheduleProvider>();
  final Uuid _uuid = const Uuid(); // Untuk menghasilkan ID unik

  // Observable list untuk menampilkan jadwal pengajian di UI
  final RxList<PengajianScheduleModel> pengajianSchedules =
      <PengajianScheduleModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPengajianSchedules();
  }

  Future<void> loadPengajianSchedules() async {
    isLoading.value = true;
    try {
      final data = _provider.getPengajianSchedules();
      pengajianSchedules.assignAll(data);
      print('Loaded ${data.length} pengajian schedules');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat jadwal pengajian: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      print("Error loading pengajian schedules: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void showAddPengajianDialog() {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeController = TextEditingController();
    
    // Default tanggal adalah hari ini (set ke jam 00:00:00 untuk konsistensi)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = today.obs;
    
    // Default waktu adalah 19:00
    timeController.text = '19:00 WIB';

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16,
        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tambah Jadwal Pengajian Baru",
                    style: Get.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Pengajian *',
                  hintText: 'Contoh: Kajian Fiqih Shalat',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: speakerController,
                decoration: const InputDecoration(
                  labelText: 'Penceramah *',
                  hintText: 'Contoh: Ustadz Ali Fikri, Lc.',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Deskripsi singkat tentang pengajian',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              // Date Picker
              Obx(() => InkWell(
                onTap: () async {
                  try {
                    final DateTime? picked = await showDatePicker(
                      context: Get.context!,
                      initialDate: selectedDate.value,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      // Hapus locale untuk menghindari error jika locale tidak tersedia
                      // locale: const Locale('id', 'ID'),
                    );
                    if (picked != null) {
                      // Set ke jam 00:00:00 untuk konsistensi
                      final pickedDate = DateTime(picked.year, picked.month, picked.day);
                      selectedDate.value = pickedDate;
                    }
                  } catch (e) {
                    print('Error showing date picker: $e');
                    Get.snackbar(
                      'Error',
                      'Gagal membuka date picker: $e',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Pengajian *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _formatDate(selectedDate.value),
                    style: Get.textTheme.bodyLarge,
                  ),
                ),
              )),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Waktu *',
                  hintText: 'Contoh: 19:30 WIB',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validasi input
                    if (titleController.text.trim().isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Judul pengajian harus diisi',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    if (speakerController.text.trim().isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Penceramah harus diisi',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    if (timeController.text.trim().isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Waktu harus diisi',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Simpan data
                    try {
                      // Tampilkan loading indicator
                      Get.dialog(
                        const Center(child: CircularProgressIndicator()),
                        barrierDismissible: false,
                      );
                      
                      await addPengajian(
                        titleController.text.trim(),
                        descriptionController.text.trim().isEmpty
                            ? "Tidak ada deskripsi"
                            : descriptionController.text.trim(),
                        selectedDate.value,
                        timeController.text.trim(),
                        speakerController.text.trim(),
                      );
                      
                      // Tutup loading indicator
                      Get.back();
                      
                      // Tutup bottom sheet
                      Get.back();
                      
                      Get.snackbar(
                        'Sukses',
                        'Jadwal pengajian berhasil ditambahkan',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    } catch (e, stackTrace) {
                      // Tutup loading indicator jika masih terbuka
                      if (Get.isDialogOpen ?? false) {
                        Get.back();
                      }
                      
                      print('Error saving pengajian: $e');
                      print('Stack trace: $stackTrace');
                      
                      Get.snackbar(
                        'Error',
                        'Gagal menyimpan jadwal pengajian: ${e.toString()}',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 4),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan Jadwal Pengajian'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
    );
  }

  // Metode untuk menambahkan data dummy jika tidak ada data awal
  void addDummyData() async {
    print("Adding dummy pengajian data...");
    await _provider.addPengajianSchedule(
      PengajianScheduleModel(
        id: _uuid.v4(),
        title: 'Kajian Fiqih Shalat',
        description: 'Membahas tata cara shalat yang benar menurut sunnah.',
        date: DateTime.now().add(const Duration(days: 2)),
        time: '19:30 WIB',
        speaker: 'Ustadz Ali Fikri, Lc.',
        createdAt: DateTime.now(),
      ),
    );
    await _provider.addPengajianSchedule(
      PengajianScheduleModel(
        id: _uuid.v4(),
        title: 'Belajar Hadits Arbain',
        description:
            'Pembahasan Hadits ke-12: Keutamaan Meninggalkan yang Tidak Bermanfaat.',
        date: DateTime.now().add(const Duration(days: 5)),
        time: '16:00 WIB',
        speaker: 'Ustadzah Fatimah Azzahra, M.Pd.I',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );
    await _provider.addPengajianSchedule(
      PengajianScheduleModel(
        id: _uuid.v4(),
        title: 'Bedah Buku Riyadhus Shalihin',
        description: 'Bab Adab Menuntut Ilmu.',
        date: DateTime.now().add(const Duration(days: 10)),
        time: '20:00 WIB',
        speaker: 'Prof. Dr. Ahmad Yusuf',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );
    // Setelah menambah dummy data, muat ulang jadwal

    await _provider.setDummyDataAdded();
    pengajianSchedules.assignAll(_provider.getPengajianSchedules());
  }

  // Metode untuk menambahkan pengajian (untuk UI form nanti jika dibutuhkan)
  Future<void> addPengajian(
    String title,
    String description,
    DateTime date,
    String time,
    String speaker,
  ) async {
    try {
      final newSchedule = PengajianScheduleModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        date: date,
        time: time,
        speaker: speaker,
        createdAt: DateTime.now(),
      );
      
      // Simpan ke Hive melalui provider
      await _provider.addPengajianSchedule(newSchedule);
      
      // Muat ulang data setelah menambah
      await loadPengajianSchedules();
      
      print('Pengajian schedule saved successfully: ${newSchedule.title}');
    } catch (e) {
      print('Error saving pengajian schedule: $e');
      rethrow; // Re-throw agar error bisa ditangani di UI
    }
  }

  // Metode untuk menghapus pengajian
  Future<void> deletePengajian(String id) async {
    Get.defaultDialog(
      title: "Hapus Pengajian",
      middleText: "Anda yakin ingin menghapus jadwal pengajian ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Tutup dialog
        await _provider.deletePengajianSchedule(id);
        loadPengajianSchedules(); // Muat ulang data setelah menghapus
        Get.snackbar(
          'Sukses',
          'Jadwal pengajian berhasil dihapus.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  // Helper method untuk format tanggal dengan fallback
  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      // Fallback ke format default jika locale tidak tersedia
      return DateFormat('EEEE, dd MMMM yyyy').format(date);
    }
  }
}