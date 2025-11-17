import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxController {
  static ThemeService get to => Get.find<ThemeService>();
  
  final RxBool isDarkMode = false.obs; 
//tandeh se stiah
  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {//mokak shrd,ngalak data deri dark mode
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
      updateTheme();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', isDarkMode.value);
      updateTheme(); //abelik tema peteng terak,nympn se anyar/
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }

  void updateTheme() {
    if (isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.dark); //se agenteh tema
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }
}