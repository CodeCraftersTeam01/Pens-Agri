var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_Monitoring_Lahan = require('../model/Model_Monitoring_Lahan');
const OpenAI = require('openai');

var router = express.Router();

function getOpenAIClient() {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY belum dikonfigurasi di file .env.');
  }
  return new OpenAI({ apiKey });
}

/* 1. GET halaman utama Policy Brief */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    if (!id) return res.redirect('/');
    
    let Data = await Model_Users.getId(id);
    if (!Data || Data.length === 0) return res.redirect('/logout');

    // Ambil 100 data terbaru untuk pratinjau tabel agar loading halaman instan dan ringan
    let rows = await Model_Monitoring_Lahan.getRecent(100);
    
    res.render('admin/policy_brief/index', {
      currentRoute: '/policy_brief', 
      email: Data[0].email,
      userRole: Data[0].role,
      data: rows
    });
  } catch (error) {
    console.error(error);
    res.status(501).json({error: 'cant access'});
  }
});

/* 2. POST endpoint: Komputasi Big Data di Database + Rekomendasi OpenAI */
router.post('/generate-policy', async function(req, res) {
  try {
    let id = req.session.userId;
    if (!id) {
      return res.status(403).json({ success: false, message: 'Akses ditolak. Sesi login telah berakhir.' });
    }
    let Data = await Model_Users.getId(id);
    if (!Data || Data.length === 0) {
      return res.status(403).json({ success: false, message: 'Akses ditolak. Akun tidak ditemukan.' });
    }

    const { tahun_bps, data_makro_bps } = req.body;

    // 1. Hitung agregasi statistik secara native di MySQL (Sangat cepat <10ms bahkan untuk 100.000+ data)
    const statsSummary = await Model_Monitoring_Lahan.getStatisticalSummary();

    if (!statsSummary || !statsSummary.ringkasan_umum || statsSummary.ringkasan_umum.total_titik === 0) {
      return res.status(400).json({ success: false, message: 'Data monitoring lahan di database masih kosong.' });
    }

    // 2. Format Prompt AI Padat, Terstruktur, dan Kaya Konteks
    const systemPrompt = `Bertindaklah sebagai Senior Data Scientist Pertanian Presisi & Pembuat Kebijakan Publik untuk Dinas Pertanian dan Ketahanan Pangan Kabupaten Sumenep, Jawa Timur.

Tugas Anda adalah membuat dokumen rekomendasi kebijakan strategis (Policy Brief) formal berdasarkan analisis 3 pilar data agregat real-time berikut ini:

[PILAR 1: DATA STATISTIK MAKRO PERKEBUNAN BPS SUMENEP (Tahun ${tahun_bps || 'Terbaru'})]
${JSON.stringify(data_makro_bps || [])}

[PILAR 2 & 3: HASIL ANALISIS STATISTIK BIG DATA SENSOR TANAH LAPANGAN (USB DONGLE) & SEBARAN KOMODITAS (Total Data: ${statsSummary.ringkasan_umum.total_titik} Titik Lahan)]
- Ringkasan Metrik Makro-Mikro:
  * Total Titik Lahan Terdata: ${statsSummary.ringkasan_umum.total_titik}
  * Rata-rata pH Tanah: ${statsSummary.ringkasan_umum.avg_ph} (Rentang: ${statsSummary.ringkasan_umum.min_ph} s/d ${statsSummary.ringkasan_umum.max_ph})
  * Rata-rata Kelembaban Tanah: ${statsSummary.ringkasan_umum.avg_moisture}%
  * Rata-rata Unsur Hara: Nitrogen = ${statsSummary.ringkasan_umum.avg_nitrogen} mg/kg, Fosfor = ${statsSummary.ringkasan_umum.avg_phosphorus} mg/kg, Kalium = ${statsSummary.ringkasan_umum.avg_potassium} mg/kg
  * Rata-rata Suhu & EC: Suhu = ${statsSummary.ringkasan_umum.avg_temp}°C, EC = ${statsSummary.ringkasan_umum.avg_conductivity} µS/cm
  * Infrastruktur & Risiko: Irigasi Aktif = ${statsSummary.ringkasan_umum.total_irigasi_aktif}, Pengguna Pompa = ${statsSummary.ringkasan_umum.total_pakai_pompa}, Kondisi Air Sulit = ${statsSummary.ringkasan_umum.total_air_sulit}, Total Kasus Gagal Panen = ${statsSummary.ringkasan_umum.total_gagal_panen}

- Analisis Kebutuhan per Komoditas Unggulan:
${JSON.stringify(statsSummary.distribusi_komoditas, null, 2)}

- Sampel Titik Lahan Kritis (Anomali pH / Hara / Risiko Tinggi):
${JSON.stringify(statsSummary.sampel_titik_kritis, null, 2)}

---
Sajikan analisis dalam Bahasa Indonesia yang formal, berbobot, berbasis data, dan aplikatif bagi Pemerintah Daerah. Struktur dokumen wajib:
# POLICY BRIEF: STRATEGI PERTANIAN PRESISI & TATA KELOLA LAHAN KABUPATEN SUMENEP

## 1. Ringkasan Eksekutif (Executive Summary)
Garis besar temuan konvergensi data makro BPS dan uji tanah sensor presisi lapangan.

## 2. Analisis Lahan Kritis & Anomali Sensor
Mendeteksi anomali pH tanah, defisit/kelebihan NPK, serta risiko gagal panen lintas komoditas.

## 3. Strategi Alokasi Pupuk Bersubsidi & Tata Kelola Air Berbasis Data Uji Tanah Presisi
Rekomendasi takaran pupuk dan intervensi pompa/irigasi.

## 4. Rencana Aksi Strategis (Action Plan)
Rencana operasional taktis jangka pendek bagi Dinas Pertanian dan Petani binaan.`;

    const openai = getOpenAIClient();
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini", 
      messages: [
        { role: "system", content: "Anda adalah pakar analis kebijakan pertanian presisi pemerintah dengan gaya penulisan formal birokratis dan solutif." },
        { role: "user", content: systemPrompt }
      ],
      temperature: 0.3
    });

    const policyBriefText = response.choices[0].message.content;

    return res.json({ 
      success: true, 
      policyBriefText: policyBriefText 
    });

  } catch (error) {
    console.error("Kesalahan OpenAI API:", error);
    return res.status(500).json({ 
      success: false, 
      message: 'Gagal menghasilkan rekomendasi kebijakan melalui AI: ' + error.message,
      error: error.message 
    });
  }
});


module.exports = router;