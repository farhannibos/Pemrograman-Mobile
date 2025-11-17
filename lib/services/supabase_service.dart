import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kajian_hive_model.dart';
import 'supabase_client.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _supabase = SupabaseClientService.client;

  // ===== AUTH METHODS =====
  Future<void> signUp(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (response.user == null) {
        throw Exception('Registrasi gagal - tidak ada user yang dibuat');
      }
    } on AuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (response.user == null) {
        throw Exception('Login gagal');
      }
    } on AuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // ===== DATABASE METHODS =====
  Future<void> syncKajianToCloud(List<KajianHiveModel> kajianList) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User belum login');

      for (final kajian in kajianList) {
        await _supabase
            .from('kajian')
            .upsert({
              'id': kajian.id,
              'user_id': user.id,
              'title': kajian.title,
              'description': kajian.description,
              'pemateri': kajian.pemateri,
              'lokasi': kajian.lokasi,
              'date': kajian.date.toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
      }
    } catch (e) {
      throw Exception('Sync gagal: $e');
    }
  }

  Future<List<KajianHiveModel>> getKajianFromCloud() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User belum login');

      final response = await _supabase
          .from('kajian')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      final List<dynamic> data = response;
      
      return data.map((item) {
        final map = item as Map<String, dynamic>;
        return KajianHiveModel(
          id: map['id']?.toString() ?? '',
          title: map['title']?.toString() ?? '',
          description: map['description']?.toString() ?? '',
          pemateri: map['pemateri']?.toString() ?? '',
          lokasi: map['lokasi']?.toString() ?? '',
          date: DateTime.parse(map['date']?.toString() ?? DateTime.now().toIso8601String()),
        );
      }).toList();
    } catch (e) {
      throw Exception('Fetch data gagal: $e');
    }
  }

  Future<void> deleteKajianFromCloud(String id) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User belum login');

      await _supabase
          .from('kajian')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Delete gagal: $e');
    }
  }

  // ===== STORAGE METHODS =====
  Future<String> uploadFile(File file, String fileName) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User belum login');

      final uniqueFileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage
          .from('kajian_files')
          .upload(uniqueFileName, file);

      return _supabase.storage
          .from('kajian_files')
          .getPublicUrl(uniqueFileName);
    } catch (e) {
      throw Exception('Upload file gagal: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFilesList() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User belum login');
      
      final files = await _supabase.storage
        .from('kajian_files')
        .list();

      return files.map((file) {
        // Handle updatedAt
        dynamic updatedAt = file.updatedAt;
        if (updatedAt is DateTime) {
          updatedAt = updatedAt.toIso8601String();
        }
        
        // Handle createdAt
        dynamic createdAt = file.createdAt;
        if (createdAt is DateTime) {
          createdAt = createdAt.toIso8601String();
        }

        // Handle size dari metadata tanpa cast
        final metadata = file.metadata;
        final size = metadata?['size'] ?? metadata?['contentLength'];

        return {
          'name': file.name,
          'id': file.id,
          'updated_at': updatedAt?.toString(),
          'created_at': createdAt?.toString(),
          'size': size,
          'metadata': metadata,
        };
      }).toList();
    } catch (e) {
      throw Exception('Get files list gagal: $e');
    }
  }

  // ===== REALTIME SUBSCRIPTION =====
  Stream<List<Map<String, dynamic>>> getKajianRealtime() {
    return _supabase
        .from('kajian')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUser?.id ?? '')
        .order('date')
        .map((data) => data); // Data sudah dalam format yang benar
  }

  // ===== UTILITY METHODS =====
  Future<bool> checkConnection() async {
    try {
      await _supabase.from('kajian').select().limit(1).timeout(const Duration(seconds: 10));
      return true;
    } catch (e) {
      return false;
    }
  }
}