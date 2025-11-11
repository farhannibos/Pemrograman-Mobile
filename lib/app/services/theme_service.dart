import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  final String _key = 'isDarkMode'; // Kunci untuk shared_preferences

  // Metode untuk mendapatkan instance SharedPreferences
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Metode untuk membaca tema yang tersimpan
  bool _loadThemeFromBox() {
    return Get.find<SharedPreferences>().getBool(_key) ?? false; // Default false (light mode)
  }

  // Metode untuk menyimpan tema
  Future<void> _saveThemeToBox(bool isDarkMode) async {
    await Get.find<SharedPreferences>().setBool(_key, isDarkMode);
  }

  // Metode untuk mengganti tema
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }

  // Metode untuk mendapatkan ThemeMode saat ini
  ThemeMode get themeMode => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  // Metode inisialisasi service
  // Ini akan dipanggil saat service di-load dengan Get.putAsync
  Future<ThemeService> init() async {
    // Daftarkan SharedPreferences sebagai dependency yang dapat ditemukan oleh Get
    await Get.putAsync(() => SharedPreferences.getInstance());
    // Apply theme based on saved preference
    Get.changeThemeMode(themeMode);
    return this;
  }
}