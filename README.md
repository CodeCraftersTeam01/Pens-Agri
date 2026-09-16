# 🌾 PENS AGRI PRESISI (Monorepo)
> **Precision Agriculture & Soil IoT Monitoring Platform with Mobile Apps & Generative AI Policy Brief**

[![Node.js](https://img.shields.io/badge/Node.js-v20+-green.svg?logo=node.js)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-v3.0+-blue.svg?logo=flutter)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg?logo=mysql)](https://www.mysql.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--4o--mini-412991.svg?logo=openai)](https://openai.com/)
[![Gemini](https://img.shields.io/badge/AI%20Assistance-Google%20Gemini-4285F4.svg?logo=google-gemini)](https://deepmind.google/technologies/gemini/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📌 Tentang Proyek

**PENS Agri Presisi** adalah ekosistem pemantauan pertanian presisi (*Precision Agriculture Ecosystem*) berbasis **Internet of Things (IoT)**, **Sistem Informasi Geografis (GIS)**, **Aplikasi Mobile (Flutter)**, dan **Kecerdasan Buatan (AI)** yang dikembangkan oleh tim **CodeCrafters Politeknik Elektronika Negeri Surabaya (PENS)**.

---

## 📂 Struktur Monorepo

```plaintext
Pens-Agri/
├── BackEnd-monitoringlahan/       # Web Admin Dashboard & REST API (Express.js, Leaflet GIS, OpenAI)
├── apk-pertanian_presisi-penyuluh/ # Aplikasi Mobile Petugas Penyuluh Pertanian (Flutter)
├── apk-pertanian_presisi-petani/   # Aplikasi Mobile Petani (Flutter)
└── change.md                       # Log Perubahan & Dokumentasi Integrasi
```

---

## ✨ Fitur Utama

- 🗺️ **Peta Geospasial Presisi (GIS & Marker Clustering)**:
  - Visualisasi ribuan sebaran titik lahan dengan clustering adaptif ala Google Maps (60 FPS).
  - Filter interaktif komoditas (Padi, Jagung, Cabai, Tembakau), pembajak (Traktor & Sapi), kelompok tani, dan infrastruktur air/listrik.
- 🤖 **AI Policy Brief Generator (OpenAI)**:
  - Formulasi otomatis rekomendasi kebijakan taktis berbasis data agregasi SQL real-time.
  - Cetak laporan PDF resmi siap edar untuk pemangku kebijakan daerah.
- 📱 **Mobile App Penyuluh & Petani (Flutter)**:
  - Telemetri sensor tanah probe IoT (NPK, pH, Kelembaban, Suhu, Konduktivitas Elektrik).
  - Pengambilan foto sampel tanah, daun, dan pohon untuk analisis kesehatan tanaman.
- 🌐 **Interoperabilitas Statistik BPS**:
  - Sinkronisasi data makro regional komoditas pertanian.

---

## 👥 Kontributor & Kolaborator

Proyek ini dikembangkan dan dipelihara oleh:

- **Tim Pengembang CodeCrafters PENS**
- 🤖 **[Google Gemini](https://github.com/gemini-code-assist)** (*AI Pair Programmer & Code Contributor*) — Optimalisasi arsitektur performa web GIS, AI Policy Brief Engine, dan sinkronisasi sistem.

---

<div align="center">
  <sub>Dikembangkan oleh <b>Politeknik Elektronika Negeri Surabaya (PENS)</b> &copy; 2026</sub>
</div>
