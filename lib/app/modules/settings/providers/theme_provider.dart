// lib/app/modules/settings/providers/theme_provider.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends GetxService {
  static const String _themeKey = 'isDarkTheme'; // Key untuk shared_preferences
  
  // RxBool untuk membuat isDarkMode observable
  final RxBool _isDarkMode = false.obs;

  // Getter untuk mengakses nilai isDarkMode secara reaktif
  RxBool get isDarkMode => _isDarkMode;

  // Metode untuk inisialisasi provider, memuat tema dari shared_preferences
  Future<ThemeProvider> init() async {
    await _loadTheme();
    print("ThemeProvider Initialized. Dark mode: ${_isDarkMode.value}");
    return this;
  }

  // Memuat status tema dari shared_preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIsDark = prefs.getBool(_themeKey) ?? false; // Default ke false (light mode)
      _isDarkMode.value = savedIsDark;
    } catch (e) {
      print("Error loading theme from shared_preferences: $e");
      _isDarkMode.value = false; // Fallback ke light mode jika ada error
    }
  }

  // Mengubah status tema dan menyimpannya ke shared_preferences
  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value; // Balikkan nilai tema
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode.value); // Simpan status tema baru
      print("Theme toggled to dark mode: ${_isDarkMode.value}");
    } catch (e) {
      print("Error saving theme to shared_preferences: $e");
      // Jika gagal menyimpan, kembalikan ke nilai sebelumnya (opsional, tergantung UX)
      // _isDarkMode.value = !_isDarkMode.value; 
    }
  }
}