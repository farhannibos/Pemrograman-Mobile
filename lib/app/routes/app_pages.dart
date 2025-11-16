// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/home/bindings/home_binding.dart';
import 'package:masjid_ku/app/modules/home/views/home_view.dart';
import 'package:masjid_ku/app/modules/settings/bindings/settings_binding.dart';
import 'package:masjid_ku/app/modules/settings/views/settings_view.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/bindings/pengajian_schedule_binding.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/views/pengajian_schedule_list_view.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/bindings/khutbah_jumat_schedule_binding.dart'; // Import binding
import 'package:masjid_ku/app/modules/khutbahjumatschedules/views/khutbah_jumat_schedule_list_view.dart'; // Import view
import 'package:masjid_ku/app/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.PENGAJIAN_SCHEDULES,
      page: () => const PengajianScheduleListView(),
      binding: PengajianScheduleBinding(),
    ),
    GetPage( // Tambahkan GetPage ini
      name: Routes.KHUTBAH_JUMAT_SCHEDULES,
      page: () => const KhutbahJumatScheduleListView(),
      binding: KhutbahJumatScheduleBinding(),
    ),
  ];
}