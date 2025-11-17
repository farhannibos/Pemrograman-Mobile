# PRAKTIKUM MODUL 3
## API Call & Async Handling

**SharedPreferences (Theme — Dark / Light)**

- **Purpose:** Menyimpan preferensi tema (dark mode / light mode) secara lokal agar pilihan pengguna bertahan antara sesi aplikasi.
- **Implementasi:** Lihat service tema di `lib/services/theme_service.dart`. Inisialisasi dan penggunaan tema biasanya dilakukan dari `lib/main.dart` dan halaman UI yang menyediakan toggle.
- **Cara Kerja Singkat:** Saat pengguna mengganti tema, aplikasi menyimpan pilihan ke SharedPreferences melalui fungsi pada `ThemeService`. Pada startup aplikasi, `ThemeService` membaca nilai tersimpan dan mengatur theme yang sesuai.

**Hive (Local Storage)**

- **Purpose:** Menyimpan data lokal terstruktur (contoh: data kajian) secara persisten dengan model dan adapter Hive.
- **File terkait:**
	- `lib/models/kajian_hive_model.dart` — model data untuk entitas kajian.
	- `lib/models/kajian_hive_model.g.dart` — file generated (TypeAdapter) untuk Hive.
	- `lib/controllers/kajian_hive_controller.dart` — controller untuk mengatur logika baca/tulis ke Hive.
	- `lib/services/hive_kajian_service.dart` — wrapper service yang membuka box, CRUD, dan serialisasi.
- **Implementasi & Catatan:** Pastikan Hive diinisialisasi (biasanya di `main.dart`) dengan `Hive.initFlutter()` sebelum membuka box. Nama box dan detail serialisasi ada di `hive_kajian_service.dart`.

**Cloud (Supabase) — Auth & Database**

- **Purpose:** Menyediakan backend cloud untuk autentikasi pengguna dan penyimpanan data (Postgres via Supabase).
- **File terkait:**
	- `lib/services/supabase_client.dart` — inisialisasi client Supabase (URL & anon/public key).
	- `lib/services/supabase_service.dart` — wrapper untuk operasi autentikasi dan query database (sign up, sign in, sign out, CRUD tabel).
	- `lib/auth_screen.dart` — tampilan/auth UI yang berinteraksi dengan Supabase untuk login/registrasi.
	- `lib/test_supabase.dart` — file helper/test untuk mencoba koneksi dan operasi Supabase.
- **Fitur utama:** Autentikasi (email/password, session handling) dan operasi database (insert, read, update, delete pada tabel yang dikonfigurasi di Supabase).
- **Konfigurasi:** Simpan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` secara aman (mis. environment variables atau file konfigurasi tidak termasuk pada repo publik). `supabase_client.dart` memerlukan nilai ini untuk menginisialisasi client.

**Lokasi Kode (Ringkasan)**

- `lib/services/theme_service.dart`: layanan untuk menyimpan dan membaca preferensi theme (SharedPreferences).
- `lib/main.dart`: inisialisasi app, kemungkinan inisialisasi Hive dan theme; titik masuk aplikasi.
- `lib/models/kajian_hive_model.dart` & `*.g.dart`: model data Hive.
- `lib/services/hive_kajian_service.dart`: akses dan operasi Hive.
- `lib/controllers/kajian_hive_controller.dart`: logic pengelolaan data lokal (controller).
- `lib/services/supabase_client.dart`: inisialisasi Supabase client.
- `lib/services/supabase_service.dart`: wrapper fungsi auth & database untuk Supabase.
- `lib/auth_screen.dart`: UI untuk autentikasi menggunakan Supabase.
- `lib/test_supabase.dart`: contoh/tes pemanggilan Supabase.

**Cara Menjalankan & Catatan Singkat**

- Pastikan dependencies berikut ada di `pubspec.yaml`: `shared_preferences`, `hive`, `hive_flutter`, `supabase_flutter` (atau paket supabase yang dipakai).
- Jalankan `flutter pub get` untuk mengunduh dependencies.
- Jalankan aplikasi dengan:

```
flutter run
```

- Pastikan Supabase URL/Key dikonfigurasi sebelum mencoba fitur auth/database.

Jika Anda ingin, saya dapat:
- Menambahkan contoh kode singkat untuk memanggil fungsi theme toggle dan operasi Hive/Supabase.
- Membuat file konfigurasi `.env.example` yang menunjukkan variabel Supabase yang diperlukan.

---
_Dokumentasi ini ditambahkan otomatis — beri tahu saya jika Anda ingin penyesuaian (bahasa, detail implementasi, atau contoh kode)._ 

**GetX (State Management, Dependency Injection, Navigation)**

- **Purpose:** Mengelola state reaktif, dependency injection, dan navigasi dengan mudah menggunakan `GetX`/`Get`.
- **Lokasi penggunaan di project:**
	- Registrasi/iniialisasi: `lib/main.dart` (`Get.put(ThemeService())`, `Get.put(KajianHiveController())`, `Get.put(SupabaseService())`, dll.)
	- Controller: `lib/controllers/kajian_hive_controller.dart` (menggunakan `RxList` dan `RxBool`).
	- Services: `lib/services/theme_service.dart` (menggunakan `GetxController` dan `.obs`).
	- UI: `lib/home_screen.dart`, `lib/auth_screen.dart` (memanggil `Get.find<T>()`, menggunakan `Obx()` untuk rebuild otomatis).
- **Konsep utama yang dipakai:**
	- Dependency Injection: `Get.put()` mendaftarkan instance yang dapat diakses di mana saja memakai `Get.find<T>()`.
	- Reactive variables: deklarasi `.obs` (contoh: `final RxList<KajianHiveModel> kajianList = <KajianHiveModel>[].obs;`) dan akses lewat `.value` atau langsung di dalam `Obx`.
	- UI reaktif: `Obx(() => Widget(...))` secara otomatis merender ulang ketika variabel `.obs` berubah.
	- Lifecycle: controller menggunakan `onInit()` untuk memuat data awal (mis. `loadKajianFromHive()`).
- **Contoh singkat (di README):**

```dart
// mendaftarkan controller (biasanya di main.dart)
Get.put(KajianHiveController());

// mengakses dan menampilkan jumlah secara reaktif di UI
Obx(() {
	final c = Get.find<KajianHiveController>();
	return Text('${c.getTotalKajian()} kajian');
});

// toggle theme (memanggil service)
Get.find<ThemeService>().toggleTheme();

// autentication
await Get.find<SupabaseService>().signIn(email, password);
```

- **Catatan & rekomendasi:**
	- Untuk service yang butuh inisialisasi async (mis. membuka Hive box), buat instance, jalankan init, lalu `Get.put(instance)` agar terhindar dari race condition.
	- Jika project berkembang, pertimbangkan menggunakan `Bindings` untuk mendaftarkan dependency per route/module.

---
