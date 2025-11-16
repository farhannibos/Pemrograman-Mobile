// lib/app/modules/auth/views/register_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masjid_ku/app/modules/auth/controllers/auth_controller.dart';
// Tidak perlu import Routes di sini, bisa pakai Get.back()

class RegisterView extends GetView<AuthController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Admin')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Buat Akun Admin Baru', style: Get.textTheme.headlineSmall),
              const SizedBox(height: 40),
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.register(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Daftar', style: TextStyle(fontSize: 18)),
                  )),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.back(), // Kembali ke halaman login
                child: const Text('Sudah punya akun? Login'),
              ),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}