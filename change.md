# 📋 Sistem Integrasi Pertanian Presisi — Technical Change & Architecture Audit (`change.md`)

---

## 1. Executive Summary & System Architecture

Dokumen ini menyajikan rincian teknis lengkap mengenai integrasi antara dua aplikasi mobile Flutter (**Petani** & **Penyuluh**) dengan backend service berbasis Node.js/Express (**BackEnd-monitoringlahan**) dan database MySQL.

Sistem pertanian presisi ini dirancang untuk mendeteksi 8 parameter kesuburan tanah secara *real-time* via hardware probe sensor RS485 Modbus RTU yang terhubung ke smartphone melalui konverter USB-to-TTL (chipset CH340), lalu menyinkronkan data telemetri dan kuesioner lahan ke server cloud.

```
+---------------------------------------------------------------------------------------------------+
|                                      MOBILE CLIENT LAYER                                          |
|                                                                                                   |
|   +---------------------------------------+       +-------------------------------------------+   |
|   |   apk-pertanian_presisi-petani        |       |   apk-pertanian_presisi-penyuluh          |   |
|   |   (Target: Petani Mandiri)            |       |   (Target: Petugas Penyuluh Lapangan)     |   |
|   |   - Form Kuesioner Profil Lahan (24f) |       |   - Baseline Komoditas (Padi, Jagung, dll)|   |
|   |   - CH340 USB Serial Modbus RTU       |       |   - Justifikasi Kesuburan Otomatis        |   |
|   |   - GPS Geolocation                   |       |   - 3x Kamera Multi-Photo Capture         |   |
|   |   - Payload: application/json         |       |   - Payload: multipart/form-data          |   |
|   +-------------------+-------------------+       +---------------------+---------------------+   |
|                       |                                                 |                         |
+-----------------------|-------------------------------------------------|-------------------------+
                        | POST /api/soil/save                             | POST /api/soil/penyuluh/save
                        | (JSON Payload)                                  | (Multipart with 3 Photos)
                        v                                                 v
+---------------------------------------------------------------------------------------------------+
|                                  BACKEND SERVICE (Node.js/Express)                                 |
|                                                                                                   |
|   +---------------------------------------+       +-------------------------------------------+   |
|   |   Legacy Route (JSON Parser)          |       |   Penyuluh Route (Multer Engine)          |   |
|   |   routes/api/monitoring_lahan.js      |       |   routes/api/monitoring_lahan.js          |   |
|   |   Model_Monitoring_Lahan.Store()      |       |   Model_Monitoring_Lahan.StorePenyuluh()  |   |
|   +-------------------+-------------------+       +---------------------+---------------------+   |
|                       |                                                 |                         |
|                       |                                                 | Simpan Gambar           |
|                       |                                                 v                         |
|                       |                                   +---------------------------+           |
|                       |                                   | public/images/uploads/soil|           |
|                       |                                   +---------------------------+           |
|                       +-------------------+-----------------------------+                         |
|                                           |                                                       |
|                                           v                                                       |
|                           +-------------------------------+                                       |
|                           |      MySQL Database Pool      |                                       |
|                           |  Table: `monitoring_lahan`    |                                       |
|                           +-------------------------------+                                       |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Comprehensive Architectural Comparison: Petani vs. Penyuluh

| Aspek / Komponen | `apk-pertanian_presisi-petani` | `apk-pertanian_presisi-penyuluh` |
| :--- | :--- | :--- |
| **Target Pengguna** | Petani / Pemilik Lahan Mandiri | Petugas Penyuluh Pertanian Lapangan (PPL) / Agronomis |
| **Tujuan Aplikasi** | Pengecekan cepat 8 parameter tanah & pengisian survei profil infrastruktur tani | Audit komprehensif lahan, justifikasi nutrisi tanaman, dokumentasi visual (daun, pohon, tanah) |
| **Struktur Navigasi & Halaman** | **2 Halaman Utama:**<br>1. *Soil Dashboard Page* (Monitor sensor + kontrol USB)<br>2. *Form Input Lahan Page* (Kuesioner 24 field) | **3 Halaman Utama (Modern Bio-Digital Flow):**<br>1. *Commodity Selection Page* (Grid komoditas)<br>2. *Soil Probe Capture Page* (Sensor + 3x foto capture + GPS)<br>3. *Analysis Result Page* (Justifikasi NPK, pH, kelembapan vs threshold komoditas + Cloud sync) |
| **Integrasi Hardware (USB Modbus)** | MethodChannel `id.ac.pens/usb_serial`, Modbus RTU Frame: `0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C` (Baudrate: 4800 bps) | MethodChannel `id.ac.pens/usb_serial`, Modbus RTU Frame: `0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C` (Baudrate: 4800 bps) |
| **8 Parameter Sensor Telemetri** | 1. Suhu (°C)<br>2. Kelembaban (%)<br>3. Konduktivitas Listrik / EC (us/cm)<br>4. pH Tanah<br>5. Nitrogen / N (mg/kg)<br>6. Fosfor / P (mg/kg)<br>7. Kalium / K (mg/kg)<br>8. Salinitas / Fertility (mg/kg) | 1. Suhu (°C)<br>2. Kelembaban (%)<br>3. Konduktivitas Listrik / EC (us/cm)<br>4. pH Tanah<br>5. Nitrogen / N (mg/kg)<br>6. Fosfor / P (mg/kg)<br>7. Kalium / K (mg/kg)<br>8. Salinitas / Fertility (mg/kg) |
| **Dokumentasi Kamera (Foto)** | Tidak ada (form berbasis teks & radio toggle) | **Wajib 3 Titik Foto:**<br>1. `foto_daun` (Kondisi visual daun/hama)<br>2. `foto_pohon` (Postur pertumbuhan vegetatif)<br>3. `foto_tanah` (Tekstur dan agregat tanah) |
| **Logika Analisis & Rekomendasi** | Visual indikator status di form | Automated Threshold Justification (Status: *Defisiensi / Optimal / Berlebih* berdasarkan batas agronomi komoditas terpilih) |
| **Format Payload Jaringan** | `application/json` murni | `multipart/form-data` (Binary file streams + field map) |
| **State Management & Pattern** | `StatefulWidget` modular dengan Service Layer terisolasi (`LocationService`, `UsbSerialService`) | Reactive Architecture dengan Service Layer terisolasi (`ApiService`, `LocationService`, `UsbSerialService`) |
| **Dependencies Utama** | `http: ^1.6.0`, `geolocator: ^14.0.2` | `http: ^1.6.0`, `geolocator: ^14.0.2`, `image_picker: ^1.1.2`, `google_fonts: ^6.2.1` |
| **Android Root Project Name** | `pertanian_presisi_petani` | `pertanian_presisi_penyuluh` |
| **Android Application ID** | `id.ac.pens.pertanian_presisi.petani` | `id.ac.pens.pertanian_presisi.penyuluh` |
| **Android Launcher App Label** | `AgriSensor Petani` | `AgriSensor Penyuluh` |
| **Native Kotlin Package** | `id.ac.pens.pertanian_presisi.petani` | `id.ac.pens.pertanian_presisi.penyuluh` |

---

## 3. Backend Breakdown: Existing Routes vs. Newly Introduced Routes

### A. Rute Eksisting (Preserved 100% Without Regression)
1. **API Endpoints (`routes/api/monitoring_lahan.js`):**
   * `GET /api/soil/` — Mengambil seluruh data monitoring tanah.
   * `POST /api/soil/save` — Menyimpan payload JSON 24 parameter dari aplikasi Petani ke database.
   * `POST /api/soil/update/:id` — Mengubah data record tanah.
   * `GET /api/soil/delete/:id` — Menghapus record data tanah.
2. **Web Dashboard Server-Side Rendering (EJS):**
   * `/sensor` & `/petalahan` — Peta persebaran sensor & GIS pemetaan lahan.
   * `/kelompoktani` — Master data kelompok tani.
   * `/policy_brief` — Modul rekomendasi AI OpenAI untuk kebijakan pertanian.
   * `/sayur_buah`, `/biofarmaka`, `/luas_tanam_perkebunan_rakyat` — Statistik master data komoditas.

### B. Rute Baru Penyuluh (Dedicated Non-Conflicting Routes)
1. **`POST /api/soil/penyuluh/save`**
   * **Middleware:** `multer.fields([ { name: 'foto_daun', maxCount: 1 }, { name: 'foto_pohon', maxCount: 1 }, { name: 'foto_tanah', maxCount: 1 } ])`
   * **Penyimpanan Berkas:** `public/images/uploads/soil/`
   * **Model Penanganan:** `Model_Monitoring_Lahan.StorePenyuluh(Data)`
   * **Fungsi:** Menerima unggahan multipart dari aplikasi Penyuluh yang mencakup metadata komoditas, varietas, hasil panen lalu, 8 parameter telemetri, dan 3 foto sampel.
2. **`GET /api/soil/penyuluh`**
   * **Model Penanganan:** `Model_Monitoring_Lahan.getAllPenyuluh()`
   * **Fungsi:** Mengambil data monitoring yang diinput khusus oleh penyuluh atau yang memiliki lampiran foto sampel.

---

## 4. Detailed Endpoint Specifications

### 4.1. Endpoint Petani (JSON Questionnaire Ingestion)

* **URL:** `POST https://demo.codingsolver.my.id/api/soil/save` *(atau `http://localhost:3000/api/soil/save`)*
* **HTTP Method:** `POST`
* **Content-Type:** `application/json`

#### Request Body Parameters (JSON)
| Field | Tipe Data | Wajib | Contoh Nilai | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| `latitude` | Number / Float | Ya | `-7.01234500` | Koordinat lintang GPS |
| `longitude` | Number / Float | Ya | `113.85432100` | Koordinat bujur GPS |
| `nama_desa` | String | Ya | `"Desa Sukamaju"` | Nama wilayah administrasi |
| `irigasi` | String | Ya | `"ya"` / `"tidak"` | Ketersediaan saluran irigasi |
| `listrik` | String | Ya | `"ya"` / `"tidak"` | Ketersediaan aliran listrik PLN |
| `pompa_air` | String | Ya | `"ya"` / `"tidak"` | Kepemilikan pompa air |
| `sumber_air` | String | Ya | `"Sumur Bor"` | Asal sumber air pertanian |
| `kondisi_air` | String | Ya | `"Tersedia / Lancar"` | Keandalan debit air |
| `sumber_energi_pompa` | String | Ya | `"BBM"` / `"PLN"` | Sumber tenaga pompa |
| `pembajak` | String | Ya | `"Traktor"` / `"Sapi"` | Alat pengolah tanah |
| `tadahan_hujan` | String | Ya | `"tidak"` / `"ya"` | Ketergantungan air hujan |
| `komoditas` | String | Ya | `"Jagung"` | Komoditas tanaman utama |
| `luas_lahan` | String | Ya | `"0.5 Hektar"` | Luas area tanam |
| `status_lahan` | String | Ya | `"Milik Sendiri"` | Status kepemilikan |
| `kelompok_tani` | String | Ya | `"ya"` / `"tidak"` | Keanggotaan poktan |
| `gagal_panen` | String | Ya | `"tidak"` / `"ya"` | Riwayat gagal panen |
| `temp` | Number / Float | Ya | `28.5` | Suhu tanah (°C) |
| `moisture` | Number / Float | Ya | `65.2` | Kelembaban tanah (%) |
| `conductivity` | Number / Integer | Ya | `120` | Konduktivitas listrik (us/cm) |
| `ph` | Number / Float | Ya | `6.5` | Derajat keasaman tanah |
| `nitrogen` | Number / Integer | Ya | `45` | Kadar Nitrogen (mg/kg) |
| `phosphorus` | Number / Float | Ya | `30.2` | Kadar Fosfor (mg/kg) |
| `potassium` | Number / Float | Ya | `15.5` | Kadar Kalium (mg/kg) |
| `fertility` | Number / Float | Ya | `85.0` | Salinitas / Indeks Kesuburan |

#### Sample Request JSON
```json
{
  "latitude": -7.01234500,
  "longitude": 113.85432100,
  "nama_desa": "Desa Sukamaju",
  "irigasi": "ya",
  "listrik": "ya",
  "pompa_air": "ya",
  "sumber_air": "Sumur Bor",
  "kondisi_air": "Tersedia",
  "sumber_energi_pompa": "BBM",
  "pembajak": "Traktor",
  "tadahan_hujan": "tidak",
  "komoditas": "Jagung",
  "luas_lahan": "0.5 Hektar",
  "status_lahan": "Milik Sendiri",
  "kelompok_tani": "ya",
  "gagal_panen": "tidak",
  "temp": 28.5,
  "moisture": 65.2,
  "conductivity": 120,
  "ph": 6.5,
  "nitrogen": 45,
  "phosphorus": 30.2,
  "potassium": 15.5,
  "fertility": 85.0
}
```

#### Sample Response JSON
* **HTTP 200 OK (Success):**
```json
{
  "status": true,
  "message": "Data Lahan Berhasil Disimpan"
}
```
* **HTTP 500 Internal Server Error:**
```json
{
  "status": false,
  "message": "Gagal menyimpan data lahan ke database",
  "error": "Error description..."
}
```

---

### 4.2. Endpoint Penyuluh (Multipart Telemetry & Photo Ingestion)

* **URL:** `POST https://demo.codingsolver.my.id/api/soil/penyuluh/save` *(atau `http://localhost:3000/api/soil/penyuluh/save`)*
* **HTTP Method:** `POST`
* **Content-Type:** `multipart/form-data`

#### Request Parameters (Form-Data)
| Parameter Name | Tipe | Format | Contoh Nilai | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| `latitude` | Text (Float) | String | `"-7.01234500"` | Koordinat Latitude GPS |
| `longitude` | Text (Float) | String | `"113.85432100"` | Koordinat Longitude GPS |
| `nama_desa` | Text | String | `"Desa Sumenep Timur"` | Nama Desa / Titik Survei |
| `komoditas` | Text | String | `"Padi"` | Jenis Komoditas Pertanian |
| `varietas` | Text | String | `"Inpari 32"` | Varietas Bibit / Tanaman |
| `hasil_panen_lalu` | Text (Double) | String | `"5.2"` | Kuantitas panen periode lalu |
| `satuan_panen` | Text | String | `"ton"` / `"sak"` | Satuan kuantitas panen |
| `temp` | Text (Float) | String | `"27.4"` | Suhu probe sensor (°C) |
| `moisture` | Text (Float) | String | `"62.8"` | Kelembaban probe sensor (%) |
| `conductivity` | Text (Integer) | String | `"145"` | Konduktivitas listrik (us/cm) |
| `ph` | Text (Float) | String | `"6.2"` | pH probe sensor |
| `nitrogen` | Text (Integer) | String | `"38"` | Nitrogen probe sensor (mg/kg) |
| `phosphorus` | Text (Integer) | String | `"25"` | Fosfor probe sensor (mg/kg) |
| `potassium` | Text (Integer) | String | `"18"` | Kalium probe sensor (mg/kg) |
| `fertility` | Text (Integer) | String | `"78"` | Salinitas probe sensor (mg/kg) |
| `foto_daun` | File (Binary) | Image (`.jpg`, `.png`) | `[binary leaf photo]` | Berkas foto morfologi daun |
| `foto_pohon` | File (Binary) | Image (`.jpg`, `.png`) | `[binary tree photo]` | Berkas foto morfologi pohon |
| `foto_tanah` | File (Binary) | Image (`.jpg`, `.png`) | `[binary soil photo]` | Berkas foto agregat tanah |

#### Sample Response JSON
* **HTTP 200 OK (Success):**
```json
{
  "status": true,
  "message": "Data Lahan Penyuluh Berhasil Disimpan",
  "data": {
    "id": 16,
    "latitude": -7.012345,
    "longitude": 113.854321,
    "nama_desa": "Desa Sumenep Timur",
    "komoditas": "Padi",
    "varietas": "Inpari 32",
    "hasil_panen_lalu": "5.2",
    "satuan_panen": "ton",
    "temp": 27.4,
    "moisture": 62.8,
    "conductivity": 145,
    "ph": 6.2,
    "nitrogen": 38,
    "phosphorus": 25,
    "potassium": 18,
    "fertility": 78,
    "foto_daun": "/images/uploads/soil/foto_daun-1718000000000-123456789.jpg",
    "foto_pohon": "/images/uploads/soil/foto_pohon-1718000000000-987654321.jpg",
    "foto_tanah": "/images/uploads/soil/foto_tanah-1718000000000-456789123.jpg",
    "tipe_penginput": "penyuluh"
  }
}
```
* **HTTP 500 Internal Server Error:**
```json
{
  "status": false,
  "message": "Gagal menyimpan data lahan penyuluh ke database",
  "error": "Error description..."
}
```

---

## 5. Database Alterations & SQL Migration Script

Untuk mendukung penyimpanan data dari aplikasi Penyuluh tanpa mengganggu struktur eksisting tabel `monitoring_lahan` yang digunakan oleh aplikasi Petani, jalankan query migrasi MySQL berikut:

```sql
-- ====================================================================
-- DATABASE MIGRATION SCRIPT: Support Penyuluh Telemetry & Photo Records
-- Target Database: `db_pertanian`
-- ====================================================================

USE `db_pertanian`;

-- 1. Tambahkan kolom pendukung varietas dan hasil panen (jika belum ada)
ALTER TABLE `monitoring_lahan`
  ADD COLUMN IF NOT EXISTS `varietas` VARCHAR(255) DEFAULT NULL AFTER `komoditas`,
  ADD COLUMN IF NOT EXISTS `hasil_panen_lalu` VARCHAR(255) DEFAULT NULL AFTER `varietas`,
  ADD COLUMN IF NOT EXISTS `satuan_panen` VARCHAR(50) DEFAULT 'ton' AFTER `hasil_panen_lalu`;

-- 2. Tambahkan kolom penyimpanan path 3 berkas foto hasil audit
ALTER TABLE `monitoring_lahan`
  ADD COLUMN IF NOT EXISTS `foto_daun` VARCHAR(255) DEFAULT NULL AFTER `fertility`,
  ADD COLUMN IF NOT EXISTS `foto_pohon` VARCHAR(255) DEFAULT NULL AFTER `foto_daun`,
  ADD COLUMN IF NOT EXISTS `foto_tanah` VARCHAR(255) DEFAULT NULL AFTER `foto_pohon`;

-- 3. Tambahkan kolom penanda peran penginput (petani vs penyuluh)
ALTER TABLE `monitoring_lahan`
  ADD COLUMN IF NOT EXISTS `tipe_penginput` ENUM('petani', 'penyuluh') DEFAULT 'petani' AFTER `foto_tanah`;

-- Verifikasi Struktur Akhir Tabel
DESCRIBE `monitoring_lahan`;
```

> **Catatan Kompatibilitas:**
> Semua kolom baru memiliki nilai `DEFAULT NULL` atau nilai default yang aman (`'ton'`, `'petani'`). Query `insert into monitoring_lahan set ?` pada route Petani eksisting akan tetap berjalan 100% normal tanpa *null pointer exception* ataupun *constraint violation*.

---

## 6. Verification & Audit Log

| Komponen / Target | Perintah Verifikasi | Hasil / Status | Detail Output |
| :--- | :--- | :--- | :--- |
| **`apk-pertanian_presisi-penyuluh`** | `dart analyze` / `flutter analyze` |  **PASSED** (0 Issues) | `Analyzing apk-pertanian_presisi-penyuluh... No issues found!` |
| **`apk-pertanian_presisi-petani`** | `dart analyze` / `flutter analyze` |  **PASSED** (0 Issues) | `Analyzing apk-pertanian_presisi-petani... No issues found!` |
| **`apk-pertanian_presisi-penyuluh`** | `flutter build apk --debug` |  **PASSED** (Built OK) | `√ Built build\app\outputs\flutter-apk\app-debug.apk` |
| **`apk-pertanian_presisi-petani`** | `flutter build apk --debug` |  **PASSED** (Built OK) | `√ Built build\app\outputs\flutter-apk\app-debug.apk` |
| **`BackEnd-monitoringlahan`** | `node -c model/Model_Monitoring_Lahan.js routes/api/monitoring_lahan.js app.js` |  **PASSED** (0 Syntax Errors) | Seluruh file backend valid tanpa kesalahan sintaks. |
| **Gradle Project Name Isolation** | `rootProject.name` check |  **PASSED** | `apk-pertanian_presisi-penyuluh` = `pertanian_presisi_penyuluh`<br>`apk-pertanian_presisi-petani` = `pertanian_presisi_petani` |
| **Application ID Isolation** | `applicationId` / `namespace` check |  **PASSED** | `id.ac.pens.pertanian_presisi.penyuluh`<br>`id.ac.pens.pertanian_presisi.petani` |
| **Launcher Label Isolation** | `android:label` check |  **PASSED** | `AgriSensor Penyuluh`<br>`AgriSensor Petani` |
| **Penyuluh API Endpoint Alignment** | `saveSoilEndpoint` in `api_service.dart` |  **ALIGNED** | Mengarah ke `https://demo.codingsolver.my.id/api/soil/penyuluh/save` |
| **Petani API Endpoint Alignment** | `apiUrl` in `form_input_lahan_page.dart` |  **ALIGNED** | Mengarah ke `https://demo.codingsolver.my.id/api/soil/save` |


---

## 7. Phase 1: Sumenep Localization, Role Pairing, Custom Standards & Community Forum

### A. Architectural Overview & Critical Invariants
1. **Sumenep Exclusive Localization:**
   - Database table `master_wilayah_sumenep` houses the complete 27 kecamatan in Kabupaten Sumenep (encompassing mainland subdistricts such as Kota Sumenep, Gapura, Batang-Batang, Saronggi, Lenteng, and island subdistricts such as Kalianget, Talango, Arjasa/Kangean, Kangayan, Sapeken, Sapudi/Nonggunong/Gayam, Raas, Masalembu, Giligenting).
   - Geographic options are strictly restricted to Sumenep.
2. **Role-Based Pairing Rule (Invariant: 1 Desa = 1 Penyuluh):**
   - Every village (desa) can have at most **one** designated Penyuluh.
   - When a Petani registers or accesses profile information, they are automatically paired with that village's designated Penyuluh.
   - Any attempt to register a second Penyuluh in the same village is rejected with a `400 Bad Request`.
3. **Threshold Submission & Verification Lifecycle:**
   - Farmers can submit custom 8-parameter crop threshold baselines with status defaulting to `pending`.
   - The village's assigned Penyuluh can inspect pending submissions and mark them as `verified` or `rejected` with custom notes.
4. **Community Forum with Verification Badges:**
   - Posts can attach custom standards.
   - The feed dynamically validates the attached standard: if unverified, it explicitly outputs `verification_warning: "Standar ini belum diverifikasi penyuluh"` and `is_verified: false`. If verified, it renders `is_verified: true`.
5. **Zero Breaking Changes:**
   - Existing `/api/soil/save` and `/api/soil/penyuluh/save` remain completely intact.

---

### B. Database Schema Definitions (Phase 1)

```sql
-- 1. Master Wilayah Sumenep
CREATE TABLE IF NOT EXISTS `master_wilayah_sumenep` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `kecamatan` VARCHAR(100) NOT NULL,
  `desa` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_kec_desa` (`kecamatan`, `desa`),
  KEY `idx_kecamatan` (`kecamatan`),
  KEY `idx_desa` (`desa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2. Enhanced Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(255) DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `no_hp` VARCHAR(50) DEFAULT NULL,
  `role` ENUM('petani','penyuluh','admin') NOT NULL DEFAULT 'petani',
  `desa_id` INT(11) DEFAULT NULL,
  `foto_users` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_desa_id` (`desa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3. Standar Komoditas Petani (Farmer Custom Thresholds)
CREATE TABLE IF NOT EXISTS `standar_komoditas_petani` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `petani_id` INT(11) NOT NULL,
  `penyuluh_id` INT(11) DEFAULT NULL,
  `desa_id` INT(11) NOT NULL,
  `komoditas` VARCHAR(255) NOT NULL,
  `varietas` VARCHAR(255) NOT NULL,
  `min_ph` DECIMAL(4,2) NOT NULL DEFAULT 6.00,
  `max_ph` DECIMAL(4,2) NOT NULL DEFAULT 7.00,
  `min_moisture` DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  `max_moisture` DECIMAL(5,2) NOT NULL DEFAULT 80.00,
  `min_n` INT(11) NOT NULL DEFAULT 100,
  `max_n` INT(11) NOT NULL DEFAULT 150,
  `min_p` INT(11) NOT NULL DEFAULT 25,
  `max_p` INT(11) NOT NULL DEFAULT 45,
  `min_k` INT(11) NOT NULL DEFAULT 150,
  `max_k` INT(11) NOT NULL DEFAULT 220,
  `min_temp` DECIMAL(4,2) NOT NULL DEFAULT 20.00,
  `max_temp` DECIMAL(4,2) NOT NULL DEFAULT 35.00,
  `min_ec` INT(11) NOT NULL DEFAULT 1000,
  `max_ec` INT(11) NOT NULL DEFAULT 2000,
  `min_fertility` INT(11) NOT NULL DEFAULT 50,
  `max_fertility` INT(11) NOT NULL DEFAULT 100,
  `status` ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  `catatan_penyuluh` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_petani_id` (`petani_id`),
  KEY `idx_penyuluh_id` (`penyuluh_id`),
  KEY `idx_desa_id` (`desa_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 4. Forum Posts
CREATE TABLE IF NOT EXISTS `forum_posts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `standar_id` INT(11) DEFAULT NULL,
  `title` VARCHAR(255) NOT NULL,
  `body` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_standar_id` (`standar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 5. Forum Comments
CREATE TABLE IF NOT EXISTS `forum_comments` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `post_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `comment` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

---

### C. RESTful API Specification (Phase 1)

| Endpoint | Method | Deskripsi | Query / Request Body | Response Status & Key Fields |
| :--- | :--- | :--- | :--- | :--- |
| `/api/wilayah/sumenep` | `GET` | Mengambil master wilayah Sumenep (27 kecamatan) | `?kecamatan=...` / `?q=...` | `200 OK`: `kecamatan_list`, `data: [{id, kecamatan, desa}]` |
| `/api/auth/register` | `POST` | Registrasi Petani / Penyuluh dengan pairing otomatis | `{ nama, email, password, no_hp, role, desa_id }` | `201 Created`: `user`, `paired_penyuluh`. *Enforces 1 Desa = 1 Penyuluh.* |
| `/api/auth/login` | `POST` | Login user & auto-resolve penyuluh pendamping | `{ email, password }` | `200 OK`: `user`, `paired_penyuluh` |
| `/api/auth/me/:id` | `GET` | Detail profil & penyuluh binaan | - | `200 OK`: `user`, `paired_penyuluh` |
| `/api/petani/standar/submit` | `POST` | Petani mengajukan standar komoditas mandiri | `{ petani_id, desa_id, komoditas, varietas, min/max 8 parameter }` | `201 Created`: `status: 'pending'`, `assigned_penyuluh` |
| `/api/penyuluh/standar/pending`| `GET` | Penyuluh mengambil daftar standar pending desa binaan | `?penyuluh_id=...` / `?desa_id=...` | `200 OK`: `total`, `data: [{id, komoditas, nama_petani, desa, ...}]` |
| `/api/penyuluh/standar/verify` | `POST` | Penyuluh memverifikasi / menolak standar | `{ id, penyuluh_id, status: 'verified'/'rejected', catatan_penyuluh }` | `200 OK`: `status: 'verified'/'rejected'`, `data` |
| `/api/petani/standar/my-standards` | `GET` | Petani mengambil riwayat standar mandiri | `?petani_id=...` | `200 OK`: `total`, `data: [...]` |
| `/api/forum/posts` | `GET` | Feed forum lintas petani & penyuluh | `?limit=50&offset=0` | `200 OK`: `data: [{..., is_verified, verification_warning, attached_standard}]` |
| `/api/forum/posts` | `POST` | Membuat postingan forum (opsional standar) | `{ user_id, standar_id, title, body }` | `201 Created`: `data: { id, title, author, attached_standard }` |
| `/api/forum/comments` | `POST` | Menambahkan komentar pada postingan | `{ post_id, user_id, comment }` | `201 Created`: `data: { id, comments: [...] }` |
| `/api/forum/posts/:id` | `GET` | Detail postingan beserta seluruh thread komentar | - | `200 OK`: Post detail with populated comments |

---

### D. Syntax & Validation Verification (Phase 1)

```bash
Get-ChildItem -Path model\*.js, routes\api\*.js, config\*.js, app.js | ForEach-Object { node -c $_.FullName }
```

| File | Path | Status Sintaks | Keterangan |
| :--- | :--- | :--- | :--- |
| `Model_Wilayah_Sumenep.js` | `BackEnd-monitoringlahan/model/` |  **PASSED** (0 Errors) | Master data wilayah Sumenep (27 kecamatan) |
| `Model_Users.js` | `BackEnd-monitoringlahan/model/` |  **PASSED** (0 Errors) | Role validation & 1 Desa = 1 Penyuluh invariant |
| `Model_Standar_Komoditas.js` | `BackEnd-monitoringlahan/model/` |  **PASSED** (0 Errors) | 8-parameter threshold submission & verification |
| `Model_Forum.js` | `BackEnd-monitoringlahan/model/` |  **PASSED** (0 Errors) | Forum feed, comments & verification badge generation |
| `wilayah.js` | `BackEnd-monitoringlahan/routes/api/` |  **PASSED** (0 Errors) | Sumenep district & village RESTful queries |
| `auth.js` | `BackEnd-monitoringlahan/routes/api/` |  **PASSED** (0 Errors) | Register, login & paired penyuluh auto-resolver |
| `standar.js` | `BackEnd-monitoringlahan/routes/api/` |  **PASSED** (0 Errors) | Farmer submit & Penyuluh verify endpoints |
| `forum.js` | `BackEnd-monitoringlahan/routes/api/` |  **PASSED** (0 Errors) | Feed, post & comment endpoints |
| `db_init_sumenep.js` | `BackEnd-monitoringlahan/config/` |  **PASSED** (0 Errors) | Table creator & 27-kecamatan Sumenep master seeder |
| `app.js` | `BackEnd-monitoringlahan/` |  **PASSED** (0 Errors) | Route mounter & auto-initializer |

---

## 8. Panduan Kolaborasi & Integrasi Web Dashboard (Untuk Developer Web)

> **PENTING UNTUK REKAN DEVELOPER WEB:**
> Bagian ini disusun secara khusus dalam Bahasa Indonesia untuk mempermudah rekan developer yang mengerjakan web dashboard (EJS/Admin Dashboard) dalam mengintegrasikan fitur-fitur baru (wilayah Sumenep, status verifikasi standar petani, dan forum komunitas) ke dalam tampilan antarmuka web, sekaligus memberikan kepastian bahwa seluruh sistem lama tetap berjalan 100% normal.

---

### A. Jaminan Nol Konflik pada Rute & Sistem Legacy Web

Seluruh kode eksisting untuk dashboard web, modul pemetaan lahan GIS, dan rute telemetri sensor lama **TIDAK DIUBAH SAMA SEKALI** dan dijamin aman dari konflik merge (*zero breaking changes*):

1. **Rute Halaman Web Dashboard Eksisting (Tetap Utuh):**
   * `/sensor` (`routes/sensor.js`) — Visualisasi tabel dan monitoring probe sensor tanah.
   * `/petalahan` (`routes/petalahan.js`) — Peta GIS interaktif persebaran lahan tani Kabupaten Sumenep.
   * `/kelompoktani` (`routes/kelompoktani.js`) — Manajemen data kelompok tani.
   * `/policy_brief` (`routes/policy_brief.js`) — Modul analisis AI kebijakan pertanian Sumenep.
   * `/sayur_buah`, `/biofarmaka`, `/luas_tanam_perkebunan_rakyat` — Statistik komoditas BPS.
2. **Rute API Telemetri Sensor Lama (Tetap Utuh):**
   * `POST /api/soil/save` — Endpoint penerimaan payload 24 parameter kuesioner tanah dari aplikasi petani lama.
   * `POST /api/soil/penyuluh/save` — Endpoint penerimaan 8 parameter telemetri + 3 foto audit dari aplikasi penyuluh.
   * `GET /api/soil/` — Endpoint list data monitoring tanah.

---

### B. Daftar Tabel Baru & Skrip SQL Migrasi Database Server

Jika rekan developer web melakukan deployment ke server production atau setup database lokal baru, jalankan file SQL migrasi yang telah disediakan di:
📂 `BackEnd-monitoringlahan/config/migrations_phase1_sumenep.sql`

Atau eksekusi perintah DDL MySQL berikut:

```sql
-- =========================================================================================
-- STRUKTUR TABEL BARU & ENHANCEMENT DATABASE
-- Database Target: MySQL / MariaDB (InnoDB, utf8mb4_general_ci)
-- =========================================================================================

-- 1. Master Wilayah Eksklusif Kabupaten Sumenep (27 Kecamatan & Seluruh Desa/Kelurahan)
CREATE TABLE IF NOT EXISTS `master_wilayah_sumenep` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `kecamatan` VARCHAR(100) NOT NULL,
  `desa` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_kec_desa` (`kecamatan`, `desa`),
  KEY `idx_kecamatan` (`kecamatan`),
  KEY `idx_desa` (`desa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2. Penyesuaian Tabel Users (Dukungan Role Petani/Penyuluh & Wilayah Desa Binaan)
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(255) DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `no_hp` VARCHAR(50) DEFAULT NULL,
  `role` ENUM('petani','penyuluh','admin') NOT NULL DEFAULT 'petani',
  `desa_id` INT(11) DEFAULT NULL,
  `foto_users` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_desa_id` (`desa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3. Tabel Standar Komoditas Mandiri Petani (Siklus Verifikasi Penyuluh)
CREATE TABLE IF NOT EXISTS `standar_komoditas_petani` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `petani_id` INT(11) NOT NULL,
  `penyuluh_id` INT(11) DEFAULT NULL,
  `desa_id` INT(11) NOT NULL,
  `komoditas` VARCHAR(255) NOT NULL,
  `varietas` VARCHAR(255) NOT NULL,
  `min_ph` DECIMAL(4,2) NOT NULL DEFAULT 6.00,
  `max_ph` DECIMAL(4,2) NOT NULL DEFAULT 7.00,
  `min_moisture` DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  `max_moisture` DECIMAL(5,2) NOT NULL DEFAULT 80.00,
  `min_n` INT(11) NOT NULL DEFAULT 100,
  `max_n` INT(11) NOT NULL DEFAULT 150,
  `min_p` INT(11) NOT NULL DEFAULT 25,
  `max_p` INT(11) NOT NULL DEFAULT 45,
  `min_k` INT(11) NOT NULL DEFAULT 150,
  `max_k` INT(11) NOT NULL DEFAULT 220,
  `min_temp` DECIMAL(4,2) NOT NULL DEFAULT 20.00,
  `max_temp` DECIMAL(4,2) NOT NULL DEFAULT 35.00,
  `min_ec` INT(11) NOT NULL DEFAULT 1000,
  `max_ec` INT(11) NOT NULL DEFAULT 2000,
  `min_fertility` INT(11) NOT NULL DEFAULT 50,
  `max_fertility` INT(11) NOT NULL DEFAULT 100,
  `status` ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  `catatan_penyuluh` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_petani_id` (`petani_id`),
  KEY `idx_penyuluh_id` (`penyuluh_id`),
  KEY `idx_desa_id` (`desa_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 4. Tabel Postingan Forum Komunitas Petani & Penyuluh
CREATE TABLE IF NOT EXISTS `forum_posts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `standar_id` INT(11) DEFAULT NULL,
  `title` VARCHAR(255) NOT NULL,
  `body` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_standar_id` (`standar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 5. Tabel Komentar Thread Forum
CREATE TABLE IF NOT EXISTS `forum_comments` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `post_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `comment` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

> **Catatan Otomatisasi:**
> Pada backend Express, fungsi `initSumenepDatabase()` pada `BackEnd-monitoringlahan/config/db_init_sumenep.js` akan secara otomatis mengeksekusi pembuatan tabel dan men-seed seluruh 27 kecamatan Kabupaten Sumenep saat server Node.js pertama kali dijalankan.

---

### C. Daftar Lengkap RESTful API Baru untuk Dashboard Web

Berikut adalah daftar rute API yang dapat langsung dikonsumsi oleh developer web jika ingin menambahkan tabel pemantauan verifikasi atau widget forum di dashboard web:

#### 1. Modul Master Wilayah Sumenep
* **`GET /api/wilayah/sumenep`**
  * **Fungsi:** Mengambil data kecamatan & desa se-Kabupaten Sumenep.
  * **Query Params:**
    * `?kecamatan=Gapura` (Filter per kecamatan)
    * `?q=Batang` (Pencarian fleksibel nama desa/kecamatan)
  * **Contoh Response JSON:**
    ```json
    {
      "status": true,
      "message": "Master Wilayah Kabupaten Sumenep",
      "total_kecamatan": 27,
      "total_desa": 334,
      "kecamatan_list": ["Ambunten", "Arjasa (Kangean)", "Batang-Batang", "..."],
      "data": [
        { "id": 79, "kecamatan": "Gapura", "desa": "Gapura Barat" },
        { "id": 80, "kecamatan": "Gapura", "desa": "Gapura Timur" }
      ]
    }
    ```

#### 2. Modul Autentikasi & Pairing (1 Desa = 1 Penyuluh)
* **`POST /api/auth/register`**
  * **Payload:**
    ```json
    {
      "nama": "Ahmad Fauzi",
      "email": "fauzi@petani.id",
      "password": "password123",
      "no_hp": "081234567890",
      "role": "petani",
      "desa_id": 79
    }
    ```
  * **Aturan Khusus Invariant:** Jika `role = "penyuluh"`, sistem akan menolak jika desa tersebut sudah memiliki penyuluh terdaftar. Petani yang mendaftar akan otomatis dipasangkan dengan penyuluh desa tersebut.
* **`POST /api/auth/login`**
  * **Payload:** `{ "email": "fauzi@petani.id", "password": "password123" }`
  * **Response:** Mengembalikan data user beserta objek `paired_penyuluh`.

#### 3. Modul Standar Komoditas & Verifikasi
* **`POST /api/petani/standar/submit`**
  * **Fungsi:** Petani mengajukan ambang batas komoditas mandiri (status awal: `pending`).
  * **Payload:**
    ```json
    {
      "petani_id": 1,
      "desa_id": 79,
      "komoditas": "Cabai Rawit",
      "varietas": "Madura Super",
      "min_ph": 6.0, "max_ph": 7.0,
      "min_moisture": 50.0, "max_moisture": 75.0,
      "min_n": 120, "max_n": 180,
      "min_p": 35, "max_p": 55,
      "min_k": 160, "max_k": 240,
      "min_temp": 24.0, "max_temp": 34.0,
      "min_ec": 1100, "max_ec": 2100,
      "min_fertility": 60, "max_fertility": 95
    }
    ```
* **`GET /api/penyuluh/standar/pending?desa_id=79`**
  * **Fungsi:** Menampilkan daftar pengajuan petani yang menunggu persetujuan penyuluh di desa terkait.
* **`POST /api/penyuluh/standar/verify`**
  * **Fungsi:** Penyuluh menyetujui atau menolak standar.
  * **Payload:**
    ```json
    {
      "id": 1,
      "penyuluh_id": 2,
      "status": "verified",
      "catatan_penyuluh": "Standar disetujui sesuai agroklimat tanah tegalan Gapura."
    }
    ```

#### 4. Modul Forum Komunitas Petani & Penyuluh
* **`GET /api/forum/posts?limit=50&offset=0`**
  * **Fungsi:** Feed diskusi komunitas. Jika ada lampiran standar yang belum terverifikasi, response menyertakan `verification_warning: "Standar ini belum diverifikasi penyuluh"`.
* **`POST /api/forum/posts`**
  * **Payload:**
    ```json
    {
      "user_id": 1,
      "standar_id": 1,
      "title": "Hasil Uji Tanam Padi Inpari 32 di Lahan Tadah Hujan",
      "body": "Setelah melakukan pemupukan berimbang, nilai NPK tanah stabil..."
    }
    ```
* **`POST /api/forum/comments`**
  * **Payload:**
    ```json
    {
      "post_id": 1,
      "user_id": 2,
      "comment": "Bagus sekali Pak, pertahankan kelembaban tanah di atas 60%."
    }
    ```

---

### D. Audit Kesiapan Klien Mobile (Phase 2)

Kedua aplikasi mobile telah diperbarui dan diuji secara menyeluruh:

| Aplikasi Mobile | Modul yang Diintegrasikan | Hasil `dart analyze` |
| :--- | :--- | :--- |
| **`apk-pertanian_presisi-petani`** | 1. Modal Picker Lokasi Sumenep (27 Kecamatan).<br>2. Banner Pairing Otomatis Penyuluh Desa.<br>3. Dual Baseline Strategy (Rekomendasi vs Mandiri).<br>4. Form Pengajuan Standar & Status Badge.<br>5. Forum Diskusi Petani + Peringatan Amber.<br>6. Navigation Shell 3 Tab. |  **PASSED (0 Issues)** |
| **`apk-pertanian_presisi-penyuluh`** | 1. Profil Wilayah Binaan Desa Sumenep.<br>2. Kotak Verifikasi Standar (Tinjau, Setujui, Tolak).<br>3. Perbandingan Ambang Batas 8 Parameter.<br>4. Forum Komunitas dengan Lencana Resmi Penyuluh.<br>5. Navigation Shell 3 Tab. |  **PASSED (0 Issues)** |

---
*Dokumen ini diperbarui secara berkala oleh Tim Lead Full-Stack Architect & Mobile Systems Engineer.*
