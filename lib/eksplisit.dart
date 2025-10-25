import 'package:flutter/material.dart';
import 'package:flutter_application_1/detail_kajian_screen.dart'; // Import halaman detail

class KajianAnimationScreen extends StatefulWidget {
  const KajianAnimationScreen({super.key});

  @override
  State<KajianAnimationScreen> createState() => _KajianAnimationScreenState();
}

class _KajianAnimationScreenState extends State<KajianAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;

  static const String _heroKajianTag = 'kajianBox';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: 100.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.red).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animasi Eksplisit Kajian'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Kotak Kajian Animasi Eksplisit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  // >>>>>> PERUBAHAN DI SINI: MENGGUNAKAN PageRouteBuilder <<<<<<
                  PageRouteBuilder(
                    transitionDuration: const Duration(seconds: 2), // Durasi transisi diperlambat
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const DetailKajianScreen(heroTag: _heroKajianTag),
                    // Kita bisa menambahkan transisi kustom di sini,
                    // tapi untuk Hero Animation, kita hanya perlu mengatur durasi.
                    // Jika ingin transisi halaman non-Hero kustom juga, bisa ditambahkan di 'transitionsBuilder'.
                    // Misalnya:
                    // transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    //   return FadeTransition(opacity: animation, child: child);
                    // },
                  ),
                );
              },
              child: Hero(
                tag: _heroKajianTag,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: _sizeAnimation.value,
                      height: _sizeAnimation.value,
                      decoration: BoxDecoration(
                        color: _colorAnimation.value,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Khotib jumat',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.forward();
                  },
                  child: const Text('Mulai'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.stop();
                  },
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.reset();
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.repeat(reverse: true);
                  },
                  child: const Text('Ulangi'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _controller.reverse();
              },
              child: const Text('Reverse'),
            ),
          ],
        ),
      ),
    );
  }
}