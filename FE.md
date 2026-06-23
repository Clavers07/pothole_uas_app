# `lib/` UI Refactor Documentation — Ionic-Like Theme (Vanilla Flutter)

Dokumen ini menjelaskan seluruh perubahan refactor UI pada sisi Flutter (`lib/`) untuk menyesuaikan dengan perubahan backend yang didokumentasikan di [`BE.md`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/BE.md). Tema visual diubah menjadi **Ionic-like** menggunakan **vanilla Flutter** (tanpa tambahan package UI framework seperti `ionic_flutter`, dll.).

---

## Daftar Isi

1. [Ringkasan Perubahan](#1-ringkasan-perubahan)
2. [Design System — Ionic-Like Theme](#2-design-system--ionic-like-theme)
3. [Perubahan Per File](#3-perubahan-per-file)
   - 3.1 [`main.dart`](#31-maindart)
   - 3.2 [`api_service.dart`](#32-api_servicedart)
   - 3.3 [`login_page.dart`](#33-login_pagedart)
   - 3.4 [`dashboard_page.dart`](#34-dashboard_pagedart)
   - 3.5 [`report_form_page.dart`](#35-report_form_pagedart) *(rename dari `sampah_form_page.dart`)*
   - 3.6 [`chat_page.dart`](#36-chat_pagedart)
4. [File Yang Dihapus / Tidak Dipakai](#4-file-yang-dihapus--tidak-dipakai)
5. [Catatan Tambahan](#5-catatan-tambahan)

---

## 1. Ringkasan Perubahan

| Aspek | Sebelum (Bank Sampah) | Sesudah (Pothole Report) |
|-------|----------------------|--------------------------|
| **Domain** | Sampah / Waste | Reports / Jalan Berlubang |
| **Endpoint** | `/sampah` | `/reports` |
| **Field Data** | `nama_sampah` | `jalan`, `level_kerusakan` |
| **Tema Warna** | Hijau (`0xFF2E7D32`) | **Ionic Blue** (`0xFF3880FF`) |
| **Ikon Utama** | `Icons.recycling` | `Icons.report_problem` / `Icons.warning_amber` |
| **Branding** | "BANK SAMPAH" | "POTHOLE REPORT" |
| **Tagline** | "Kelola sampah jadi berkah" | "Laporkan jalan berlubang di sekitarmu" |
| **UI Style** | Material standar | **Ionic-like** (vanilla Flutter) |

---

## 2. Design System — Ionic-Like Theme

Seluruh styling dibangun **tanpa package tambahan**, hanya menggunakan widget Material bawaan Flutter yang dikustomisasi agar menyerupai tampilan [Ionic Framework](https://ionicframework.com/docs/components).

### 2.1 Palet Warna (Ionic Default Colors)

Definisikan sebagai **konstanta** di file terpisah atau di bagian atas `main.dart`:

```dart
// lib/ionic_theme.dart (OPSIONAL, bisa juga langsung di main.dart)

import 'package:flutter/material.dart';

class IonicColors {
  // Primary
  static const Color primary       = Color(0xFF3880FF);
  static const Color primaryShade  = Color(0xFF3171E0);
  static const Color primaryTint   = Color(0xFF4C8DFF);

  // Secondary
  static const Color secondary      = Color(0xFF3DC2FF);
  static const Color secondaryShade = Color(0xFF36ABE0);

  // Success
  static const Color success      = Color(0xFF2DD36F);
  static const Color successShade = Color(0xFF28BA62);

  // Warning
  static const Color warning      = Color(0xFFFFC409);
  static const Color warningShade = Color(0xFFE0AC08);

  // Danger
  static const Color danger      = Color(0xFFEB445A);
  static const Color dangerShade = Color(0xFFCF3C4F);

  // Dark & Light
  static const Color dark       = Color(0xFF222428);
  static const Color medium     = Color(0xFF92949C);
  static const Color light      = Color(0xFFF4F5F8);
  static const Color background = Color(0xFFF0F0F0);

  // Toolbar
  static const Color toolbar    = Colors.white;
}
```

### 2.2 Tipografi (Ionic-Like)

```dart
// Gunakan font system default atau Google Fonts "Inter" / "Roboto"
// Ionic menggunakan system font stack, Flutter sudah default ke Roboto

static const TextStyle ionTitle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: IonicColors.dark,
  letterSpacing: 0.15,
);

static const TextStyle ionSubtitle = TextStyle(
  fontSize: 14,
  color: IonicColors.medium,
  fontWeight: FontWeight.w400,
);

static const TextStyle ionLabel = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: IonicColors.dark,
);
```

### 2.3 Komponen Ionic-Like (Vanilla Flutter)

Berikut cara mereplikasi komponen Ionic menggunakan widget Flutter standar:

#### `ion-header` / `ion-toolbar` → `AppBar`

```dart
AppBar(
  elevation: 0.5,                          // Ionic: shadow ringan
  backgroundColor: IonicColors.toolbar,     // Putih bersih
  foregroundColor: IonicColors.dark,         // Teks hitam
  centerTitle: true,                        // Ionic default: center
  title: Text("Judul Halaman", style: IonicTheme.ionTitle),
  bottom: PreferredSize(                    // Garis border bawah tipis
    preferredSize: const Size.fromHeight(1),
    child: Container(color: Colors.grey[200], height: 1),
  ),
)
```

#### `ion-item` → `ListTile` + Kustom

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
  ),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: /* avatar/icon */,
    title: Text("Label", style: IonicTheme.ionLabel),
    subtitle: Text("Detail", style: IonicTheme.ionSubtitle),
    trailing: Icon(Icons.chevron_right, color: IonicColors.medium),
  ),
)
```

#### `ion-button` → `ElevatedButton` Kustom

```dart
SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: IonicColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,                          // Ionic: flat button
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Ionic: border-radius 8px
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    onPressed: () {},
    child: const Text("TOMBOL"),
  ),
)
```

#### `ion-input` → `TextFormField` Kustom

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: "Label",
    labelStyle: TextStyle(color: IonicColors.medium),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: IonicColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: IonicColors.danger, width: 1),
    ),
    prefixIcon: Icon(Icons.email_outlined, color: IonicColors.medium),
  ),
)
```

#### `ion-card` → `Card` Kustom

```dart
Card(
  elevation: 0,
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: BorderSide(color: Colors.grey[200]!, width: 0.5),
  ),
  child: /* content */,
)
```

#### `ion-toast` / `ion-alert` → `SnackBar` / `AlertDialog` Kustom

```dart
// Toast (SnackBar)
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("Pesan"),
    backgroundColor: IonicColors.dark,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(16),
  ),
);

// Alert Dialog
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    title: Text("Konfirmasi", style: IonicTheme.ionTitle),
    content: Text("Pesan", style: IonicTheme.ionSubtitle),
    actions: [
      TextButton(
        child: Text("Batal", style: TextStyle(color: IonicColors.medium)),
        onPressed: () => Navigator.pop(ctx),
      ),
      TextButton(
        child: Text("Hapus", style: TextStyle(color: IonicColors.danger)),
        onPressed: () { /* ... */ },
      ),
    ],
  ),
);
```

#### `ion-fab` → `FloatingActionButton` Kustom

```dart
FloatingActionButton(
  backgroundColor: IonicColors.primary,
  elevation: 4,
  shape: const CircleBorder(),
  child: const Icon(Icons.add, color: Colors.white),
  onPressed: () {},
)
```

---

## 3. Perubahan Per File

---

### 3.1 `main.dart`

**File:** [`main.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/main.dart)

#### Kondisi Saat Ini
- Masih berisi template counter default Flutter
- Tidak terhubung ke `LoginPage` atau `DashboardPage`

#### Perubahan Yang Harus Dilakukan

| No | Perubahan | Detail |
|----|-----------|--------|
| 1 | Hapus class `MyHomePage` dan `_MyHomePageState` | Tidak diperlukan lagi |
| 2 | Ubah `title` | Dari `'Flutter Demo'` → `'Pothole Report'` |
| 3 | Ubah `colorScheme` | Dari `Colors.deepPurple` → `Color(0xFF3880FF)` (Ionic Primary) |
| 4 | Tambah `ThemeData` global Ionic-like | Custom `appBarTheme`, `elevatedButtonTheme`, `inputDecorationTheme`, dll. |
| 5 | Set `home` ke `LoginPage()` | `home: const LoginPage()` |
| 6 | Tambah `routes` | `'/dashboard': (ctx) => DashboardPage()` |
| 7 | Import halaman | `import 'login_page.dart'` dan `import 'dashboard_page.dart'` |

#### Kode Refactor

```dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pothole Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ═══ Ionic-Like Theme ═══
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3880FF),
          primary: const Color(0xFF3880FF),
          secondary: const Color(0xFF3DC2FF),
          error: const Color(0xFFEB445A),
          surface: Colors.white,
          background: const Color(0xFFF0F0F0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),

        // AppBar Ionic-like
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF222428),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222428),
            letterSpacing: 0.15,
          ),
        ),

        // ElevatedButton Ionic-like
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3880FF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // InputDecoration Ionic-like
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF3880FF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFFEB445A), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFFEB445A), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF92949C)),
        ),

        // Card Ionic-like
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),

        // FloatingActionButton Ionic-like
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3880FF),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // SnackBar Ionic-like (toast)
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF222428),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}
```

---

### 3.2 `api_service.dart`

**File:** [`api_service.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/api_service.dart)

#### Perubahan Yang Harus Dilakukan

| No | Baris | Sebelum | Sesudah | Alasan |
|----|-------|---------|---------|--------|
| 1 | 43 | `fetchSampah()` | `fetchReports()` | Endpoint berubah ke `/reports` |
| 2 | 47 | `'$baseUrl/sampah'` | `'$baseUrl/reports'` | Sesuai BE |
| 3 | 53 | `deleteSampah(int id)` | `deleteReport(int id)` | Rename method |
| 4 | 57 | `'$baseUrl/sampah/$id'` | `'$baseUrl/reports/$id'` | Sesuai BE |
| 5 | 63 | `saveSampah(String nama, ...)` | `saveReport(String jalan, String levelKerusakan, ...)` | Field berubah |
| 6 | 69 | `'$baseUrl/sampah'` / `'$baseUrl/sampah/$id'` | `'$baseUrl/reports'` / `'$baseUrl/reports/$id'` | Sesuai BE |
| 7 | 74 | `request.fields['nama_sampah'] = nama` | `request.fields['jalan'] = jalan` + `request.fields['level_kerusakan'] = levelKerusakan` | Field baru |

#### Kode Refactor

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://192.168.18.12:3000";
  final String baseUrlNlp = "http://192.168.18.12:8000";

  Future<String> askChatbot(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlNlp/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        return "Maaf, server sedang sibuk.";
      }
    } catch (e) {
      return "Gagal terhubung ke chatbot.";
    }
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    }
    return null;
  }

  // ══════════════════════════════════════════
  // CHANGED: fetchSampah() → fetchReports()
  // Endpoint: GET /reports
  // ══════════════════════════════════════════
  Future<List> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  // ══════════════════════════════════════════
  // CHANGED: deleteSampah() → deleteReport()
  // Endpoint: DELETE /reports/:id
  // ══════════════════════════════════════════
  Future<void> deleteReport(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await http.delete(
      Uri.parse('$baseUrl/reports/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // ══════════════════════════════════════════
  // CHANGED: saveSampah() → saveReport()
  // Fields: jalan, level_kerusakan, pic
  // Endpoint: POST /reports atau PUT /reports/:id
  // ══════════════════════════════════════════
  Future<bool> saveReport(
    String jalan,
    String levelKerusakan,
    File? image, {
    int? id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse(id == null ? '$baseUrl/reports' : '$baseUrl/reports/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['jalan'] = jalan;
    request.fields['level_kerusakan'] = levelKerusakan;
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'pic',
          image.path,
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode == 201 || response.statusCode == 200;
  }
}
```

---

### 3.3 `login_page.dart`

**File:** [`login_page.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/login_page.dart)

#### Perubahan Yang Harus Dilakukan

| No | Aspek | Sebelum | Sesudah |
|----|-------|---------|---------|
| 1 | Gradient | Hijau `0xFF2E7D32` → `0xFF81C784` | Biru Ionic `0xFF3880FF` → `0xFF4C8DFF` |
| 2 | Ikon | `Icons.recycling` | `Icons.report_problem_rounded` |
| 3 | Judul | `"BANK SAMPAH"` | `"POTHOLE REPORT"` |
| 4 | Subtitle | `"Kelola sampah jadi berkah"` | `"Laporkan jalan berlubang di sekitarmu"` |
| 5 | Tombol Login biasa | `backgroundColor: Color(0xFF2E7D32)` | `backgroundColor: IonicColors.primary` (`0xFF3880FF`) |
| 6 | Tombol Face Login | `backgroundColor: Colors.blueAccent` | `backgroundColor: IonicColors.secondary` (`0xFF3DC2FF`) |
| 7 | Border radius form | `Radius.circular(40)` | `Radius.circular(20)` (lebih Ionic) |
| 8 | Input fields | Menggunakan `border: OutlineInputBorder(borderRadius: 15)` | Ikut global `InputDecorationTheme` Ionic (radius 8) |
| 9 | Tombol shape | `borderRadius: 15` | `borderRadius: 8` (Ionic) |
| 10 | Tombol elevation | `elevation: 5` | `elevation: 0` (Ionic flat) |

#### Highlight Kode Ionic-Like

```dart
// ═══ GRADIENT HEADER ═══
Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3880FF), Color(0xFF4C8DFF)], // Ionic Blue
    ),
  ),
  // ...
)

// ═══ IKON & BRANDING ═══
const Icon(Icons.report_problem_rounded, size: 80, color: Colors.white),
const Text("POTHOLE REPORT", style: TextStyle(
  color: Colors.white, fontSize: 28,
  fontWeight: FontWeight.bold, letterSpacing: 2,
)),
const Text("Laporkan jalan berlubang di sekitarmu",
  style: TextStyle(color: Colors.white70, fontSize: 16),
),

// ═══ FORM CONTAINER ═══
Container(
  decoration: const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),   // Ionic: lebih kecil
      topRight: Radius.circular(20),
    ),
  ),
  // ...
)

// ═══ TOMBOL MASUK (Ionic Primary) ═══
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3880FF),  // Ionic Primary
    elevation: 0,                               // Flat
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),   // Ionic radius
    ),
  ),
  child: const Text("MASUK"),
)

// ═══ TOMBOL FACE LOGIN (Ionic Secondary) ═══
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF3DC2FF),  // Ionic Secondary
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text("MASUK DENGAN PENGENALAN WAJAH"),
)
```

---

### 3.4 `dashboard_page.dart`

**File:** [`dashboard_page.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/dashboard_page.dart)

Ini adalah file dengan perubahan **paling banyak** karena harus menyesuaikan domain dari `sampah` ke `reports` sekaligus menerapkan tema Ionic.

#### Perubahan Domain (Backend-driven)

| No | Baris | Sebelum | Sesudah |
|----|-------|---------|---------|
| 1 | 5 | `import 'sampah_form_page.dart'` | `import 'report_form_page.dart'` |
| 2 | 13 | `List allSampah = []` | `List allReports = []` |
| 3 | 14 | `List filteredSampah = []` | `List filteredReports = []` |
| 4 | 17 | `ApiService().fetchSampah()` | `ApiService().fetchReports()` |
| 5 | 19 | `allSampah = data` | `allReports = data` |
| 6 | 20 | `filteredSampah = data` | `filteredReports = data` |
| 7 | 26-31 | Filter by `nama_sampah` | Filter by `jalan` |
| 8 | 84 | `ApiService().deleteSampah(id)` | `ApiService().deleteReport(id)` |
| 9 | 112-113 | `"Bank Sampah"` | `"Pothole Reports"` |
| 10 | 136 | `"Cari jenis sampah..."` | `"Cari nama jalan..."` |
| 11 | 150 | `filteredSampah.length` | `filteredReports.length` |
| 12 | 152 | `filteredSampah[index]` | `filteredReports[index]` |
| 13 | 174-177 | `Icons.recycling` + green | `Icons.warning_amber` + orange (Ionic warning) |
| 14 | 181 | `item['nama_sampah']` | `Text(item['jalan'])` + subtitle `item['level_kerusakan']` |
| 15 | 197 | `SampahFormPage(sampah: item)` | `ReportFormPage(report: item)` |
| 16 | 209 | `item['nama_sampah']` | `item['jalan']` |
| 17 | 243 | `SampahFormPage()` | `ReportFormPage()` |

#### Perubahan Tema Ionic-Like

| No | Komponen | Sebelum | Sesudah |
|----|----------|---------|---------|
| 1 | `AppBar` | `backgroundColor: Colors.white` (plain) | Ionic toolbar style (white, elevation 0.5, bottom border) |
| 2 | Search `TextField` | `borderRadius: 15` | `borderRadius: 8` + Ionic input style |
| 3 | `Card` | `borderRadius: 15` | `borderRadius: 10` + Ionic card (border tipis, shadow 0) |
| 4 | `ListView` item | Single line (`nama_sampah`) | Two lines: `jalan` (title) + `level_kerusakan` (subtitle dengan badge/chip) |
| 5 | FAB Add | `backgroundColor: Colors.green` | `backgroundColor: IonicColors.primary` (`0xFF3880FF`) |
| 6 | FAB Chat | `backgroundColor: Colors.blueAccent` | `backgroundColor: IonicColors.secondary` (`0xFF3DC2FF`) |
| 7 | Delete icon | `Colors.red` | `IonicColors.danger` (`0xFFEB445A`) |
| 8 | Edit icon | `Colors.blue` | `IonicColors.primary` (`0xFF3880FF`) |
| 9 | Placeholder icon | `Icons.recycling` + green | `Icons.warning_amber_rounded` + `IonicColors.warning` |

#### Tambahan: Badge Level Kerusakan

Untuk menampilkan `level_kerusakan`, buat widget chip/badge sederhana:

```dart
Widget _buildLevelBadge(String level) {
  Color badgeColor;
  switch (level.toLowerCase()) {
    case 'ringan':
      badgeColor = const Color(0xFF2DD36F); // Ionic success/green
      break;
    case 'sedang':
      badgeColor = const Color(0xFFFFC409); // Ionic warning/yellow
      break;
    case 'berat':
      badgeColor = const Color(0xFFEB445A); // Ionic danger/red
      break;
    default:
      badgeColor = const Color(0xFF92949C); // Ionic medium/grey
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: badgeColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      level.toUpperCase(),
      style: TextStyle(
        color: badgeColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
}
```

#### Contoh List Item Refactored

```dart
Card(
  // Menggunakan global CardTheme dari main.dart
  child: ListTile(
    contentPadding: const EdgeInsets.all(12),
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: item['pic'] != null
          ? Image.network(
              "http://192.168.18.12:3000/uploads/${item['pic']}",
              width: 60, height: 60, fit: BoxFit.cover,
            )
          : Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC409).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFFC409),
              ),
            ),
    ),
    title: Text(
      item['jalan'],
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 6),
      child: _buildLevelBadge(item['level_kerusakan'] ?? 'unknown'),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Color(0xFF3880FF)),
          onPressed: () { /* navigate to ReportFormPage */ },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFEB445A)),
          onPressed: () => _confirmDelete(item['id'], item['jalan']),
        ),
      ],
    ),
  ),
)
```

---

### 3.5 `report_form_page.dart`

**File baru** — rename dari [`sampah_form_page.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/sampah_form_page.dart)

#### Perubahan Yang Harus Dilakukan

| No | Aspek | Sebelum | Sesudah |
|----|-------|---------|---------|
| 1 | Nama file | `sampah_form_page.dart` | `report_form_page.dart` |
| 2 | Nama class | `SampahFormPage` | `ReportFormPage` |
| 3 | Parameter | `Map? sampah` | `Map? report` |
| 4 | State class | `_SampahFormPageState` | `_ReportFormPageState` |
| 5 | Controller | 1 controller (`_controller` untuk `nama_sampah`) | 2 controller: `_jalanController` + `_levelController` |
| 6 | `initState` | `_controller.text = widget.sampah!['nama_sampah']` | `_jalanController.text = widget.report!['jalan']` + `_levelController = widget.report!['level_kerusakan']` |
| 7 | Label form | "Nama Sampah" | "Nama Jalan" |
| 8 | Judul section | "Informasi Sampah" | "Informasi Jalan Berlubang" |
| 9 | Label foto | "Foto Sampah" | "Foto Kerusakan" |
| 10 | Input baru | — | Tambah `DropdownButtonFormField` untuk `level_kerusakan` |
| 11 | `saveSampah()` | `ApiService().saveSampah(nama, image, id: ...)` | `ApiService().saveReport(jalan, level, image, id: ...)` |
| 12 | Tombol warna | `Colors.green` | `IonicColors.primary` (`0xFF3880FF`) |
| 13 | AppBar | Default Material | Ionic toolbar style |

#### Input Level Kerusakan (Dropdown Ionic-Like)

```dart
// Dropdown untuk level_kerusakan
DropdownButtonFormField<String>(
  value: _selectedLevel,
  decoration: const InputDecoration(
    labelText: "Level Kerusakan",
    prefixIcon: Icon(Icons.speed, color: Color(0xFF92949C)),
  ),
  items: const [
    DropdownMenuItem(value: "Ringan", child: Text("Ringan")),
    DropdownMenuItem(value: "Sedang", child: Text("Sedang")),
    DropdownMenuItem(value: "Berat",  child: Text("Berat")),
  ],
  validator: (value) =>
      value == null || value.isEmpty ? "Level harus dipilih" : null,
  onChanged: (val) => setState(() => _selectedLevel = val),
)
```

#### Kode Refactor Lengkap

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class ReportFormPage extends StatefulWidget {
  final Map? report; // null = insert, isi = update
  const ReportFormPage({super.key, this.report});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _jalanController = TextEditingController();
  String? _selectedLevel;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _jalanController.text = widget.report!['jalan'] ?? '';
      _selectedLevel = widget.report!['level_kerusakan'];
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil gambar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? "Tambah Laporan" : "Edit Laporan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Jalan Berlubang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // ═══ Input: Nama Jalan ═══
              TextFormField(
                controller: _jalanController,
                decoration: const InputDecoration(
                  labelText: "Nama Jalan",
                  prefixIcon: Icon(Icons.location_on_outlined,
                      color: Color(0xFF92949C)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Nama jalan harus diisi"
                    : null,
              ),
              const SizedBox(height: 20),

              // ═══ Input: Level Kerusakan (Dropdown) ═══
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: "Level Kerusakan",
                  prefixIcon:
                      Icon(Icons.speed, color: Color(0xFF92949C)),
                ),
                items: const [
                  DropdownMenuItem(value: "Ringan", child: Text("Ringan")),
                  DropdownMenuItem(value: "Sedang", child: Text("Sedang")),
                  DropdownMenuItem(value: "Berat", child: Text("Berat")),
                ],
                validator: (value) => value == null || value.isEmpty
                    ? "Level harus dipilih"
                    : null,
                onChanged: (val) => setState(() => _selectedLevel = val),
              ),
              const SizedBox(height: 20),

              // ═══ Foto Kerusakan ═══
              const Text(
                "Foto Kerusakan",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40,
                                color: Color(0xFF92949C)),
                            SizedBox(height: 8),
                            Text("Ketuk untuk memilih foto",
                                style: TextStyle(color: Color(0xFF92949C))),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),

              // ═══ Tombol Simpan ═══
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await ApiService().saveReport(
                        _jalanController.text,
                        _selectedLevel!,
                        _image,
                        id: widget.report?['id'],
                      );
                      if (success) {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Laporan berhasil disimpan")),
                        );
                      }
                    }
                  },
                  child: const Text("SIMPAN LAPORAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 3.6 `chat_page.dart`

**File:** [`chat_page.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/chat_page.dart)

#### Perubahan Yang Harus Dilakukan

| No | Aspek | Sebelum | Sesudah |
|----|-------|---------|---------|
| 1 | AppBar title | `"Tanya Bank Sampah"` | `"Tanya Pothole AI"` |
| 2 | AppBar color | `Colors.green[700]` | Ikut theme (putih, Ionic toolbar) |
| 3 | Chat bubble user | `Colors.green[100]` | `Color(0xFF3880FF).withOpacity(0.12)` (Ionic primary tint) |
| 4 | Chat bubble bot | `Colors.grey[200]` | `Color(0xFFF4F5F8)` (Ionic light) |
| 5 | `LinearProgressIndicator` | `color: Colors.green` | `color: Color(0xFF3880FF)` (Ionic primary) |
| 6 | Send FAB | `backgroundColor: Colors.green` | `backgroundColor: Color(0xFF3880FF)` (Ionic primary) |
| 7 | Input border radius | `25` | `20` |
| 8 | TextField hint | `"Tanya sesuatu..."` | `"Tanyakan tentang jalan berlubang..."` |

---

## 4. File Yang Dihapus / Tidak Dipakai

| File | Status | Keterangan |
|------|--------|------------|
| [`sampah_form_page.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/sampah_form_page.dart) | **HAPUS / RENAME** | Diganti menjadi `report_form_page.dart` |
| [`login.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/login.dart) | **HAPUS** | Duplikat dari `login_page.dart` (konten hampir identik, versi lama) |
| [`main copy.dart`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/lib/main%20copy.dart) | **HAPUS** | File copy yang tidak diperlukan |

---

## 5. Catatan Tambahan

### 5.1 Tidak Perlu Package Tambahan

Semua styling Ionic-like di atas dicapai **murni** dengan:
- `ThemeData` global di `main.dart`
- Widget bawaan Flutter: `AppBar`, `ElevatedButton`, `TextFormField`, `Card`, `ListTile`, `SnackBar`, `AlertDialog`, `FloatingActionButton`
- Konstanta warna custom (`IonicColors`)

**Tidak ada** package UI framework tambahan yang diperlukan.

### 5.2 Mapping Komponen Ionic ↔ Flutter

| Ionic Component | Flutter Widget | Catatan |
|----------------|----------------|---------|
| `<ion-header>` + `<ion-toolbar>` | `AppBar` | White bg, elevation 0.5, center title |
| `<ion-content>` | `Scaffold.body` | `backgroundColor: IonicColors.background` |
| `<ion-item>` | `ListTile` + `Container` | Border bottom tipis |
| `<ion-input>` | `TextFormField` | Border radius 8, focus border primary |
| `<ion-button>` | `ElevatedButton` | Flat (elevation 0), radius 8 |
| `<ion-card>` | `Card` | Elevation 0, border tipis, radius 10 |
| `<ion-fab>` | `FloatingActionButton` | Circle shape, Ionic primary |
| `<ion-toast>` | `SnackBar` | Floating, dark bg, radius 8 |
| `<ion-alert>` | `AlertDialog` | Radius 14, action text berwarna |
| `<ion-badge>` | Custom `Container` | Rounded, bg opacity, bold text |
| `<ion-select>` | `DropdownButtonFormField` | Ikut input theme |
| `<ion-spinner>` | `CircularProgressIndicator` | Color primary |
| `<ion-searchbar>` | `TextField` + search icon | Filled, radius 8 |

### 5.3 Skema Database Yang Diperlukan

Pastikan tabel MySQL sudah diperbarui sesuai backend:

```sql
CREATE TABLE IF NOT EXISTS reports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  jalan VARCHAR(255) NOT NULL,
  level_kerusakan VARCHAR(50) NOT NULL,
  pic VARCHAR(255)
);
```

### 5.4 Checklist Refactor

- [ ] Buat file `ionic_theme.dart` (opsional, bisa inline di `main.dart`)
- [ ] Refactor `main.dart` — theme + routing
- [ ] Refactor `api_service.dart` — endpoint + field
- [ ] Refactor `login_page.dart` — branding + warna Ionic
- [ ] Refactor `dashboard_page.dart` — domain + UI Ionic
- [ ] Buat `report_form_page.dart` (rename + refactor dari `sampah_form_page.dart`)
- [ ] Refactor `chat_page.dart` — branding + warna Ionic
- [ ] Hapus file lama: `sampah_form_page.dart`, `login.dart`, `main copy.dart`
- [ ] Test: Login email/password
- [ ] Test: Login face recognition
- [ ] Test: CRUD reports (create, read, update, delete)
- [ ] Test: Chat NLP
- [ ] Test: Search/filter reports by nama jalan

---

> [!NOTE]
> Dokumen ini adalah **panduan refactor UI** yang menyelaraskan sisi Flutter dengan perubahan backend di [`BE.md`](file:///c:/Users/sabil/belajar-flutter/pothole_uas_app/BE.md). Semua perubahan menggunakan **vanilla Flutter** tanpa package UI framework tambahan, dengan tema visual **Ionic-like** yang dicapai melalui kustomisasi `ThemeData` dan widget Material bawaan.
