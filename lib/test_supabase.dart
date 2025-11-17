import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

class TestSupabaseScreen extends StatefulWidget {
  const TestSupabaseScreen({super.key});

  @override
  State<TestSupabaseScreen> createState() => _TestSupabaseScreenState();
}

class _TestSupabaseScreenState extends State<TestSupabaseScreen> {
  final SupabaseService _supabase = SupabaseService();
  String _status = 'Checking...';

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  void _testConnection() async {
    try {
      final user = _supabase.currentUser;
      setState(() {
        _status = 'Connected! User: ${user?.email ?? "Not logged in"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Supabase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}