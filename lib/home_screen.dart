import 'package:flutter/material.dart';
import 'package:flutter_application_1/eksplisit.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'services/theme_service.dart';
import 'services/hive_kajian_service.dart';
import 'models/kajian_hive_model.dart';
import 'controllers/kajian_hive_controller.dart';
import 'models/prayer_time_model.dart';
import 'services/supabase_service.dart'; 
import 'auth_screen.dart'; // Import AuthScreen// Import Supabase service

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<PrayerTime> _prayerTimes = [];
  int? _selectedIndex;
  bool _isLoading = false;
  String? _selectedCity;
  String? _selectedCountry;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  // Performance tracking
  final List<Map<String, dynamic>> _performanceResults = [];
  String _selectedLibrary = 'http';
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Setup Dio Interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[DIO] $obj'),
    ));
    
    // Load saved location
    _loadSavedLocation();
    
    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ===== SUPABASE METHODS =====
  void _showSupabaseDialog() {
    final supabase = Get.find<SupabaseService>();
    final kajianController = Get.find<KajianHiveController>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloud Storage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${supabase.currentUser?.email ?? "Not logged in"}'),
            const SizedBox(height: 8),
            Text('Status: ${supabase.isLoggedIn ? "Terhubung" : "Offline"}'),
            const SizedBox(height: 8),
            Text('Local Kajian: ${kajianController.kajianList.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (supabase.isLoggedIn) ...[
            TextButton(
              onPressed: () {
                _syncToCloud(kajianController.kajianList);
                Navigator.pop(context);
              },
              child: const Text('Sync ke Cloud'),
            ),
            TextButton(
              onPressed: () {
                _importFromCloud();
                Navigator.pop(context);
              },
              child: const Text('Import dari Cloud'),
            ),
            TextButton(
              onPressed: () {
                supabase.signOut();
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ] else ...[
            TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog dulu
              Get.to(() => const AuthScreen()); // Buka auth screen
            },
            child: const Text('Login/Daftar'),
          ),
        ],
      ],
    ),
  );
}

  

  Future<void> _syncToCloud(List<KajianHiveModel> kajianList) async {
    try {
      final supabase = Get.find<SupabaseService>();
      await supabase.syncKajianToCloud(kajianList);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${kajianList.length} kajian tersinkronisasi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Sync gagal: $e')),
      );
    }
  }

  Future<void> _importFromCloud() async {
    try {
      final supabase = Get.find<SupabaseService>();
      final kajianController = Get.find<KajianHiveController>();
      
      final cloudKajian = await supabase.getKajianFromCloud();
      
      for (final kajian in cloudKajian) {
        // Cek duplikat
        final exists = kajianController.kajianList.any((k) => k.id == kajian.id);
        if (!exists) {
          await kajianController.addKajian(kajian);
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${cloudKajian.length} kajian diimport')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Import gagal: $e')),
      );
    }
  }
Future<void> _testPerformance() async {
  final stopwatch = Stopwatch();
  
  // Test Hive Write
  stopwatch.start();
  final hiveService = Get.find<HiveKajianService>();
  for (int i = 0; i < 10; i++) {
    await hiveService.addKajian(KajianHiveModel(
      id: 'test_$i',
      title: 'Test Kajian $i',
      description: 'Deskripsi test',
      date: DateTime.now(),
      pemateri: 'Test Ustadz',
      lokasi: 'Test Masjid',
    ));
  }
  stopwatch.stop();
  final hiveWriteTime = stopwatch.elapsedMilliseconds;
  
  // Test Supabase Write
  stopwatch.reset();
  stopwatch.start();
  final supabase = Get.find<SupabaseService>();
  if (supabase.isLoggedIn) {
    final testData = List.generate(5, (i) => KajianHiveModel(
      id: 'cloud_test_$i',
      title: 'Cloud Test $i',
      description: 'Cloud description',
      date: DateTime.now(),
      pemateri: 'Cloud Ustadz',
      lokasi: 'Cloud Masjid',
    ));
    await supabase.syncKajianToCloud(testData);
  }
  stopwatch.stop();
  final supabaseWriteTime = stopwatch.elapsedMilliseconds;
  
  // Show results
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Performance Test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hive Write (10 items): ${hiveWriteTime}ms'),
          Text('Supabase Write (5 items): ${supabaseWriteTime}ms'),
        ],
      ),
    ),
  );
}

void _testOfflineMode() {
  final supabase = Get.find<SupabaseService>();
  final kajianController = Get.find<KajianHiveController>();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Offline Mode Test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Hive (Local)'),
            subtitle: Text('${kajianController.kajianList.length} kajian tersimpan'),
          ),
          ListTile(
            leading: Icon(
              supabase.isLoggedIn ? Icons.cloud_done : Icons.cloud_off,
              color: supabase.isLoggedIn ? Colors.green : Colors.grey,
            ),
            title: const Text('Supabase (Cloud)'),
            subtitle: Text(supabase.isLoggedIn ? 'Terhubung' : 'Offline'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Matikan internet untuk test:\n- Hive tetap bisa CRUD\n- Supabase akan error',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
Widget _buildSupabaseSection() {
  final supabase = Get.find<SupabaseService>();
  final kajianController = Get.find<KajianHiveController>();
  
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_sync,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cloud Storage (Supabase)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Status Login
          Row(
            children: [
              Icon(
                supabase.isLoggedIn ? Icons.check_circle : Icons.cancel,
                color: supabase.isLoggedIn ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                supabase.isLoggedIn 
                  ? 'Terhubung: ${supabase.currentUser?.email ?? "No email"}'
                  : 'Belum login',
                style: TextStyle(
                  color: supabase.isLoggedIn ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Info Local vs Cloud
          Text('Local: ${kajianController.kajianList.length} kajian'),
          const SizedBox(height: 16),
          
          // Tombol Aksi
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showSupabaseDialog,
                  icon: const Icon(Icons.cloud),
                  label: const Text('Kelola Cloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (supabase.isLoggedIn) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _syncToCloud(kajianController.kajianList),
                    icon: const Icon(Icons.upload),
                    label: const Text('Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const AuthScreen());
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Login/Daftar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
  // ===== EXISTING METHODS =====
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedCity = prefs.getString('saved_city');
        _selectedCountry = prefs.getString('saved_country');
        _selectedLibrary = prefs.getString('saved_library') ?? 'http';
      });
      
      if (_selectedCity != null && _selectedCountry != null) {
        if (_selectedLibrary == 'http') {
          _fetchPrayerTimesHTTP(_selectedCity!, _selectedCountry!);
        } else {
          _fetchPrayerTimesDio(_selectedCity!, _selectedCountry!);
        }
      } else {
        _showLocationModal();
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  Future<void> _saveLocation(String city, String country, String library) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_city', city);
      await prefs.setString('saved_country', country);
      await prefs.setString('saved_library', library);
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  // Fetch menggunakan HTTP package
  Future<void> _fetchPrayerTimesHTTP(String city, String country) async {
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2',
        ),
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        setState(() {
          _prayerTimes = [
            PrayerTime(name: 'Subuh', time: _formatTime(timings['Fajr']), icon: Icons.nightlight_round),
            PrayerTime(name: 'Dzuhur', time: _formatTime(timings['Dhuhr']), icon: Icons.wb_sunny),
            PrayerTime(name: 'Ashar', time: _formatTime(timings['Asr']), icon: Icons.brightness_medium),
            PrayerTime(name: 'Maghrib', time: _formatTime(timings['Maghrib']), icon: Icons.brightness_low),
            PrayerTime(name: 'Isya', time: _formatTime(timings['Isha']), icon: Icons.dark_mode),
          ];
          _isLoading = false;
          
          _performanceResults.add({
            'library': 'HTTP',
            'responseTime': responseTime,
            'statusCode': response.statusCode,
            'success': true,
            'timestamp': DateTime.now(),
          });
        });
      } else {
        setState(() {
          _isLoading = false;
          _performanceResults.add({
            'library': 'HTTP',
            'responseTime': responseTime,
            'statusCode': response.statusCode,
            'success': false,
            'error': 'Status code ${response.statusCode}',
            'timestamp': DateTime.now(),
          });
        });
        _showErrorDialog('Gagal mengambil jadwal sholat. Status: ${response.statusCode}');
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isLoading = false;
        _performanceResults.add({
          'library': 'HTTP',
          'responseTime': stopwatch.elapsedMilliseconds,
          'success': false,
          'error': e.toString(),
          'timestamp': DateTime.now(),
        });
      });
      _showErrorDialog('Terjadi kesalahan HTTP: $e');
    }
  }

  // Fetch menggunakan Dio package
  Future<void> _fetchPrayerTimesDio(String city, String country) async {
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _dio.get(
        'http://api.aladhan.com/v1/timingsByCity',
        queryParameters: {
          'city': city,
          'country': country,
          'method': '2',
        },
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      if (response.statusCode == 200) {
        final timings = response.data['data']['timings'];

        setState(() {
          _prayerTimes = [
            PrayerTime(name: 'Subuh', time: _formatTime(timings['Fajr']), icon: Icons.nightlight_round),
            PrayerTime(name: 'Dzuhur', time: _formatTime(timings['Dhuhr']), icon: Icons.wb_sunny),
            PrayerTime(name: 'Ashar', time: _formatTime(timings['Asr']), icon: Icons.brightness_medium),
            PrayerTime(name: 'Maghrib', time: _formatTime(timings['Maghrib']), icon: Icons.brightness_low),
            PrayerTime(name: 'Isya', time: _formatTime(timings['Isha']), icon: Icons.dark_mode),
          ];
          _isLoading = false;
          
          _performanceResults.add({
            'library': 'DIO',
            'responseTime': responseTime,
            'statusCode': response.statusCode,
            'success': true,
            'timestamp': DateTime.now(),
          });
        });
      }
    } on DioException catch (e) {
      stopwatch.stop();
      setState(() {
        _isLoading = false;
        _performanceResults.add({
          'library': 'DIO',
          'responseTime': stopwatch.elapsedMilliseconds,
          'success': false,
          'error': '${e.type}: ${e.message}',
          'timestamp': DateTime.now(),
        });
      });
      
      String errorMsg = 'Terjadi kesalahan Dio: ';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg += 'Koneksi timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMsg += 'Timeout saat mengirim request';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg += 'Timeout saat menerima response';
          break;
        case DioExceptionType.badResponse:
          errorMsg += 'Response error (${e.response?.statusCode})';
          break;
        default:
          errorMsg += e.message ?? 'Unknown error';
      }
      _showErrorDialog(errorMsg);
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isLoading = false;
        _performanceResults.add({
          'library': 'DIO',
          'responseTime': stopwatch.elapsedMilliseconds,
          'success': false,
          'error': e.toString(),
          'timestamp': DateTime.now(),
        });
      });
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  String _formatTime(String time) {
    final cleanTime = time.split(' ')[0];
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    return '$hour:$minute';
  }

  void _showLocationModal() {
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    if (_selectedCity != null) cityController.text = _selectedCity!;
    if (_selectedCountry != null) countryController.text = _selectedCountry!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Pilih Lokasi Anda'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Masukkan kota dan negara Anda untuk mendapatkan jadwal sholat yang akurat:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'Kota',
                        hintText: 'contoh: Jakarta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                        labelText: 'Negara',
                        hintText: 'contoh: Indonesia',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.public),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pilih Library HTTP:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Perbaikan RadioListTile - gunakan Radio.adaptive
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('HTTP'),
                          value: 'http',
                          groupValue: _selectedLibrary,
                          onChanged: (value) {
                            setModalState(() {
                              _selectedLibrary = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Dio'),
                          value: 'dio',
                          groupValue: _selectedLibrary,
                          onChanged: (value) {
                            setModalState(() {
                              _selectedLibrary = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    final city = cityController.text.trim();
                    final country = countryController.text.trim();

                    if (city.isEmpty || country.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mohon masukkan kota dan negara'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _selectedCity = city;
                      _selectedCountry = country;
                    });

                    _saveLocation(city, country, _selectedLibrary);
                    Navigator.of(context).pop();
                    
                    if (_selectedLibrary == 'http') {
                      _fetchPrayerTimesHTTP(city, country);
                    } else {
                      _fetchPrayerTimesDio(city, country);
                    }
                  },
                  child: const Text('Simpan & Dapatkan Jadwal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kesalahan'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPerformanceResults() {
    if (_performanceResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada data performa')),
      );
      return;
    }

    final httpResults = _performanceResults.where((r) => r['library'] == 'HTTP').toList();
    final dioResults = _performanceResults.where((r) => r['library'] == 'DIO').toList();
    
    final httpAvg = httpResults.isEmpty ? 0 : 
        httpResults.map((r) => r['responseTime'] as int).reduce((a, b) => a + b) / httpResults.length;
    final dioAvg = dioResults.isEmpty ? 0 :
        dioResults.map((r) => r['responseTime'] as int).reduce((a, b) => a + b) / dioResults.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Performa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Statistik:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text('Total Percobaan HTTP: ${httpResults.length}'),
              Text('Rata-rata Response Time HTTP: ${httpAvg.toStringAsFixed(2)} ms'),
              const SizedBox(height: 10),
              Text('Total Percobaan Dio: ${dioResults.length}'),
              Text('Rata-rata Response Time Dio: ${dioAvg.toStringAsFixed(2)} ms'),
              const Divider(height: 30),
              const Text('Riwayat Request:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._performanceResults.reversed.take(10).map((result) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${result['library']} - ${result['success'] ? '✓ Berhasil' : '✗ Gagal'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: result['success'] ? Colors.green : Colors.red,
                          ),
                        ),
                        Text('Response Time: ${result['responseTime']} ms'),
                        if (result['statusCode'] != null)
                          Text('Status Code: ${result['statusCode']}'),
                        if (result['error'] != null)
                          Text('Error: ${result['error']}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    final themeService = Get.find<ThemeService>();
    themeService.toggleTheme();
  }

  void _testHive() async {
    final hiveService = Get.find<HiveKajianService>();
    
    final sampleKajian = KajianHiveModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Kajian Test Hive',
      description: 'Ini adalah data test untuk Hive',
      date: DateTime.now(),
      pemateri: 'Ustadz Test',
      lokasi: 'Masjid Test',
    );
    
    await hiveService.addKajian(sampleKajian);
    
    final allKajian = hiveService.getAllKajian();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Hive berhasil! ${allKajian.length} kajian tersimpan'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ===== WIDGET BUILDERS =====

  Widget _buildLocationCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_selectedCity, $_selectedCountry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.http, size: 14, color: Colors.blue.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Library: ${_selectedLibrary.toUpperCase()}',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue.shade600),
                      onPressed: _showLocationModal,
                      tooltip: 'Ubah Lokasi',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimeGrid() {
    final blueShade800 = Colors.blue[800]; // Perbaikan untuk const error
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.7),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Sholat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: blueShade800,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _prayerTimes.length,
                  itemBuilder: (context, index) {
                    final prayer = _prayerTimes[index];
                    final isSelected = _selectedIndex == index;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Card(
                        elevation: isSelected ? 8 : 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: isSelected ? Colors.blue.shade500 : Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _selectedIndex = isSelected ? null : index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  prayer.icon,
                                  size: 32,
                                  color: isSelected ? Colors.white : Colors.blue.shade500,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  prayer.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prayer.time,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKajianSection() {
    final blueShade800 = Colors.blue[800]; // Perbaikan untuk const error
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Kajian',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: blueShade800,
                      ),
                    ),
                    Obx(() {
                      final kajianController = Get.find<KajianHiveController>();
                      return Chip(
                        label: Text(
                          '${kajianController.getTotalKajian()} kajian',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blue.shade500,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final kajianController = Get.find<KajianHiveController>();
                  
                  if (kajianController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final kajianList = kajianController.kajianList;

                  if (kajianList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.storage, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada kajian tersimpan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Data kajian akan disimpan secara lokal di device Anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: kajianList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final kajian = entry.value;
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue.shade500, Colors.blue.shade300],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.menu_book, color: Colors.white),
                            ),
                            title: Text(
                              kajian.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                _buildInfoRow(Icons.person, kajian.pemateri),
                                _buildInfoRow(Icons.location_on, kajian.lokasi),
                                _buildInfoRow(Icons.access_time, kajian.formattedDate),
                                if (kajian.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    kajian.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.storage, size: 12, color: Colors.green.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tersimpan di Hive',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 80,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20, color: Colors.orange.shade600),
                                    onPressed: () => _showEditKajianHiveDialog(kajian),
                                    tooltip: 'Edit Kajian',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 20, color: Colors.red.shade600),
                                    onPressed: () => _showDeleteKajianHiveConfirmation(kajian.id, kajian.title),
                                    tooltip: 'Hapus Kajian',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(), // Perbaikan: hapus .toList() yang tidak perlu
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddKajianHiveDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Kajian Baru'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() {
                      final kajianController = Get.find<KajianHiveController>();
                      return IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: kajianController.isLoading.value 
                            ? null 
                            : () => kajianController.loadKajianFromHive(),
                        tooltip: 'Refresh Data',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.all(12),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationButton() {
    final blueShade800 = Colors.blue[800]; // Perbaikan untuk const error
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Jadwal Kajian Mingguan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: blueShade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KajianAnimationScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.animation),
                            SizedBox(width: 8),
                            Text(
                              'Lihat Animasi Kajian',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildExperimentSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Modul 4 - Experiments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _testPerformance,
                  child: const Text('Test Performance'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _testOfflineMode,
                  child: const Text('Test Offline'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Masjid'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
    actions: [
  IconButton(
    icon: const Icon(Icons.cloud), // ← ICON TETAP
    onPressed: _showSupabaseDialog,
    tooltip: 'Cloud Storage',
  ),
  IconButton(
    icon: const Icon(Icons.storage),
    onPressed: _testHive,
    tooltip: 'Test Hive',
  ),
  IconButton(
    icon: const Icon(Icons.brightness_6), // ← ICON TETAP
    onPressed: _toggleTheme,
    tooltip: 'Toggle Theme',
  ),
  IconButton(
    icon: const Icon(Icons.speed),
    onPressed: _showPerformanceResults,
    tooltip: 'Lihat Hasil Performa',
  ),
  IconButton(
    icon: const Icon(Icons.location_on),
    onPressed: _showLocationModal,
    tooltip: 'Ubah Lokasi',
  ),
],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Memuat jadwal sholat...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedCity != null && _selectedCountry != null) _buildLocationCard(),
                  const SizedBox(height: 24),
                    _buildSupabaseSection(),
            const SizedBox(height: 16),
                  if (_prayerTimes.isNotEmpty) _buildPrayerTimeGrid(),
                  if (_prayerTimes.isEmpty && !_isLoading) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada jadwal sholat',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _showLocationModal,
                            child: const Text('Pilih Lokasi'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _buildKajianSection(),
                  const SizedBox(height: 24),
                  _buildAnimationButton(),
                  const SizedBox(height: 16),
                  _buildExperimentSection(),
                  const SizedBox(height: 16),
                  
                  
                ],
              ),
            ),
    );
  }

  // ===== DIALOG METHODS (tetap sama seperti sebelumnya, tapi perbaiki BuildContext issues) =====
  
  void _showAddKajianHiveDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final pemateriController = TextEditingController();
    final lokasiController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Tambah Kajian Baru'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Kajian *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pemateriController,
                      decoration: const InputDecoration(
                        labelText: 'Pemateri *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lokasiController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal & Waktu Kajian',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today, color: Colors.blue),
                            title: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                            ),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null && mounted) {
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                                );
                                if (time != null && mounted) {
                                  setState(() {
                                    selectedDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '* Wajib diisi',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || 
                        pemateriController.text.isEmpty || 
                        lokasiController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul, pemateri, dan lokasi wajib diisi'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final hiveService = Get.find<HiveKajianService>();
                    final newKajian = KajianHiveModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      description: descriptionController.text,
                      date: selectedDate,
                      pemateri: pemateriController.text,
                      lokasi: lokasiController.text,
                    );

                    hiveService.addKajian(newKajian);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ "${titleController.text}" berhasil disimpan di Hive'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                  ),
                  child: const Text('Simpan ke Hive'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditKajianHiveDialog(KajianHiveModel kajian) {
    final titleController = TextEditingController(text: kajian.title);
    final descriptionController = TextEditingController(text: kajian.description);
    final pemateriController = TextEditingController(text: kajian.pemateri);
    final lokasiController = TextEditingController(text: kajian.lokasi);
    DateTime selectedDate = kajian.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Edit Kajian'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Kajian *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pemateriController,
                      decoration: const InputDecoration(
                        labelText: 'Pemateri *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lokasiController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal & Waktu Kajian',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today, color: Colors.blue),
                            title: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                            ),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null && mounted) {
                                final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(selectedDate),
                                );
                                if (time != null && mounted) {
                                  setState(() {
                                    selectedDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty || 
                        pemateriController.text.isEmpty || 
                        lokasiController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul, pemateri, dan lokasi wajib diisi'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final hiveService = Get.find<HiveKajianService>();
                    final updatedKajian = KajianHiveModel(
                      id: kajian.id,
                      title: titleController.text,
                      description: descriptionController.text,
                      date: selectedDate,
                      pemateri: pemateriController.text,
                      lokasi: lokasiController.text,
                    );

                    hiveService.updateKajian(updatedKajian);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ "${titleController.text}" berhasil diupdate di Hive'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                  ),
                  child: const Text('Update di Hive'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteKajianHiveConfirmation(String id, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Kajian'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yakin ingin menghapus "$title"?'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Data akan dihapus permanen dari penyimpanan lokal',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final hiveService = Get.find<HiveKajianService>();
                hiveService.deleteKajian(id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ "$title" berhasil dihapus dari Hive'),
                    backgroundColor: Colors.orange.shade600,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}