var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_Monitoring_Lahan = require('../model/Model_Monitoring_Lahan');
const OpenAI = require('openai');

var router = express.Router();

// Pastikan inisialisasi mengambil key dari process.env yang sudah di-load dotenv
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

/* 1. GET halaman utama Policy Brief */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    let rows = await Model_Monitoring_Lahan.getAll();
    
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        res.redirect('/logout');
      } else {
        res.render('admin/policy_brief/index', {
          currentRoute: '/policy_brief', 
          email: Data[0].email,
          data: rows
        });
      }
    } else {
      res.status(401).json({error: 'user not found'});
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
  }
});

/* 2. POST endpoint untuk memproses data & meminta rekomendasi dari OpenAI */
// router.post('/generate-policy', async function(req, res) {
//   try {
//     let id = req.session.userId;
//     let Data = await Model_Users.getId(id);
    
//     if (!Data || Data.length === 0 || Data[0].role != 2) {
//       return res.status(403).json({ success: false, message: 'Akses ditolak. Anda tidak memiliki otoritas.' });
//     }

//     const { tahun_bps, data_makro_bps, data_mikro_sensor } = req.body;

//     // Validasi payload mencegah data kosong terkirim ke OpenAI yang membuang kuota token
//     if (!data_mikro_sensor || data_mikro_sensor.length === 0) {
//       return res.status(400).json({ success: false, message: 'Data mikro sensor kosong atau gagal diekstraksi dari tabel.' });
//     }

//     const systemPrompt = `Bertindaklah sebagai Senior Data Scientist di bidang Pertanian Presisi sekaligus Pembuat Kebijakan Publik (Policy Maker) untuk Dinas Pertanian dan Ketahanan Pangan Kabupaten Sumenep, Jawa Timur.
        
// Tugas Anda adalah memformulasikan dokumen rekomendasi kebijakan strategis (Policy Brief) formal berdasarkan akumulasi 3 pilar data real-time lapangan berikut ini:

// [PILAR 1: DATA STATISTIK MAKRO DARI BPS SUMENEP (Tahun ${tahun_bps})]
// ${JSON.stringify(data_makro_bps)}

// [PILAR 2 & 3: LOG DATA MIKRO SENSOR IOT LAPANGAN & VALIDASI KELEMBAGAAN MESO]
// ${JSON.stringify(data_mikro_sensor)}

// ---
// Sajikan analisis Anda dalam Bahasa Indonesia yang sangat formal, akademis-birokratis, tajam, dan langsung menyasar pada rencana aksi taktis Pemerintah Daerah. Struktur dokumen wajib terdiri dari:
// 1. Executive Summary (Garis besar temuan konvergensi lintas-data makro dan mikro).
// 2. Analisis Lahan Kritis (Mendeteksi desa-desa yang memiliki anomali pH kritis, ketidakseimbangan NPK, atau risiko gagal panen tinggi).
// 3. Strategi Alokasi Pupuk Bersubsidi & Tata Kelola Air Berbasis IoT Spasial (Gunakan data irigasi, kondisi air, dan pompa).
// 4. Action Plan / Rencana Kerja Operasional Jangka Pendek untuk Bupati atau Kepala Dinas Pertanian setempat.

// Gunakan format penulisan Markdown dengan sub-bab (headings) yang terstruktur rapi agar mudah dibaca di dashboard aplikasi.`;

//     const response = await openai.chat.completions.create({
//       model: "gpt-4o", 
//       messages: [
//         { role: "system", content: "Anda adalah pakar analis kebijakan makro agrikultur regional dengan gaya penulisan birokratis-akademis resmi." },
//         { role: "user", content: systemPrompt }
//       ],
//       temperature: 0.2 // Diturunkan sedikit ke 0.2 agar output analisis jauh lebih konsisten, matematis, dan rigid pada data empiris
//     });

//     const policyBriefText = response.choices[0].message.content;

//     return res.json({ 
//       success: true, 
//       policyBriefText: policyBriefText 
//     });

//   } catch (error) {
//     console.error("Kesalahan OpenAI API:", error);
//     return res.status(500).json({ 
//       success: false, 
//       message: 'Gagal menghasilkan rekomendasi kebijakan melalui AI.',
//       error: error.message 
//     });
//   }
// });

/* 2. POST endpoint untuk memproses data & meminta rekomendasi dari OpenAI */
router.post('/generate-policy', async function(req, res) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    
    if (!Data || Data.length === 0 || Data[0].role != 2) {
      return res.status(403).json({ success: false, message: 'Akses ditolak. Anda tidak memiliki otoritas.' });
    }

    const { tahun_bps, data_makro_bps, data_mikro_sensor } = req.body;

    // Validasi payload
    if (!data_mikro_sensor || data_mikro_sensor.length === 0) {
      return res.status(400).json({ success: false, message: 'Data mikro sensor kosong atau gagal diekstraksi dari tabel.' });
    }

    // Fungsi ringkas data sensor
    function summarizeSensorData(sensorData) {
      const summary = sensorData.reduce((acc, item) => {
        if (item.ph !== undefined) acc.ph.push(item.ph);
        if (item.npk !== undefined) acc.npk.push(item.npk);
        if (item.moisture !== undefined) acc.moisture.push(item.moisture);
        return acc;
      }, { ph: [], npk: [], moisture: [] });

      const avg = arr => arr.length > 0 ? arr.reduce((a,b)=>a+b,0) / arr.length : null;

      return {
        rata_rata_ph: avg(summary.ph),
        rata_rata_npk: avg(summary.npk),
        rata_rata_kelembaban: avg(summary.moisture),
        jumlah_record: sensorData.length
      };
    }

    // Ringkas data mikro sensor
    const summarizedMicro = summarizeSensorData(data_mikro_sensor);

    // Ringkas data makro (jangan kirim full JSON)
    const summarizedMacro = {
      jumlah_desa: data_makro_bps?.desa?.length || 0,
      produksi_total: data_makro_bps?.produksi_total || null,
      luas_lahan: data_makro_bps?.luas_lahan || null
    };

    const systemPrompt = `Bertindaklah sebagai Senior Data Scientist di bidang Pertanian Presisi sekaligus Pembuat Kebijakan Publik (Policy Maker) untuk Dinas Pertanian dan Ketahanan Pangan Kabupaten Sumenep, Jawa Timur.
        
Tugas Anda adalah memformulasikan dokumen rekomendasi kebijakan strategis (Policy Brief) formal berdasarkan akumulasi 3 pilar data real-time lapangan berikut ini:

[PILAR 1: Ringkasan DATA STATISTIK MAKRO BPS SUMENEP (Tahun ${tahun_bps})]
${JSON.stringify(summarizedMacro)}

[PILAR 2 & 3: Ringkasan LOG DATA MIKRO SENSOR IOT LAPANGAN]
${JSON.stringify(summarizedMicro)}

---
Sajikan analisis Anda dalam Bahasa Indonesia yang sangat formal, akademis-birokratis, tajam, dan langsung menyasar pada rencana aksi taktis Pemerintah Daerah. Struktur dokumen wajib terdiri dari:
1. Executive Summary
2. Analisis Lahan Kritis
3. Strategi Alokasi Pupuk Bersubsidi & Tata Kelola Air Berbasis IoT Spasial
4. Action Plan / Rencana Kerja Operasional Jangka Pendek.`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o", 
      messages: [
        { role: "system", content: "Anda adalah pakar analis kebijakan makro agrikultur regional dengan gaya penulisan birokratis-akademis resmi." },
        { role: "user", content: systemPrompt }
      ],
      temperature: 0.2
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
      message: 'Gagal menghasilkan rekomendasi kebijakan melalui AI.',
      error: error.message 
    });
  }
});


module.exports = router;