// lib/app/modules/khutbahjumatschedules/views/khutbah_jumat_schedule_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/controllers/khutbah_jumat_schedule_controller.dart';

class KhutbahJumatScheduleListView extends GetView<KhutbahJumatScheduleController> {
  const KhutbahJumatScheduleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Khutbah Jumat (Cloud)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshSchedules(), // Refresh data dari Supabase
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.khutbahSchedules.isEmpty) {
          return const Center(
            child: Text('Belum ada jadwal khutbah Jumat dari cloud.'),
          );
        } else {
          return ListView.builder(
            itemCount: controller.khutbahSchedules.length,
            itemBuilder: (context, index) {
              final schedule = controller.khutbahSchedules[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Khatib: ${schedule.khatibName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(schedule.date)}'),
                      if (schedule.topic != null && schedule.topic!.isNotEmpty)
                        Text('Topik: ${schedule.topic}'),
                      if (schedule.time != null && schedule.time!.isNotEmpty)
                        Text('Waktu: ${schedule.time}'),
                    ],
                  ),
                  onTap: () {
                    Get.snackbar(
                      'Detail Khutbah',
                      'Khatib ${schedule.khatibName} pada ${DateFormat('dd MMMM yyyy').format(schedule.date)}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              );
            },
          );
        }
      }),
    );
  }
}