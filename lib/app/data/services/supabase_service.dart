// lib/app/data/services/supabase_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    // Memuat variabel lingkungan dari file .env
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }

    // Inisialisasi Supabase client
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );

    client = Supabase.instance.client;
    print("Supabase Initialized: ${client.auth.currentUser?.email ?? 'No user logged in'}");
    return this;
  }

  // Metode helper untuk mengakses client Supabase
  SupabaseClient get supabaseClient => client;

  // Anda bisa menambahkan helper lain di sini, misalnya untuk from() atau storage()
  // SupabaseQueryBuilder from(String table) => client.from(table);
  // SupabaseStorageClient get storage => client.storage;
}