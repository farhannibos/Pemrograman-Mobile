// lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/data/models/khutbah_jumat_schedule_model.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart'; // Import SupabaseService

class KhutbahJumatScheduleProvider extends GetxService {
  // Dapatkan instance SupabaseService yang sudah diinisialisasi
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  static const String _tableName = 'khutbah_jumat_schedules'; // Nama tabel di Supabase

  Future<List<KhutbahJumatScheduleModel>> getKhutbahJumatSchedules() async {
    try {
      // Query data dari tabel Supabase
          final List<dynamic> data = await _supabaseService
            .from(_tableName)
            .select() // Memilih semua kolom
            .order('date', ascending: true) // Urutkan berdasarkan tanggal ascending
            as List<dynamic>;

          // Konversi List<Map<String, dynamic>> menjadi List<KhutbahJumatScheduleModel>
          return data
            .map((json) => KhutbahJumatScheduleModel.fromJson(json as Map<String, dynamic>))
            .toList();
    } catch (e, stackTrace) {
      print("Error fetching Khutbah Jumat schedules from Supabase: $e");
      print("Stack Trace: $stackTrace");
      rethrow; // Lempar ulang error agar bisa ditangani di Controller
    }
  }

  // Jika nanti ada fitur admin dan perlu CRUD, metode ini akan ditambahkan
  // Future<void> addKhutbahSchedule(KhutbahJumatScheduleModel schedule) async { ... }
  // Future<void> updateKhutbahSchedule(KhutbahJumatScheduleModel schedule) async { ... }
  // Future<void> deleteKhutbahSchedule(String id) async { ... }
}