# 🌾 PENS AGRI PRESISI
> **Smart Agriculture & Soil IoT Monitoring System with Generative AI Policy Brief**

[![Node.js](https://img.shields.io/badge/Node.js-v20+-green.svg?logo=node.js)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-4.21-black.svg?logo=express)](https://expressjs.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg?logo=mysql)](https://www.mysql.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o--mini-412991.svg?logo=openai)](https://openai.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📌 Ringkasan Proyek

**PENS Agri Presisi** adalah platform pemantauan pertanian presisi (*Precision Agriculture*) berbasis **Internet of Things (IoT)**, **Sistem Informasi Geografis (GIS)**, dan **Kecerdasan Buatan (AI)**. 

Platform ini dirancang untuk memadukan data makro regional (BPS) dengan data mikro sensor lapangan (pH, Kelembaban, Nitrogen, Fosfor, Kalium, EC, Suhu) serta informasi meso kelembagaan kelompok tani guna memformulasikan dokumen rekomendasi kebijakan strategis (**Policy Brief**) secara otomatis bagi pengambil kebijakan dan dinas terkait.

---

## ✨ Fitur Utama

- 📊 **Dashboard Analisis & Ringkasan Lahan**: Visualisasi data statistik real-time persebaran lahan, komoditas, dan infrastruktur tani.
- 🤖 **AI Policy Brief Generator (OpenAI)**:
  - Komputasi Big Data cepat menggunakan **Native SQL Aggregation** (mampu memproses ratusan ribu data dalam hitungan milidetik).
  - Formulasi rekomendasi taktis (Executive Summary, Analisis Lahan Kritis, Strategi Alokasi Pupuk Bersubsidi & Tata Kelola Air, serta Rencana Aksi).
  - Fitur cetak laporan formal langsung ke format PDF.
- 🌐 **Interoperabilitas WebAPI BPS**: Integrasi data statistik makro pertanian BPS Sumenep secara *live*.
- 🗺️ **Pemetaan Lahan & Geospasial (GIS)**: Pemetaan titik koordinat lokasi lahan pertanian dan status hara tanah.
- 🧪 **Log Parameter Sensor IoT**: Monitoring real-time unsur kimia tanah (NPK, pH, Electrical Conductivity, Kelembaban, Suhu).
- 👥 **Multi-level User Access**: Pembagian hak akses terkelola (*Super User* dan *User*).

---

## 🛠️ Tech Stack

- **Backend**: Node.js, Express.js
- **Frontend / Template**: EJS (Embedded JavaScript), Bootstrap 5, FontAwesome, DataTables, Marked.js
- **Database**: MySQL / MariaDB (Connection Pooling dengan `mysql2`)
- **AI & Integrasi**: OpenAI API (`gpt-4o-mini`), BPS WebAPI Interoperability
- **Security & Session**: Bcryptjs, Express-Session, Express-Flash, Dotenv

---

## 🚀 Panduan Instalasi & Menjalankan

### 1. Prasyarat Sistem
Pastikan perangkat Anda telah terinstal:
- [Node.js](https://nodejs.org/) (versi 18 ke atas)
- [MySQL](https://www.mysql.com/) atau MariaDB (via XAMPP, Laragon, Homebrew, atau Herd)
- Git

### 2. Kloning Repositori
```bash
git clone https://github.com/username/monitoringlahan.git
cd monitoringlahan
```

### 3. Instal Dependensi
```bash
npm install
```

### 4. Konfigurasi Environment (`.env`)
Salin file `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```
Buka file `.env` dan sesuaikan dengan konfigurasi lokal Anda:
```env
PORT=3000
NODE_ENV=development

# Konfigurasi Database MySQL
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=db_pertanian
DB_PORT=3306

# Keamanan Sesi
SESSION_SECRET=your_super_secret_session_key

# OpenAI API Key
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-4o-mini
```

### 5. Impor Database
1. Buat database baru bernama `db_pertanian` di phpMyAdmin / MySQL CLI.
2. Impor file skema database:
   ```bash
   mysql -u root -p db_pertanian < config/db_pertanian.sql
   ```

### 6. Jalankan Aplikasi
Jalankan server dalam mode *Hot-Reload* (Nodemon):
```bash
npm start
```
Aplikasi akan aktif di: **[http://localhost:3000](http://localhost:3000)**

---

## 🔐 Kredensial Pengujian Default

| Role | Email | Password Default | Akses |
|---|---|---|---|
| **Super User** | `admin@gmail.com` | `admin123` | Master Data & Dashboard Super Admin |
| **User** | `p@gmail.com` | `123456` | Dashboard Monitoring & AI Policy Brief |

---

## 📂 Struktur Direktori

```plaintext
├── bin/                 # Skrip inisialisasi server (www)
├── config/              # Konfigurasi database & skrip SQL
├── model/               # Model data MySQL & logika query
├── public/              # Aset statis (CSS, JS, Gambar)
├── routes/              # Routing endpoint aplikasi Express
│   ├── master_data/     # Rute data komoditas pertanian
│   ├── api/             # Rute REST API sensor
│   ├── policy_brief.js  # Rute kalkulasi & konektor OpenAI
│   └── ...
├── views/               # Template UI berbasis EJS
│   ├── admin/           # Tampilan halaman admin & Policy Brief
│   ├── auth/            # Halaman Login & Registrasi
│   └── partials/        # Komponen header, sidebar, navbar
├── .env.example         # Template konfigurasi environment
├── .gitignore           # Daftar berkas yang diabaikan Git
├── app.js               # Konfigurasi utama Express application
└── package.json         # Dependensi proyek & skrip npm
```

---

## 👥 Kontributor & Kolaborator

- **Tim Pengembang CodeCrafters PENS**
- 🤖 **[Google Gemini](https://github.com/gemini-code-assist)** (*AI Pair Programmer & Code Contributor*)

---

## 📄 Lisensi
Didistribusikan di bawah Lisensi MIT. Lihat `LICENSE` untuk informasi lebih lanjut.

---

<div align="center">
  <sub>Dikembangkan oleh <b>Politeknik Elektronika Negeri Surabaya (PENS)</b> &copy; 2026</sub>
</div>
