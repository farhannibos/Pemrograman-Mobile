// lib/app/modules/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:masjid_ku/app/modules/auth/providers/auth_provider.dart';
import 'package:masjid_ku/app/routes/app_routes.dart'; // Untuk navigasi

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Text editing controllers untuk form
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable untuk state autentikasi
  final Rx<User?> user = Rx<User?>(null);
  bool get isAuthenticated => user.value != null;

  @override
  void onInit() {
    super.onInit();
    // Mendengarkan perubahan state autentikasi dari Supabase
    _authProvider.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print("Auth Event: $event");
      if (session != null) {
        user.value = session.user;
        print("User logged in: ${user.value?.email}");
        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
          // Setelah login sukses, arahkan ke halaman Home
          // Gunakan Future.microtask untuk menunda navigasi sampai setelah build selesai
          Future.microtask(() => Get.offAllNamed(Routes.HOME));
        }
      } else {
        user.value = null;
        print("User logged out or session expired.");
        if (event == AuthChangeEvent.signedOut) {
          // Setelah logout, arahkan ke halaman Login
          // Gunakan Future.delayed untuk memastikan semua operasi selesai
          Future.delayed(const Duration(milliseconds: 200), () {
            if (Get.currentRoute != Routes.LOGIN) {
              Get.offAllNamed(Routes.LOGIN);
            }
          });
        }
      }
    });

    // Cek sesi awal - tunda navigasi sampai setelah build selesai
    user.value = _authProvider.currentUser;
    Future.microtask(() {
      if (user.value != null) {
        Get.offAllNamed(Routes.HOME);
      } else {
        // Jangan navigasi ke LOGIN jika sudah di halaman LOGIN
        if (Get.currentRoute != Routes.LOGIN) {
          Get.offAllNamed(Routes.LOGIN);
        }
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // --- Metode untuk Login ---
  Future<void> login() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final AuthResponse response = await _authProvider.signInWithEmail(
        emailController.text,
        passwordController.text,
      );
      if (response.user != null) {
        Get.snackbar('Login Sukses', 'Selamat datang, ${response.user!.email}',
            backgroundColor: Colors.green, colorText: Colors.white);
        // Navigasi ke Home akan ditangani oleh listener onAuthStateChange
      } else {
        errorMessage.value = 'Login gagal, periksa kredensial Anda.';
        Get.snackbar('Login Gagal', errorMessage.value,
            backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Login Gagal', e.message,
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Login Error (AuthException): ${e.message}");
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tidak dikenal: $e';
      Get.snackbar('Login Gagal', errorMessage.value,
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Login Error (General): $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Metode untuk Register ---
  Future<void> register() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final AuthResponse response = await _authProvider.signUpWithEmail(
        emailController.text,
        passwordController.text,
      );
      if (response.user != null) {
        Get.snackbar('Registrasi Sukses', 'Akun berhasil dibuat. Silakan cek email Anda untuk verifikasi.',
            backgroundColor: Colors.green, colorText: Colors.white);
        // Setelah registrasi, bisa arahkan ke halaman login
        Get.offAllNamed(Routes.LOGIN);
      } else {
        errorMessage.value = 'Registrasi gagal, coba lagi.';
        Get.snackbar('Registrasi Gagal', errorMessage.value,
            backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar('Registrasi Gagal', e.message,
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Register Error (AuthException): ${e.message}");
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tidak dikenal: $e';
      Get.snackbar('Registrasi Gagal', errorMessage.value,
          backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
      print("Register Error (General): $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Metode untuk Logout ---
  Future<void> logout() async {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Anda yakin ingin logout?",
      textConfirm: "Ya",
      textCancel: "Tidak",
      confirmTextColor: Colors.white,
      barrierDismissible: true, // Bisa ditutup dengan klik di luar dialog
      onConfirm: () async {
        Get.back(); // Tutup dialog terlebih dahulu
        // Tunggu sedikit untuk memastikan dialog tertutup
        await Future.delayed(const Duration(milliseconds: 100));
        try {
          await _authProvider.signOut();
          // Navigasi ke Login akan ditangani oleh listener onAuthStateChange
          // Tidak perlu snackbar karena akan langsung navigasi
        } catch (e) {
          Get.snackbar('Logout Gagal', 'Terjadi kesalahan saat logout: $e',
              backgroundColor: Get.theme.colorScheme.error, colorText: Colors.white);
          print("Logout Error: $e");
        }
      },
      onCancel: () {
        // User membatalkan, tidak perlu melakukan apa-apa
      },
    );
  }
}