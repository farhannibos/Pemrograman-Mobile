import 'package:flutter/material.dart';
import 'package:flutter_application_1/detail_kajian_screen.dart';

class KajianAnimationScreen extends StatefulWidget {
  const KajianAnimationScreen({super.key});

  @override
  State<KajianAnimationScreen> createState() => _KajianAnimationScreenState();
}

class _KajianAnimationScreenState extends State<KajianAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late ScrollController _scrollController;

  // Data jadwal kajian untuk 7 hari
  final List<Map<String, dynamic>> _jadwalKajian = [
    {
      'hari': 'Senin',
      'judul': 'Kajian Subuh & Pemuda',
      'pemateri': 'Ustadz Farhan Fauzi',
      'lokasi': 'Masjid Al-Hikmah',
      'waktu': '04:30 - 06:00 & 16:00 - 17:30',
      'deskripsi': 'Kajian rutin pemuda masjid dengan pembahasan fiqih sehari-hari',
      'warna': Colors.blue,
    },
    {
      'hari': 'Selasa', 
      'judul': 'Kajian Muslimah',
      'pemateri': 'Ustadzah Bagaswati',
      'lokasi': 'Musholla An-Nur',
      'waktu': '09:00 - 11:00',
      'deskripsi': 'Kajian khusus muslimah tentang peran wanita dalam Islam',
      'warna': Colors.pink,
    },
    {
      'hari': 'Rabu',
      'judul': 'Tahsin Al-Quran',
      'pemateri': 'Ustadz Irfan',
      'lokasi': 'Masjid Agung',
      'waktu': '15:00 - 16:30',
      'deskripsi': 'Belajar memperbaiki bacaan Quran dengan tajwid yang benar',
      'warna': Colors.green,
    },
    {
      'hari': 'Kamis',
      'judul': 'Kajian Keluarga Sakinah',
      'pemateri': 'Ustadz Budi Raharjo',
      'lokasi': 'Aula Serbaguna',
      'waktu': '19:00 - 20:30',
      'deskripsi': 'Membangun keluarga harmonis menurut ajaran Islam',
      'warna': Colors.orange,
    },
    {
      'hari': 'Jumat',
      'judul': 'Khotib Jumat & Kajian Ba\'da Maghrib',
      'pemateri': 'Ustadz Abdul Malik',
      'lokasi': 'Masjid Jami',
      'waktu': '11:30 - 12:30 & 18:00 - 19:00',
      'deskripsi': 'Ceramah Jumat dan kajian singkat setelah maghrib',
      'warna': Colors.purple,
    },
    {
      'hari': 'Sabtu',
      'judul': 'Kajian Umum & Anak-anak',
      'pemateri': 'Tim Dai Muda',
      'lokasi': 'Halaman Masjid',
      'waktu': '08:00 - 10:00 & 16:00 - 17:00',
      'deskripsi': 'Kajian untuk semua usia dengan metode yang menyenangkan',
      'warna': Colors.teal,
    },
    {
      'hari': 'Minggu',
      'judul': 'Kajian Ahad Pagi',
      'pemateri': 'Ustadz Hasan Basri',
      'lokasi': 'Masjid Al-Ikhlas',
      'waktu': '07:00 - 09:00',
      'deskripsi': 'Kajian pekanan dengan tema-tema aktual seputar Islam',
      'warna': Colors.red,
    },
  ];

  // Track animasi per item
  final List<bool> _itemAnimated = List.generate(7, (index) => false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );


    _scrollController = ScrollController();
    
    // Listen to scroll events
    _scrollController.addListener(_onScroll);
    
    // Auto start animation untuk item pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStaggeredAnimation();
    });
  }

  void _onScroll() {
    // Trigger animasi saat scroll
    final scrollOffset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;
    
    for (int i = 0; i < _jadwalKajian.length; i++) {
      final shouldAnimate = scrollOffset > (i * 120) - screenHeight * 0.7;
      if (shouldAnimate && !_itemAnimated[i]) {
        setState(() {
          _itemAnimated[i] = true;
        });
      }
    }
  }

  void _startStaggeredAnimation() {
    // Reset semua animasi
    setState(() {
      for (int i = 0; i < _itemAnimated.length; i++) {
        _itemAnimated[i] = false;
      }
    });
    
    // Start animasi berurutan
    for (int i = 0; i < _jadwalKajian.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          setState(() {
            _itemAnimated[i] = true;
          });
        }
      });
    }
  }

  void _resetAnimation() {
    setState(() {
      for (int i = 0; i < _itemAnimated.length; i++) {
        _itemAnimated[i] = false;
      }
    });
  }

  void _loopAnimation() {
    _resetAnimation();
    Future.delayed(const Duration(milliseconds: 500), _startStaggeredAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildKajianCard(int index, BuildContext context) {
    final kajian = _jadwalKajian[index];
    final color = kajian['warna'] as Color;
    final heroTag = '${kajian['hari']}_hero';
    final isAnimated = _itemAnimated[index];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      opacity: isAnimated ? 1.0 : 0.0,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        padding: EdgeInsets.only(
          top: isAnimated ? 0.0 : 20.0,
          bottom: isAnimated ? 0.0 : 20.0,
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          scale: isAnimated ? 1.0 : 0.7,
          child: GestureDetector(
            onTap: () {
              _navigateToDetail(context, kajian, heroTag);
            },
            child: Hero(
              tag: heroTag,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.9),
                        color.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      // Circle dengan huruf hari
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            kajian['hari'].toString().substring(0, 1),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Informasi kajian
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kajian['hari'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kajian['judul'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kajian['pemateri'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.white60),
                                const SizedBox(width: 4),
                                Text(
                                  kajian['waktu'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Icon arrow dengan animasi
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isAnimated ? 0.0 : 0.25,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> kajian, String heroTag) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailKajianScreen(
              kajianData: kajian,
              heroTag: heroTag,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kajian Mingguan'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                children: [
                  Text(
                    'Jadwal Kajian 7 Hari',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scroll untuk melihat animasi!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Konten utama dengan animasi
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _jadwalKajian.length,
                itemBuilder: (context, index) {
                  return _buildKajianCard(index, context);
                },
              ),
            ),
            
            // Control buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startStaggeredAnimation,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai Animasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _resetAnimation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loopAnimation,
                    icon: const Icon(Icons.loop),
                    label: const Text('Loop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}