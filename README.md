# masjid_ku

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Lokasi kode penyimpanan dan cloud

Proyek ini menggunakan tiga pendekatan penyimpanan yang berbeda di beberapa bagian aplikasi:

- SharedPreferences (penyimpanan key/value sederhana, untuk pengaturan kecil)
- Hive (penyimpanan lokal NoSQL untuk data aplikasi seperti jadwal)
- Supabase (backend cloud untuk sinkronisasi jadwal dan autentikasi)

Berikut file-file penting dan lokasinya yang bisa kamu gunakan saat presentasi.

### SharedPreferences (pengaturan & flag kecil)
- `lib/app/modules/settings/providers/theme_provider.dart`
	- Menyimpan pilihan tema pengguna (`isDarkTheme`) menggunakan `SharedPreferences`.
	- Metode penting: `init()` untuk memuat dan `toggleTheme()` untuk menyimpan perubahan.

- `lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart`
	- Menggunakan `SharedPreferences` untuk flag boolean kecil `_dummyDataAddedKey` yang menandai apakah data dummy sudah ditambahkan.

### Hive (penyimpanan lokal — Jadwal Pengajian)
- `lib/app/data/services/local_storage_service.dart`
	- Bertanggung jawab menginisialisasi Hive, membuka box, dan menyediakan akses ke box yang dipakai aplikasi.

- `lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart`
	- Mengimplementasikan operasi CRUD terhadap Hive (get/add/update/delete jadwal).
	- Membaca/menyimpan Map ke Hive box `pengajianScheduleBox` dan memfilter data berdasarkan pengguna yang sedang login.

- `lib/app/data/models/pengajian_schedule_model.dart`
	- Membantu konversi model ke/dari Map (`toMap`/`fromMap`) saat menyimpan atau memuat dari Hive.

Catatan:
- Hive digunakan untuk data offline/lokal dan biasanya diinisialisasi lebih awal melalui `GlobalBindings`.
- `LocalStorageService` mengekspos box yang dipakai di seluruh aplikasi.

### Supabase (backend cloud)
- `lib/app/data/services/supabase_service.dart`
	- Membungkus inisialisasi Supabase dan menyediakan helper seperti `from(table)` dan `supabaseClient`.
	- Membaca kredensial dari file `.env` (lihat bagian Environment di bawah).

- `lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart`
	- Mengambil jadwal Khutbah Jumat dari Supabase (cloud) dan memetakan hasil ke model aplikasi.

- `lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart`
	- Menggunakan client Supabase untuk mengambil info user saat ini dan (opsional) menyinkronkan data cloud.

- `lib/global_bindings.dart`
	- Bertanggung jawab mendaftarkan dan menginisialisasi layanan global (Hive, ThemeProvider, SupabaseService).
	- Penting agar layanan terdaftar sebelum controller/provider mencoba mengaksesnya.

### Environment (.env)
- Client Supabase membaca `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dari file `.env` di root proyek.
- Buat file `.env` di root proyek (jangan commit ke VCS) dengan isi contohnya:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Jika file `.env` tidak ada atau bernilai tidak valid, inisialisasi Supabase akan gagal dan fitur cloud akan fallback atau dinonaktifkan.

### Petunjuk singkat untuk presentasi
- Tunjukkan `GlobalBindings` untuk menjelaskan urutan startup aplikasi dan pendaftaran layanan (Hive -> Theme -> Supabase).
- Tunjukkan `LocalStorageService` untuk menjelaskan di mana box Hive dibuat dan bagaimana persistence lokal bekerja.
- Tunjukkan `ThemeProvider` untuk contoh penggunaan `SharedPreferences` pada pengaturan sederhana.
- Tunjukkan `SupabaseService` dan `khutbah_jumat_schedule_provider.dart` untuk menunjukkan permintaan cloud dan pemetaan hasil ke model.

---

Jika kamu mau, saya bisa menambahkan potongan kode singkat ke README yang menunjukkan contoh read/write untuk masing-masing penyimpanan, atau membuat poin-poin siap slide untuk tiap file. Pilih format yang kamu mau (snippet README / bullet slide / contoh perintah terminal). 
