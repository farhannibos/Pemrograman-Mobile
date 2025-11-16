// lib/app/routes/app_routes.dart
abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SETTINGS = _Paths.SETTINGS;
  static const PENGAJIAN_SCHEDULES = _Paths.PENGAJIAN_SCHEDULES; // Tambahkan ini
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SETTINGS = '/settings';
  static const PENGAJIAN_SCHEDULES = '/pengajian-schedules'; // Tambahkan ini
}