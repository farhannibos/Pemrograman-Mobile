// lib/app/routes/app_routes.dart
abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  // Tambahkan rute lain di sini
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  // Tambahkan path lain di sini
}