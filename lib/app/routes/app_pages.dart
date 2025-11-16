// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/home/bindings/home_binding.dart';
import 'package:masjid_ku/app/modules/home/views/home_view.dart';
import 'package:masjid_ku/app/modules/settings/bindings/settings_binding.dart';
import 'package:masjid_ku/app/modules/settings/views/settings_view.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/bindings/pengajian_schedule_binding.dart';
import 'package:masjid_ku/app/modules/pengajianschedules/views/pengajian_schedule_list_view.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/bindings/khutbah_jumat_schedule_binding.dart';
import 'package:masjid_ku/app/modules/khutbahjumatschedules/views/khutbah_jumat_schedule_list_view.dart';
import 'package:masjid_ku/app/modules/auth/bindings/auth_binding.dart'; // Import binding
import 'package:masjid_ku/app/modules/auth/views/login_view.dart';     // Import view
import 'package:masjid_ku/app/modules/auth/views/register_view.dart';  // Import view
import 'package:masjid_ku/app/routes/app_routes.dart';

class AppPages {
  AppPages._();

  // Initial route akan ditentukan oleh AuthController berdasarkan status login
  static const INITIAL = Routes.LOGIN; // Ubah ini ke LOGIN

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
    GetPage(
      name: Routes.KHUTBAH_JUMAT_SCHEDULES,
      page: () => const KhutbahJumatScheduleListView(),
      binding: KhutbahJumatScheduleBinding(),
    ),
    GetPage( // <-- Tambahkan GetPage untuk Login
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(), // AuthBinding akan menginisialisasi AuthController dan AuthProvider
    ),
    GetPage( // <-- Tambahkan GetPage untuk Register
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
  ];
}