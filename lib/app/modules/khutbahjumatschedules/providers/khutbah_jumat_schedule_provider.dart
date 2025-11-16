// lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart
import 'package:get/get.dart';
import 'package:masjid_ku/app/data/models/khutbah_jumat_schedule_model.dart';
import 'package:masjid_ku/app/data/services/supabase_service.dart';

class KhutbahJumatScheduleProvider extends GetxService {
  static const String _tableName = 'khutbah_jumat_schedules';

  Future<List<KhutbahJumatScheduleModel>> getKhutbahJumatSchedules() async {
    print("KhutbahJumatScheduleProvider: Attempting to fetch schedules from Supabase...");

    // Ambil SupabaseService pada saat diperlukan — jangan panggil di konstruktor
    final SupabaseService? supabaseService =
        Get.isRegistered<SupabaseService>() ? Get.find<SupabaseService>() : null;

    if (supabaseService == null) {
      print('KhutbahJumatScheduleProvider: SupabaseService belum tersedia. Mengembalikan list kosong.');
      return <KhutbahJumatScheduleModel>[];
    }

    try {
      final response = await supabaseService
          .from(_tableName)
          .select()
          .order('date', ascending: true);

      print("KhutbahJumatScheduleProvider: Supabase response received.");

      // Konversi List<Map<String, dynamic>> menjadi List<KhutbahJumatScheduleModel>
      return (response as List<dynamic>)
          .map((json) => KhutbahJumatScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print("KhutbahJumatScheduleProvider: Error fetching Khutbah Jumat schedules from Supabase: $e");
      print("Stack Trace: $stackTrace");
      rethrow;
    }
  }
}