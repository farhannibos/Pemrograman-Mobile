import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';
import 'services/theme_service.dart';
import 'services/hive_kajian_service.dart';
import 'models/kajian_hive_model.dart';
import 'controllers/kajian_hive_controller.dart';
import 'services/supabase_client.dart'; // Import Supabase client
import 'services/supabase_service.dart'; // Import Supabase service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KajianHiveModelAdapter());
  }
  
  try {
    // Initialize Supabase
    await SupabaseClientService.initialize();
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }
  
  // Initialize GetX services
  Get.put(ThemeService());
  
  final hiveService = HiveKajianService();
  await hiveService.init();
  Get.put(hiveService);
  
  Get.put(KajianHiveController()); // Register Hive Controller
  Get.put(SupabaseService()); // Register Supabase Service
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: 'Aplikasi Masjid',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeService.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    ));
  }
}