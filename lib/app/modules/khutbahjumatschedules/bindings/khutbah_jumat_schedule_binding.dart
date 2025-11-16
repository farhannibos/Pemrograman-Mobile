// lib/app/modules/khutbahjumatschedules/bindings/khutbah_jumat_schedule_binding.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/controllers/khutbah_jumat_schedule_controller.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart';

class KhutbahJumatScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // Registrasi KhutbahJumatScheduleProvider sebagai layanan
    Get.lazyPut<KhutbahJumatScheduleProvider>(
      () => KhutbahJumatScheduleProvider(),
    );
    // Instansiasi KhutbahJumatScheduleController
    Get.lazyPut<KhutbahJumatScheduleController>(
      () => KhutbahJumatScheduleController(),
    );
  }
}