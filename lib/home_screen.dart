import 'package:flutter/material.dart';
import 'package:flutter_application_1/eksplisit.dart'; // Import halaman animasi

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _prayerTimes = [
    {'name': 'Shubuh', 'time': '04:30 AM'},
    {'name': 'Dzuhur', 'time': '12:00 PM'},
    {'name': 'Ashar', 'time': '03:15 PM'},
    {'name': 'Maghrib', 'time': '06:00 PM'},
    {'name': 'Isya', 'time': '07:15 PM'},
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Menggunakan MediaQuery untuk mendapatkan lebar layar saat ini
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Masjid'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jadwal Sholat (AnimatedContainer Implisit & Responsif Grid):',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Menyesuaikan childAspectRatio berdasarkan lebar layar
                  double childAspectRatio;
                  if (screenWidth < 350) {
                    // Layar sangat kecil (misal, ponsel sangat sempit), buat item lebih tinggi
                    childAspectRatio = 0.9;
                  } else if (screenWidth < 600) {
                    // Layar ponsel standar, rasio default yang sedikit lebih tinggi dari lebar
                    childAspectRatio = 1.2;
                  } else {
                    // Layar lebih lebar (misal, tablet atau desktop), buat item lebih lebar relatif terhadap tingginya
                    childAspectRatio = 1.5;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      // >>>>>> PERUBAHAN DI SINI: MENYESUAIKAN childAspectRatio dengan MediaQuery<<<<<<
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