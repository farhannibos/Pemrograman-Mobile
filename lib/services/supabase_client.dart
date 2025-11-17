import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://wvimqukgqzzamzdenlpp.supabase.co', // Ganti dengan URL Anda
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2aW1xdWtncXp6YW16ZGVubHBwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMDI3OTUsImV4cCI6MjA3ODg3ODc5NX0.nE_htBNnjaPfwhBwXmovNyZ38nQ4eURiiBzY0O1EDfY', // Ganti dengan anon key Anda
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}