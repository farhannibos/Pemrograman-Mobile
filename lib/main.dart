import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter

import '/app/routes/app_pages.dart';
import '/app/services/theme_service.dart';
import '/app/data/models/event_model.dart'; // Import EventModel
import '/app/data/repositories/event_repository.dart'; // Import EventRepository

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- Inisialisasi Hive ---
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  // Daftarkan Hive Adapter untuk EventModel
  Hive.registerAdapter(EventModelAdapter()); // Pastikan EventModelAdapter() ada
  // --- Akhir Inisialisasi Hive ---

  // Inisialisasi ThemeService
  await Get.putAsync(() => ThemeService().init());
  // Inisialisasi EventRepository dan masukkan ke GetX dependency injection
  await Get.putAsync(() => EventRepository().init());
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    GetMaterialApp(
      title: "Aplikasi Masjid",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: Get.find<ThemeService>().themeMode,
      debugShowCheckedModeBanner: false,
    ),
  );
}