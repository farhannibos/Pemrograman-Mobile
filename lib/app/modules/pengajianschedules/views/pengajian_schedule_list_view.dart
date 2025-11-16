// lib/app/modules/pengajianschedules/views/pengajian_schedule_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:masjid_ku/app/modules/pengajianschedules/controllers/pengajian_schedule_controller.dart';

class PengajianScheduleListView extends GetView<PengajianScheduleController> {
  const PengajianScheduleListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pengajian (Lokal)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadPengajianSchedules(), // Muat ulang data
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.pengajianSchedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum ada jadwal pengajian.'),
                ElevatedButton(
                  onPressed: () => controller.addDummyData(), // Tambah dummy jika kosong
                  child: const Text('Tambah Contoh Jadwal'),
                ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            itemCount: controller.pengajianSchedules.length,
            itemBuilder: (context, index) {
              final schedule = controller.pengajianSchedules[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(schedule.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Penceramah: ${schedule.speaker}'),
                      Text('Tanggal: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(schedule.date)}'), // Format tanggal
                      Text('Waktu: ${schedule.time}'),
                      Text(schedule.description),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => controller.deletePengajian(schedule.id),
                  ),
                  onTap: () {
                    // Implementasi detail atau edit pengajian nanti
                    Get.snackbar(
                      'Detail Pengajian',
                      '${schedule.title} oleh ${schedule.speaker}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Panggil metode untuk menampilkan dialog tambah pengajian
          controller.showAddPengajianDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}