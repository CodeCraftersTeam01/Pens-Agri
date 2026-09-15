var express = require('express');
const Model_Monitoring_Lahan = require('../../model/Model_Monitoring_Lahan');
var router = express.Router();

/* GET users listing. */
router.get('/', async function(req, res, next) {

    let rows = await Model_Monitoring_Lahan.getAll();
    return res.status(200).json({
        status: true,
        message: 'Data Lahan',
        data: rows
    });
  
});

router.post('/save', async (req, res) => {
    try {
        let {
            nama_desa,
            latitude,
            longitude,
            irigasi,
            listrik,
            pompa_air,
            sumber_air,
            kondisi_air,
            sumber_energi_pompa,
            pembajak,
            tadahan_hujan,
            komoditas,
            luas_lahan,
            status_lahan,
            kelompok_tani,
            gagal_panen,
            temp,
            moisture,
            conductivity,
            ph,
            nitrogen,
            phosphorus,
            potassium,
            fertility
        } = req.body;

        let Data = {
            nama_desa,
            latitude,
            longitude,
            irigasi,
            listrik,
            pompa_air,
            sumber_air,
            kondisi_air,
            sumber_energi_pompa,
            pembajak,
            tadahan_hujan,
            komoditas,
            luas_lahan,
            status_lahan,
            kelompok_tani,
            gagal_panen,
            temp,
            moisture,
            conductivity,
            ph,
            nitrogen,
            phosphorus,
            potassium,
            fertility
        };

        await Model_Monitoring_Lahan.Store(Data);
        return res.status(200).json({
            status: true,
            message: 'Data Lahan Berhasil Disimpan',
        });
    } catch (error) {
        console.error("Gagal menyimpan data lahan:", error);
        return res.status(500).json({
            status: false,
            message: 'Gagal menyimpan data lahan ke database',
            error: error.message
        });
    }
});

router.post('/update/(:id)', async (req, res) => {
    try {
        let id = req.params.id;
        let {
            latitude,
            longitude,
            irigasi,
            listrik,
            pompa_air,
            sumber_air,
            kondisi_air,
            sumber_energi_pompa,
            pembajak,
            tadahan_hujan,
            komoditas,
            luas_lahan,
            status_lahan,
            kelompok_tani,
            gagal_panen,
            temp,
            moisture,
            conductivity,
            ph,
            nitrogen,
            phosphorus,
            potassium,
            fertility
        } = req.body;

        let Data = {
            latitude,
            longitude,
            irigasi,
            listrik,
            pompa_air,
            sumber_air,
            kondisi_air,
            sumber_energi_pompa,
            pembajak,
            tadahan_hujan,
            komoditas,
            luas_lahan,
            status_lahan,
            kelompok_tani,
            gagal_panen,
            temp,
            moisture,
            conductivity,
            ph,
            nitrogen,
            phosphorus,
            potassium,
            fertility
        };

        await Model_Monitoring_Lahan.Update(id, Data);
        return res.status(200).json({
            status: true,
            message: 'Data Lahan Berhasil Diperbarui',
        });
    } catch (error) {
        console.error("Gagal memperbarui data lahan:", error);
        return res.status(500).json({
            status: false,
            message: 'Gagal memperbarui data lahan ke database',
            error: error.message
        });
    }
});

router.get('/delete/(:id)', async function(req, res, next){
  let id = req.params.id;
  await Model_Monitoring_Lahan.Delete(id);
  return res.status(200).json({
        status: true,
        message: 'Data Lahan Berhasil Dihapus',
    });
});

// ==========================================
// PENYULUH DEDICATED ROUTES & MULTIPART UPLOADS
// ==========================================

const path = require('path');
const fs = require('fs');
const multer = require('multer');

// Configure upload directory for soil sample photos
const uploadDir = path.join(__dirname, '../../public/images/uploads/soil');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname) || '.jpg';
        cb(null, file.fieldname + '-' + uniqueSuffix + ext);
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB limit
});

const cpUpload = upload.fields([
    { name: 'foto_daun', maxCount: 1 },
    { name: 'foto_pohon', maxCount: 1 },
    { name: 'foto_tanah', maxCount: 1 }
]);

/**
 * POST /api/soil/penyuluh/save
 * Dedicated endpoint for Penyuluh app with multipart photo uploads and crop telemetry.
 */
router.post('/penyuluh/save', cpUpload, async (req, res) => {
    try {
        const {
            latitude,
            longitude,
            nama_desa,
            komoditas,
            varietas,
            hasil_panen_lalu,
            satuan_panen,
            temp,
            moisture,
            conductivity,
            ph,
            nitrogen,
            phosphorus,
            potassium,
            fertility
        } = req.body;

        // Process uploaded files if available
        let foto_daun = null;
        let foto_pohon = null;
        let foto_tanah = null;

        if (req.files) {
            if (req.files['foto_daun'] && req.files['foto_daun'][0]) {
                foto_daun = `/images/uploads/soil/${req.files['foto_daun'][0].filename}`;
            }
            if (req.files['foto_pohon'] && req.files['foto_pohon'][0]) {
                foto_pohon = `/images/uploads/soil/${req.files['foto_pohon'][0].filename}`;
            }
            if (req.files['foto_tanah'] && req.files['foto_tanah'][0]) {
                foto_tanah = `/images/uploads/soil/${req.files['foto_tanah'][0].filename}`;
            }
        }

        const Data = {
            latitude: parseFloat(latitude) || 0.0,
            longitude: parseFloat(longitude) || 0.0,
            nama_desa: nama_desa || '',
            komoditas: komoditas || '',
            varietas: varietas || '',
            hasil_panen_lalu: hasil_panen_lalu ? String(hasil_panen_lalu) : '0',
            satuan_panen: satuan_panen || 'ton',
            temp: parseFloat(temp) || 0.0,
            moisture: parseFloat(moisture) || 0.0,
            conductivity: parseFloat(conductivity) || 0,
            ph: parseFloat(ph) || 0.0,
            nitrogen: parseFloat(nitrogen) || 0,
            phosphorus: parseFloat(phosphorus) || 0,
            potassium: parseFloat(potassium) || 0,
            fertility: parseFloat(fertility) || 0,
            foto_daun,
            foto_pohon,
            foto_tanah,
            tipe_penginput: 'penyuluh'
        };

        const result = await Model_Monitoring_Lahan.StorePenyuluh(Data);

        return res.status(200).json({
            status: true,
            message: 'Data Lahan Penyuluh Berhasil Disimpan',
            data: {
                id: result.insertId,
                ...Data
            }
        });
    } catch (error) {
        console.error("Gagal menyimpan data lahan penyuluh:", error);
        return res.status(500).json({
            status: false,
            message: 'Gagal menyimpan data lahan penyuluh ke database',
            error: error.message
        });
    }
});

/**
 * GET /api/soil/penyuluh
 * Retrieve all records submitted by agricultural extension officers (penyuluh)
 */
router.get('/penyuluh', async (req, res) => {
    try {
        const rows = await Model_Monitoring_Lahan.getAllPenyuluh();
        return res.status(200).json({
            status: true,
            message: 'Data Lahan Penyuluh',
            data: rows
        });
    } catch (error) {
        console.error("Gagal mengambil data lahan penyuluh:", error);
        return res.status(500).json({
            status: false,
            message: 'Gagal mengambil data lahan penyuluh dari database',
            error: error.message
        });
    }
});

module.exports = router;

