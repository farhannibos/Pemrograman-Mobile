// lib/app/modules/settings/controllers/settings_controller.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/settings/providers/theme_provider.dart';

class SettingsController extends GetxController {
  // Dapatkan instance ThemeProvider yang sudah diinisialisasi secara global
  final ThemeProvider _themeProvider = Get.find<ThemeProvider>();

  // Getter untuk status dark mode, langsung dari ThemeProvider (reaktif)
  RxBool get isDarkMode => _themeProvider.isDarkMode;

  // Metode untuk mengubah tema
  void toggleTheme() {
    _themeProvider.toggleTheme();
  }
}