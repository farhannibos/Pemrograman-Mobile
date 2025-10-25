import 'package:flutter/material.dart';

class DetailKajianScreen extends StatelessWidget {
  // Tambahkan heroTag di konstruktor
  final String heroTag;

  const DetailKajianScreen({super.key, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kajian'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bungkus Container dengan Hero widget
            Hero(
              tag: heroTag, // Tag harus sama dengan halaman asal
              child: Container(
                width: 300, // Ukuran yang lebih besar di halaman detail
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.deepPurple, // Warna berbeda untuk visualisasi
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 7,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'ust. Alex',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }
}