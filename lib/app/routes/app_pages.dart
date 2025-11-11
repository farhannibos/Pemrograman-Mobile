// lib/app/routes/app_pages.dart
import 'package:get/get.dart';

// Import views dan bindings yang akan digunakan
import '/app/modules/home/views/home_view.dart';
import '/app/modules/home/bindings/home_binding.dart';

import 'app_routes.dart'; // Import AppRoutes

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME; // Tentukan rute awal aplikasi

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // Tambahkan GetPage untuk rute lain di sini
  ];
}