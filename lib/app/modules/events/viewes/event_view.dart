// lib/app/modules/events/views/event_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_form_model.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal (tambahkan di pubspec.yaml jika belum)

class EventView extends GetView<EventController> {
  const EventView({Key? key}) : super(key: key);

  void _showEventForm({EventModel? event}) {
    final isEditing = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final speakerController = TextEditingController(text: event?.speaker ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    Rx<DateTime> selectedDate = (event?.date ?? DateTime.now()).obs;

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.theme.canvasColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEditing ? 'Edit Acara' : 'Tambah Acara Baru', style: Get.textTheme.titleLarge),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Judul Acara'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              TextField(
                controller: speakerController,
                decoration: InputDecoration(labelText: 'Pembicara'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Lokasi'),
              ),
              SizedBox(height: 10),
              Obx(() => ListTile(
                title: Text('Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate.value)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate.value) {
                    selectedDate.value = picked;
                  }
                },
              )),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isEditing) {
                        controller.updateEvent(
                          event!.id,
                          titleController.text,
                          descriptionController.text,
                          selectedDate.value,
                          speakerController.text,
                          locationController.text,
                        );
                      } else {
                        controller.addEvent(
                          titleController.text,
                          descriptionController.text,
                          selectedDate.value,
                          speakerController.text,
                          locationController.text,
                        );
                      }
                    },
                    child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Acara Masjid (Hive)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () => Get.defaultDialog(
              title: "Hapus Semua?",
              middleText: "Anda yakin ingin menghapus semua acara?",
              onConfirm: () {
                controller.clearAllEvents();
                Get.back();
              },
              onCancel: () => Get.back(),
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.events.isEmpty) {
            return const Center(
              child: Text('Belum ada acara. Tambahkan satu!'),
            );
          }
          return ListView.builder(
            itemCount: controller.events.length,
            itemBuilder: (context, index) {
              final event = controller.events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(event.date)} - ${event.speaker}\n${event.location}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEventForm(event: event),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => Get.defaultDialog(
                          title: "Hapus Acara?",
                          middleText: "Anda yakin ingin menghapus acara '${event.title}'?",
                          onConfirm: () {
                            controller.deleteEvent(event.id);
                            Get.back();
                          },
                          onCancel: () => Get.back(),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}