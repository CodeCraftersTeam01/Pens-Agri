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
*Generated autonomously by Full-Stack Systems Architect & Backend Integration Specialist.*
