// lib/app/modules/auth/providers/auth_provider.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart';

class AuthProvider extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Getter untuk mengakses client autentikasi Supabase
  GoTrueClient get _authClient => _supabaseService.auth;

  // Mendapatkan user yang sedang login
  User? get currentUser => _authClient.currentUser;

  // Mendapatkan stream perubahan state autentikasi (login/logout)
  Stream<AuthState> get authStateChanges => _authClient.onAuthStateChange;

  // Metode untuk login
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _authClient.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Metode untuk register
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _authClient.signUp(
      email: email,
      password: password,
      // Anda bisa menambahkan data user_metadata di sini jika perlu
      // data: {'full_name': 'Your Name'},
    );
  }

  // Metode untuk logout
  Future<void> signOut() async {
    await _authClient.signOut();
  }

  // Cek apakah user sudah login
  bool get isAuthenticated => currentUser != null;
}