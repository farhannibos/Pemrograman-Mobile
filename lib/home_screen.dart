import 'package:flutter/material.dart';
import 'package:flutter_application_1/eksplisit.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> _prayerTimes = [];
  int? _selectedIndex;
  bool _isLoading = false;
  String? _selectedCity;
  String? _selectedCountry;
  
  // Performance tracking
  final List<Map<String, dynamic>> _performanceResults = [];
  String _selectedLibrary = 'http'; // 'http' atau 'dio'
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void initState() {
    super.initState();
    // Setup Dio Interceptor untuk logging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[DIO] $obj'),
    ));
    
    // Tampilkan modal lokasi saat app dimulai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationModal();
    });
  }

  // Fetch menggunakan HTTP package
  Future<void> _fetchPrayerTimesHTTP(String city, String country) async {
    setState(() {
      _isLoading = true;
    });

    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('[HTTP] Memulai request ke API...');
      final response = await http.get(
        Uri.parse(
          'http://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2',
        ),
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;
      
      debugPrint('[HTTP] Response diterima dalam ${responseTime}ms');
      debugPrint('[HTTP] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        setState(() {
          _prayerTimes = [
            {'name': 'Subuh', 'time': _formatTime(timings['Fajr'])},
            {'name': 'Dzuhur', 'time': _formatTime(timings['Dhuhr'])},
            {'name': 'Ashar', 'time': _formatTime(timings['Asr'])},
            {'name': 'Maghrib', 'time': _formatTime(timings['Maghrib'])},
            {'name': 'Isya', 'time': _formatTime(timings['Isha'])},
          ];
          _isLoading = false;
          
          // Simpan hasil performa
          _performanceResults.add({
            'library': 'HTTP',
            'responseTime': responseTime,
            'statusCode': response.statusCode,
            'success': true,
            'timestamp': DateTime.now(),
          });
        });
        
        debugPrint('[HTTP] Data berhasil diparse');
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
      debugPrint('[HTTP] Error: $e');
      
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
      debugPrint('[DIO] Memulai request ke API...');
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
      
      debugPrint('[DIO] Response diterima dalam ${responseTime}ms');

      if (response.statusCode == 200) {
        final timings = response.data['data']['timings'];

        setState(() {
          _prayerTimes = [
            {'name': 'Subuh', 'time': _formatTime(timings['Fajr'])},
            {'name': 'Dzuhur', 'time': _formatTime(timings['Dhuhr'])},
            {'name': 'Ashar', 'time': _formatTime(timings['Asr'])},
            {'name': 'Maghrib', 'time': _formatTime(timings['Maghrib'])},
            {'name': 'Isya', 'time': _formatTime(timings['Isha'])},
          ];
          _isLoading = false;
          
          // Simpan hasil performa
          _performanceResults.add({
            'library': 'DIO',
            'responseTime': responseTime,
            'statusCode': response.statusCode,
            'success': true,
            'timestamp': DateTime.now(),
          });
        });
        
        debugPrint('[DIO] Data berhasil diparse');
      }
    } on DioException catch (e) {
      stopwatch.stop();
      debugPrint('[DIO] DioException: ${e.type}');
      debugPrint('[DIO] Message: ${e.message}');
      debugPrint('[DIO] Response: ${e.response}');
      
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
        case DioExceptionType.cancel:
          errorMsg += 'Request dibatalkan';
          break;
        default:
          errorMsg += e.message ?? 'Unknown error';
      }
      _showErrorDialog(errorMsg);
    } catch (e) {
      stopwatch.stop();
      debugPrint('[DIO] Unexpected error: $e');
      
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
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('HTTP'),
                            value: 'http',
                            groupValue: _selectedLibrary,
                            onChanged: (value) {
                              setModalState(() {
                                _selectedLibrary = value!;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Dio'),
                            value: 'dio',
                            groupValue: _selectedLibrary,
                            onChanged: (value) {
                              setModalState(() {
                                _selectedLibrary = value!;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
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

                    Navigator.of(context).pop();
                    
                    // Pilih method berdasarkan library yang dipilih
                    if (_selectedLibrary == 'http') {
                      _fetchPrayerTimesHTTP(city, country);
                    } else {
                      _fetchPrayerTimesDio(city, country);
                    }
                  },
                  child: const Text('Dapatkan Jadwal Sholat'),
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
              onPressed: () {
                Navigator.of(context).pop();
                _showLocationModal();
              },
              child: const Text('Coba Lagi'),
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

    // Hitung rata-rata
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Masjid'),
        centerTitle: true,
        actions: [
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCity != null && _selectedCountry != null)
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Lokasi: $_selectedCity, $_selectedCountry',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.http, color: Colors.blue, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Library: ${_selectedLibrary.toUpperCase()}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    const Text(
                      'Jadwal Sholat:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    if (_prayerTimes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            'Belum ada jadwal sholat.\nSilakan pilih lokasi Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          double childAspectRatio;
                          if (screenWidth < 350) {
                            childAspectRatio = 0.9;
                          } else if (screenWidth < 600) {
                            childAspectRatio = 1.2;
                          } else {
                            childAspectRatio = 1.5;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180.0,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: _prayerTimes.length,
                            itemBuilder: (context, index) {
                              final bool isSelected = _selectedIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = isSelected ? null : index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.red : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _prayerTimes[index]['name']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _prayerTimes[index]['time']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected ? Colors.white : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KajianAnimationScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Lihat Animasi Kajian'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}