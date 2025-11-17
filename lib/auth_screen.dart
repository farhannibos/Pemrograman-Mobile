import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  bool _isLogin = true; // true = login, false = register

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final supabase = Get.find<SupabaseService>();
      
      if (_isLogin) {
        // LOGIN
        await supabase.signIn(_emailController.text, _passwordController.text);
        Get.back(); // Kembali ke home screen
        Get.snackbar('Berhasil', 'Login berhasil!', 
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // REGISTER  
        await supabase.signUp(_emailController.text, _passwordController.text);
        Get.snackbar('Berhasil', 'Registrasi berhasil! Silakan login.',
          backgroundColor: Colors.green, colorText: Colors.white);
        setState(() => _isLogin = true); // Switch ke login setelah register
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud,
                              size: 80,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isLogin ? 'Login ke Cloud' : 'Daftar Akun Baru',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLogin 
                                ? 'Masuk untuk sync data kajian'
                                : 'Buat akun untuk menyimpan data di cloud',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Form
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email harus diisi';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password harus diisi';
                                  }
                                  if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                              
                              // Confirm Password (hanya untuk register)
                              if (!_isLogin) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Konfirmasi Password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(),
                                  ),
                                  obscureText: true,
                                  validator: !_isLogin ? (value) {
                                    if (value != _passwordController.text) {
                                      return 'Password tidak cocok';
                                    }
                                    return null;
                                  } : null,
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: _isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : ElevatedButton(
                                        onPressed: _submitAuth,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          _isLogin ? 'LOGIN' : 'DAFTAR',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Switch Auth Mode
                              TextButton(
                                onPressed: _isLoading ? null : _switchAuthMode,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.grey.shade600),
                                    children: [
                                      TextSpan(
                                        text: _isLogin 
                                            ? 'Belum punya akun? '
                                            : 'Sudah punya akun? ',
                                      ),
                                      TextSpan(
                                        text: _isLogin ? 'Daftar di sini' : 'Login di sini',
                                        style: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Data akan disinkronisasi dengan cloud Supabase',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
