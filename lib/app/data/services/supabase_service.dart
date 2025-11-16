// lib/app/data/services/supabase_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    print("SupabaseService: --- Starting init() process ---");
    try {
      print("SupabaseService: Loading .env file...");
      await dotenv.load(fileName: ".env");
      print("SupabaseService: .env loaded.");

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      print("SupabaseService: SUPABASE_URL from .env: ${supabaseUrl?.isNotEmpty == true ? 'Loaded' : 'NOT FOUND'}");
      print("SupabaseService: SUPABASE_ANON_KEY from .env: ${supabaseAnonKey?.isNotEmpty == true ? 'Loaded' : 'NOT FOUND'}");

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        throw Exception('SUPABASE_URL not found or empty in .env file');
      }
      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        throw Exception('SUPABASE_ANON_KEY not found or empty in .env file');
      }

      print("SupabaseService: Initializing Supabase client...");
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Keep debug true for now
      );

      client = Supabase.instance.client;
      print("SupabaseService: Supabase Client Initialized Successfully!");
      print("SupabaseService: User: ${client.auth.currentUser?.email ?? 'No user logged in'}");
      
      print("SupabaseService: --- Init() completed successfully ---");
      return this;
    } catch (e, stackTrace) {
      print("SupabaseService: FATAL ERROR during init(): $e");
      print("SupabaseService: Stack Trace: $stackTrace");
      rethrow; // Re-throw the error to ensure GetX knows about the failure
    }
  }

  SupabaseClient get supabaseClient => client;
  SupabaseQueryBuilder from(String table) => client.from(table);
  SupabaseStorageClient get storage => client.storage;

    GoTrueClient get auth => client.auth;

  @override
  void onClose() {
    print("SupabaseService: onClose() called.");
    // Supabase client secara otomatis dielola, tidak perlu manual dispose di sini
    super.onClose();
  }
}