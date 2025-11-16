// lib/app/modules/pengajianschedules/bindings/pengajian_schedule_binding.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/controllers/pengajian_schedule_controller.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart';

class PengajianScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // Registrasi PengajianScheduleProvider sebagai layanan
    Get.lazyPut<PengajianScheduleProvider>(
      () => PengajianScheduleProvider(),
    );
    // Instansiasi PengajianScheduleController
    Get.lazyPut<PengajianScheduleController>(
      () => PengajianScheduleController(),
    );
  }
}