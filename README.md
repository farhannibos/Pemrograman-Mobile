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

#### Bagian: Hive Inisialisasi & Setup
- **File utama:** `lib/app/data/services/local_storage_service.dart`
- **Ketika dijalankan:** Diinisialisasi di awal startup melalui `GlobalBindings`
- **Cara kerja:**
  ```dart
  // Platform non-WEB (Android, iOS, Desktop):
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Platform WEB:
  await Hive.initFlutter();  // Menggunakan IndexedDB browser
  ```
- **Box yang dibuka:** `pengajian_schedule_box` (menyimpan jadwal pengajian lokal)
  ```dart
  _pengajianScheduleBox = await Hive.openBox('pengajian_schedule_box');
  ```
- **Getter untuk akses:** `pengajianScheduleBox` — diakses dari service ini

#### Bagian: Hive CRUD Operations
**File:** `lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart`

Hive box `pengajianScheduleBox` menyimpan data sebagai Map (tidak ada Hive adapter yang di-generate). Data dikonversi menggunakan `toMap()`/`fromMap()` saat CRUD.

**1. READ (Membaca data lokal)**
```dart
List<PengajianScheduleModel> getPengajianSchedules() {
  final List<PengajianScheduleModel> schedules = [];
  final userId = _getCurrentUserId();  // Ambil ID user yang login
  
  final box = _localStorageService.pengajianScheduleBox;
  
  for (var key in box.keys) {
    final value = box.get(key);
    if (value is Map) {
      final mapData = Map<String, dynamic>.from(value);
      final itemUserId = mapData['userId'] as String?;
      
      // Hanya ambil data milik user yang login
      if (itemUserId == userId) {
        schedules.add(PengajianScheduleModel.fromMap(mapData));
      }
    }
  }
  
  // Urutkan dari yang terbaru ke terlama
  schedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return schedules;
}
```

**2. CREATE (Menambah data lokal)**
```dart
Future<void> addPengajianSchedule(PengajianScheduleModel schedule) async {
  final userId = _getCurrentUserId();
  if (userId == null) {
    throw Exception('User tidak terautentikasi.');
  }

  final service = await _getLocalStorageService();
  final box = service.pengajianScheduleBox;
  
  final mapData = schedule.toMap();
  mapData['userId'] = userId;  // Tambahkan user_id
  
  // Simpan dengan key = schedule.id
  await box.put(schedule.id, mapData);
  print('Jadwal pengajian disimpan ke Hive: ${schedule.title}');
}
```

**3. UPDATE (Mengubah data lokal)**
```dart
Future<void> updatePengajianSchedule(PengajianScheduleModel updatedSchedule) async {
  final userId = _getCurrentUserId();
  if (userId == null) {
    throw Exception('User tidak terautentikasi.');
  }

  final service = await _getLocalStorageService();
  final box = service.pengajianScheduleBox;
  
  if (box.containsKey(updatedSchedule.id)) {
    final mapData = updatedSchedule.toMap();
    mapData['userId'] = userId;
    
    await box.put(updatedSchedule.id, mapData);
    print('Jadwal pengajian diupdate di Hive: ${updatedSchedule.title}');
  }
}
```

**4. DELETE (Menghapus data lokal)**
```dart
Future<void> deletePengajianSchedule(String id) async {
  final userId = _getCurrentUserId();
  if (userId == null) {
    throw Exception('User tidak terautentikasi.');
  }

  final service = await _getLocalStorageService();
  final box = service.pengajianScheduleBox;
  
  // Verifikasi bahwa data milik user yang login sebelum menghapus
  final value = box.get(id);
  if (value is Map) {
    final mapData = Map<String, dynamic>.from(value);
    final itemUserId = mapData['userId'] as String?;
    if (itemUserId != userId) {
      throw Exception('Anda tidak memiliki izin untuk menghapus jadwal ini.');
    }
  }
  
  await box.delete(id);
  print('Jadwal pengajian dihapus dari Hive: $id');
}
```

#### File Model untuk Konversi Map
- **File:** `lib/app/data/models/pengajian_schedule_model.dart`
- **Metode penting:**
  - `toMap()` — konversi model ke Map saat disimpan ke Hive
  - `fromMap(Map)` — konversi Map menjadi model saat dibaca dari Hive

**Contoh struktur model:**
```dart
class PengajianScheduleModel {
  final String id;
  final String userId;      // Untuk filter per user
  final String title;
  final DateTime date;
  final String? time;
  final String? location;
  final DateTime createdAt;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory PengajianScheduleModel.fromMap(Map<String, dynamic> map) {
    return PengajianScheduleModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String?,
      location: map['location'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
```

#### Catatan Penting Hive
- Hive digunakan untuk **data offline/lokal** yang tidak perlu disinkronkan dengan server
- Data disimpan sebagai **Map** karena model belum memiliki Hive adapter (@HiveType annotation)
- Setiap record di-filter berdasarkan `userId` untuk **isolasi data per user**
- Box `pengajianScheduleBox` otomatis dibuka saat inisialisasi di `GlobalBindings`
- Penyimpanan lokal memungkinkan aplikasi tetap **bekerja offline** tanpa koneksi internet### Supabase (backend cloud)
- `lib/app/data/services/supabase_service.dart`
  - Membungkus inisialisasi Supabase dan menyediakan helper seperti `from(table)` dan `supabaseClient`.
  - Membaca kredensial dari file `.env` (lihat bagian Environment di bawah).

#### Bagian: Supabase AUTH (Autentikasi)
- **File utama:** `lib/app/data/services/supabase_service.dart`
- **Getter untuk akses:** `auth` (GoTrueClient) — dari `client.auth`
- **Cara mengakses user saat login:**
  ```dart
  final user = supabaseService.supabaseClient.auth.currentUser;
  if (user != null) {
    print("User email: ${user.email}");
    print("User ID: ${user.id}");
  }
  ```
- **Digunakan di:**
  - `lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart` — method `_getCurrentUserId()` untuk mendapatkan ID user yang login, kemudian gunakan untuk filter data hanya milik user tersebut.
  - `lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart` — method `_getCurrentUserId()` dengan cara yang sama.

#### Bagian: Supabase DATABASE (Tabel & CRUD)
- **File utama:** `lib/app/data/services/supabase_service.dart`
- **Helper method:** `from(String table)` — untuk akses tabel Supabase
- **Tabel cloud yang dipakai:**
  - `khutbah_jumat_schedules` — untuk jadwal khutbah Jumat dari cloud

**Operasi pada tabel `khutbah_jumat_schedules`:**

File: `lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart`

1. **SELECT (Membaca data)**
   ```dart
   final List<dynamic> data = await _supabaseService
       .from('khutbah_jumat_schedules')
       .select()
       .eq('user_id', userId)              // Filter: hanya data milik user yang login
       .order('date', ascending: true);    // Sort: urutkan berdasarkan tanggal
   ```
   - Method: `getKhutbahJumatSchedules()` — mengambil semua jadwal khutbah milik user yang login

2. **INSERT (Menambah data)**
   ```dart
   await _supabaseService
       .from('khutbah_jumat_schedules')
       .insert(dataToInsert);  // dataToInsert adalah Map<String, dynamic>
   ```
   - Method: `addKhutbahSchedule(KhutbahJumatScheduleModel schedule)` — menambah jadwal baru
   - Fitur: otomatis menambahkan `user_id`, membersihkan format waktu sebelum insert

3. **DELETE (Menghapus data)**
   ```dart
   await _supabaseService
       .from('khutbah_jumat_schedules')
       .delete()
       .eq('id', id)
       .eq('user_id', userId);  // Keamanan: hanya hapus data milik user yang login
   ```
   - Method: `deleteKhutbahSchedule(String id)` — menghapus jadwal berdasarkan ID

**Skema tabel Supabase yang diharapkan:**
```sql
CREATE TABLE khutbah_jumat_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  khatib_name TEXT NOT NULL,
  date DATE NOT NULL,
  time TIME,                            -- Format HH:MM:SS (opsional)
  topic TEXT,                           -- Topik khutbah (opsional)
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

- `lib/app/modules/khutbahjumatschedules/providers/khutbah_jumat_schedule_provider.dart`
  - Mengambil jadwal Khutbah Jumat dari Supabase (cloud) dan memetakan hasil ke model aplikasi.- `lib/app/modules/pengajianschedules/providers/pengajian_schedule_provider.dart`
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

---

## 🔧 GetX - State Management & Dependency Injection

### Apa itu GetX?
**GetX** adalah library Flutter yang menyediakan state management, routing, dan dependency injection dalam satu paket.
Dalam proyek ini, GetX digunakan untuk:
1. **State Management** — Mengubah state reaktif tanpa rebuild seluruh widget
2. **Dependency Injection** — Registrasi dan akses service/controller di seluruh aplikasi
3. **Routing** — Navigasi antar halaman dengan named routes
4. **Performance** — Lazy initialization untuk efisiensi memori

---

### 1. Reactive State Management dengan Observables

GetX menggunakan `Rx` untuk membuat data yang reactive (dapat diobservasi). Ketika nilai berubah, widget yang menggunakan data itu otomatis rebuild.

#### Contoh: RxBool (Boolean reaktif)
```dart
// Di ThemeProvider (lib/app/modules/settings/providers/theme_provider.dart)
class ThemeProvider extends GetxService {
  // RxBool membuat isDarkMode observable
  final RxBool _isDarkMode = false.obs;
  
  RxBool get isDarkMode => _isDarkMode;
  
  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;  // Ubah nilai
    // UI yang Obx(() => ...) akan rebuild otomatis!
  }
}
```

#### Contoh: RxList (List reaktif)
```dart
// Di PengajianScheduleController (lib/app/modules/pengajianschedules/controllers/pengajian_schedule_controller.dart)
class PengajianScheduleController extends GetxController {
  // RxList membuat pengajianSchedules observable
  final RxList<PengajianScheduleModel> pengajianSchedules = 
      <PengajianScheduleModel>[].obs;
  
  Future<void> loadPengajianSchedules() async {
    final data = _provider.getPengajianSchedules();
    pengajianSchedules.assignAll(data);  // Ubah seluruh list
    // UI akan rebuild otomatis!
  }
}
```

#### Menggunakan Observables di Widget
```dart
// Dalam build() method atau di GetBuilder
Obx(() => ListView.builder(
  itemCount: controller.pengajianSchedules.length,
  itemBuilder: (context, index) {
    return Text(controller.pengajianSchedules[index].title);
    // Jika pengajianSchedules berubah, ListView rebuild otomatis
  },
))
```

---

### 2. Dependency Injection (Service Locator)

GetX menggunakan pola **Service Locator** untuk mendaftarkan dan mengakses service/controller di seluruh app tanpa perlu pass parameter.

#### Alur Dependency Injection:

**1️⃣ Registrasi di GlobalBindings (Startup)**
```dart
// lib/global_bindings.dart
class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    // Daftarkan service secara asinkron
    Get.putAsync(() => LocalStorageService().init());   // Priority 1 (Hive)
    Get.putAsync(() => ThemeProvider().init());         // Priority 2 (SharedPrefs)
    Get.putAsync(() => SupabaseService().init());       // Priority 3 (Cloud)
  }
  
  // Metode untuk menunggu semua async selesai
  Future<void> initializeServices() async {
    await _localStorageFuture!;    // Tunggu semuanya
    await _themeProviderFuture!;
    await _supabaseFuture!;
    print("Semua service siap!");
  }
}
```

**2️⃣ Registrasi di Module Binding (Saat navigasi ke halaman)**
```dart
// lib/app/modules/pengajianschedules/bindings/pengajian_schedule_binding.dart
class PengajianScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan provider dan controller untuk modul ini
    Get.lazyPut<PengajianScheduleProvider>(
      () => PengajianScheduleProvider(),  // Lazy: baru dibuat saat diakses
    );
    Get.lazyPut<PengajianScheduleController>(
      () => PengajianScheduleController(),
    );
  }
}
```

**3️⃣ Akses Service dari mana saja dengan Get.find()**
```dart
// Di mana saja di aplikasi
final provider = Get.find<PengajianScheduleProvider>();
final controller = Get.find<PengajianScheduleController>();

// Atau langsung akses di controller
class PengajianScheduleController extends GetxController {
  final provider = Get.find<PengajianScheduleProvider>();
}
```

---

### 3. Service Registration Methods

GetX menyediakan berbagai cara untuk registrasi:

| Method | Kapan Digunakan | Kapan Dibuat | Kapan Dihapus |
|--------|-----------------|-------------|---------------|
| `Get.put()` | Sync service, akses segera | Saat dipanggil | Saat halaman ditutup |
| `Get.putAsync()` | Async service (Future) | Saat dipanggil (async) | Saat halaman ditutup |
| `Get.lazyPut()` | Lazy loading, hemat memori | **Saat pertama kali diakses** | Saat halaman ditutup |
| `Get.putIfAbsent()` | Jika belum registered | Saat dipanggil | Saat halaman ditutup |
| `Get.put(..., permanent: true)` | Global service selamanya | Saat dipanggil | **Tidak pernah dihapus** |

**Contoh di project:**
```dart
// GlobalBindings - putAsync service (startup)
Get.putAsync(
  () => LocalStorageService().init(),
  // Service akan tersedia setelah init() selesai
);

// Module Binding - lazy loading (hemat memori)
Get.lazyPut<PengajianScheduleProvider>(
  () => PengajianScheduleProvider(),
  // Hanya dibuat saat pertama kali diakses
);
```

---

### 4. GetxService vs GetxController

**GetxService** — Untuk layer business logic (provider, service)
- Tidak memiliki lifecycle khusus
- Biasanya tidak dispose
- Digunakan: LocalStorageService, ThemeProvider, SupabaseService

**GetxController** — Untuk layer UI state management (controller)
- Memiliki `onInit()`, `onReady()`, `onClose()` lifecycle
- Dimanage otomatis saat halaman di-pop
- Digunakan: HomeController, PengajianScheduleController, KhutbahJumatScheduleController

```dart
// Layer Service - menggunakan GetxService
class ThemeProvider extends GetxService {
  Future<ThemeProvider> init() async {
    await _loadTheme();
    return this;
  }
}

// Layer Controller - menggunakan GetxController
class PengajianScheduleController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadPengajianSchedules();  // Load saat controller dibuat
  }
  
  @override
  void onClose() {
    super.onClose();
    // Cleanup resources
  }
}
```

---

### 5. Routing dengan GetX

Routing di GetX menggunakan named routes dan automatic binding injection.

**Definisi Routes:**
```dart
// lib/app/routes/app_pages.dart
class AppPages {
  static const INITIAL = Routes.HOME;
  
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),  // Registrasi dependency untuk halaman ini
    ),
    GetPage(
      name: Routes.PENGAJIAN_SCHEDULES,
      page: () => const PengajianScheduleListView(),
      binding: PengajianScheduleBinding(),  // Get.lazyPut() dipanggil di sini
    ),
  ];
}
```

**Navigasi:**
```dart
// Named navigation (dengan automatic binding)
Get.toNamed(Routes.PENGAJIAN_SCHEDULES);

// Back
Get.back();

// Replace route (pop stack)
Get.offNamed(Routes.HOME);

// Bersihkan route history dan go to halaman baru
Get.offAllNamed(Routes.HOME);
```

**Mengapa Binding penting di GetPage?**
Ketika halaman dimulai, GetX otomatis:
1. Memanggil `binding.dependencies()` — registrasi controller/provider untuk modul itu
2. Membuat widget dari `page()` — HomeView, PengajianScheduleListView, dsb
3. Widget bisa langsung mengakses controller dengan `Get.find<ControllerName>()`

---

### 6. Alur Lifecycle Aplikasi

```
🚀 main() dipanggil
    ↓
❶ GlobalBindings().dependencies()
    ├─ Get.putAsync(LocalStorageService)      → Hive init
    ├─ Get.putAsync(ThemeProvider)             → SharedPreferences load
    └─ Get.putAsync(SupabaseService)           → Supabase init
    ↓
❷ await globalBindings.initializeServices()
    ├─ Tunggu LocalStorageService ready
    ├─ Tunggu ThemeProvider ready
    └─ Tunggu SupabaseService ready
    ↓
❸ Get.isRegistered<SupabaseService>() ✓
    ├─ Semua service siap
    └─ Safe untuk akses Get.find()
    ↓
❹ runApp(MyApp())
    ├─ GetMaterialApp dengan initialRoute: Routes.HOME
    └─ HomeBinding().dependencies()
        ├─ Get.lazyPut<HomeController>()
        └─ HomeView dibuat → bisa akses Get.find<HomeController>()
    ↓
🎯 Aplikasi berjalan
    ├─ User navigasi: Get.toNamed(Routes.PENGAJIAN_SCHEDULES)
    │  → PengajianScheduleBinding().dependencies() dipanggil
    │  → Get.lazyPut<PengajianScheduleController>()
    │  → PengajianScheduleListView dibuat
    ↓
🔄 State Update
    ├─ User interaksi → ubah observable (RxBool, RxList, dsb)
    └─ Obx(() => ...) widget rebuild otomatis
    ↓
❌ User back/navigasi away
    ├─ PengajianScheduleController.onClose() dipanggil
    ├─ Resource dibersihkan
    └─ Controller dihapus dari memory
```

---

### 7. Contoh Praktis: Menggunakan GetX di View

```dart
// lib/app/modules/home/views/home_view.dart
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Akses controller (otomatis sudah di-inject oleh HomeBinding)
    final HomeController controller = Get.find<HomeController>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          children: [
            // Observable theme yang reactive
            Obx(() {
              final isDarkMode = Get.find<ThemeProvider>().isDarkMode.value;
              return Text('Dark Mode: $isDarkMode');
            }),
            
            // Tombol untuk navigate
            ElevatedButton(
              onPressed: () => controller.goToSettings(),
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 8. Ringkasan: GetX dalam Proyek MasjidKu

| Aspek | Implementasi | File |
|-------|-------------|------|
| **Global Services** | LocalStorage (Hive), Theme, Supabase | `global_bindings.dart` |
| **State Management** | RxBool, RxList, RxInt observables | `theme_provider.dart`, `*_controller.dart` |
| **Dependency Injection** | Get.find(), Get.lazyPut(), Get.putAsync() | `*_binding.dart` |
| **Routing** | Named routes + automatic binding | `app_pages.dart` + `app_routes.dart` |
| **Lifecycle** | onInit(), onClose() | `*_controller.dart` |
| **Reactive UI** | Obx(), GetBuilder() widgets | View files |

---
