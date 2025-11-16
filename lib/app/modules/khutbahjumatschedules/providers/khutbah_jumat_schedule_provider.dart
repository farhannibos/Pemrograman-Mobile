// lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/data/models/khutbah_jumat_schedule_model.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart';

class KhutbahJumatScheduleProvider extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  static const String _tableName = 'khutbah_jumat_schedules';

  Future<List<KhutbahJumatScheduleModel>> getKhutbahJumatSchedules() async {
    print("KhutbahJumatScheduleProvider: Attempting to fetch schedules from Supabase...");
    try {
      final List<dynamic> data = await _supabaseService
          .from(_tableName)
          .select()
          .order('date', ascending: true);

      print("KhutbahJumatScheduleProvider: Supabase response received for SELECT.");
      // print("KhutbahJumatScheduleProvider: Response data: $data"); // Bisa di-uncomment untuk debug

      if (data.isEmpty) {
        print("KhutbahJumatScheduleProvider: No data found in Supabase.");
        return [];
      }

      return data
          .map((json) => KhutbahJumatScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print("KhutbahJumatScheduleProvider: Error fetching Khutbah Jumat schedules from Supabase: $e");
      print("Stack Trace: $stackTrace");
      rethrow;
    }
  }

  // --- Metode Baru: Menambahkan Jadwal Khutbah Jumat ---
  Future<void> addKhutbahSchedule(KhutbahJumatScheduleModel schedule) async {
    print("KhutbahJumatScheduleProvider: Attempting to add schedule to Supabase...");
    try {
      // Supabase biasanya akan otomatis menambahkan `id` jika tidak disertakan,
      // tetapi untuk konsistensi kita buat di client jika model butuh id.
      // Kita perlu membuat map JSON tanpa 'id' karena Supabase akan meng-generate ID sendiri
      // atau menggunakan uuid_generate_v4() sesuai skema tabel.
      // Namun, jika model Anda memang membutuhkan ID dari client, pastikan itu unik.
      final Map<String, dynamic> dataToInsert = schedule.toJson();
      // Hapus 'id' dari dataToInsert jika Supabase yang generate,
      // atau biarkan jika Anda ingin mengirim ID yang di-generate client.
      // Untuk skema kita yang pakai uuid_generate_v4() default, kita tidak perlu kirim ID.
      dataToInsert.remove('id'); 
      dataToInsert.remove('created_at'); // Supabase juga akan generate created_at

      await _supabaseService
          .from(_tableName)
          .insert(dataToInsert);

      print("KhutbahJumatScheduleProvider: Supabase response received for INSERT.");
      print('Khutbah Jumat schedule added to Supabase: ${schedule.khatibName} - ${schedule.topic}');
    } catch (e, stackTrace) {
      print("KhutbahJumatScheduleProvider: Error adding Khutbah Jumat schedule to Supabase: $e");
      print("Stack Trace: $stackTrace");
      rethrow;
    }
  }

  // --- Metode Baru: Menghapus Jadwal Khutbah Jumat ---
  Future<void> deleteKhutbahSchedule(String id) async {
    print("KhutbahJumatScheduleProvider: Attempting to delete schedule from Supabase (ID: $id)...");
    try {
      await _supabaseService
          .from(_tableName)
          .delete()
          .eq('id', id); // Filter berdasarkan ID

      print("KhutbahJumatScheduleProvider: Supabase response received for DELETE.");
      print('Khutbah Jumat schedule deleted from Supabase (ID: $id).');
    } catch (e, stackTrace) {
      print("KhutbahJumatScheduleProvider: Error deleting Khutbah Jumat schedule from Supabase (ID: $id): $e");
      print("Stack Trace: $stackTrace");
      rethrow;
    }
  }
}