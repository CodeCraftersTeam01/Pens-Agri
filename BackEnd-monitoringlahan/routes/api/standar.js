const express = require('express');
const router = express.Router();
const Model_Standar_Komoditas = require('../../model/Model_Standar_Komoditas');
const Model_Users = require('../../model/Model_Users');

// Helper handler for submit standard
const handleSubmitStandard = async (req, res) => {
  try {
    const {
      petani_id,
      desa_id,
      komoditas,
      varietas,
      min_ph, max_ph,
      min_moisture, max_moisture,
      min_n, max_n,
      min_p, max_p,
      min_k, max_k,
      min_temp, max_temp,
      min_ec, max_ec,
      min_fertility, max_fertility
    } = req.body;

    if (!petani_id || !desa_id || !komoditas || !varietas) {
      return res.status(400).json({
        status: false,
        message: 'Parameter wajib: petani_id, desa_id, komoditas, varietas'
      });
    }

    // Auto-resolve assigned village Penyuluh
    const pairedPenyuluh = await Model_Users.getPenyuluhByDesa(desa_id);
    const penyuluh_id = pairedPenyuluh ? pairedPenyuluh.id : null;

    const Data = {
      petani_id: parseInt(petani_id, 10),
      penyuluh_id: penyuluh_id,
      desa_id: parseInt(desa_id, 10),
      komoditas: komoditas.trim(),
      varietas: varietas.trim(),
      min_ph: parseFloat(min_ph) || 6.0,
      max_ph: parseFloat(max_ph) || 7.0,
      min_moisture: parseFloat(min_moisture) || 50.0,
      max_moisture: parseFloat(max_moisture) || 80.0,
      min_n: parseInt(min_n, 10) || 100,
      max_n: parseInt(max_n, 10) || 150,
      min_p: parseInt(min_p, 10) || 25,
      max_p: parseInt(max_p, 10) || 45,
      min_k: parseInt(min_k, 10) || 150,
      max_k: parseInt(max_k, 10) || 220,
      min_temp: parseFloat(min_temp) || 20.0,
      max_temp: parseFloat(max_temp) || 35.0,
      min_ec: parseInt(min_ec, 10) || 1000,
      max_ec: parseInt(max_ec, 10) || 2000,
      min_fertility: parseInt(min_fertility, 10) || 50,
      max_fertility: parseInt(max_fertility, 10) || 100,
      status: 'pending',
      catatan_penyuluh: null
    };

    const result = await Model_Standar_Komoditas.SubmitStandar(Data);

    return res.status(201).json({
      status: true,
      message: 'Standar komoditas mandiri berhasil diajukan dan menunggu verifikasi Penyuluh Desa',
      data: {
        id: result.insertId,
        status: 'pending',
        assigned_penyuluh: pairedPenyuluh ? pairedPenyuluh.nama : 'Belum Ada Penyuluh Terdaftar di Desa Ini',
        ...Data
      }
    });

  } catch (error) {
    console.error('Error submitting custom standard:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal mengajukan standar komoditas mandiri',
      error: error.message
    });
  }
};

// Helper handler for pending standards
const handleGetPendingStandards = async (req, res) => {
  try {
    const { penyuluh_id, desa_id } = req.query;

    if (!penyuluh_id && !desa_id) {
      return res.status(400).json({
        status: false,
        message: 'Query parameter penyuluh_id atau desa_id wajib disertakan'
      });
    }

    const pendingList = await Model_Standar_Komoditas.getPendingByPenyuluh(penyuluh_id, desa_id);

    return res.status(200).json({
      status: true,
      message: 'Daftar pengajuan standar komoditas menunggu verifikasi',
      total: pendingList.length,
      data: pendingList
    });

  } catch (error) {
    console.error('Error fetching pending standards:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal mengambil daftar pengajuan standar pending',
      error: error.message
    });
  }
};

// Helper handler for verifying standards
const handleVerifyStandard = async (req, res) => {
  try {
    const { id, penyuluh_id, status, catatan_penyuluh } = req.body;

    if (!id || !penyuluh_id || !status) {
      return res.status(400).json({
        status: false,
        message: 'Parameter wajib: id, penyuluh_id, status ("verified" / "rejected")'
      });
    }

    const normalizedStatus = status.toLowerCase();
    if (!['verified', 'rejected'].includes(normalizedStatus)) {
      return res.status(400).json({
        status: false,
        message: 'Status harus berupa "verified" atau "rejected"'
      });
    }

    await Model_Standar_Komoditas.VerifyStandar(id, penyuluh_id, normalizedStatus, catatan_penyuluh || null);
    const updated = await Model_Standar_Komoditas.getById(id);

    return res.status(200).json({
      status: true,
      message: `Standar komoditas berhasil ${normalizedStatus === 'verified' ? 'DIVERIFIKASI' : 'DITOLAK'} oleh Penyuluh`,
      data: updated
    });

  } catch (error) {
    console.error('Error verifying standard:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal memproses verifikasi standar komoditas',
      error: error.message
    });
  }
};

// Helper handler for farmer standards list
const handleGetFarmerStandards = async (req, res) => {
  try {
    const { petani_id } = req.query;
    if (!petani_id) {
      return res.status(400).json({
        status: false,
        message: 'Query parameter petani_id wajib disertakan'
      });
    }

    const rows = await Model_Standar_Komoditas.getByPetani(petani_id);
    return res.status(200).json({
      status: true,
      total: rows.length,
      data: rows
    });
  } catch (error) {
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
};

// Explicit route bindings for `/api/petani/standar/submit` and `/api/petani/submit`
router.post('/petani/standar/submit', handleSubmitStandard);
router.post('/petani/submit', handleSubmitStandard);
router.post('/submit', handleSubmitStandard);

// Explicit route bindings for `/api/penyuluh/standar/pending` and `/api/penyuluh/pending`
router.get('/penyuluh/standar/pending', handleGetPendingStandards);
router.get('/penyuluh/pending', handleGetPendingStandards);
router.get('/pending', handleGetPendingStandards);

// Explicit route bindings for `/api/penyuluh/standar/verify` and `/api/penyuluh/verify`
router.post('/penyuluh/standar/verify', handleVerifyStandard);
router.post('/penyuluh/verify', handleVerifyStandard);
router.post('/verify', handleVerifyStandard);

// Farmer standards
router.get('/petani/standar/my-standards', handleGetFarmerStandards);
router.get('/petani/my-standards', handleGetFarmerStandards);
router.get('/my-standards', handleGetFarmerStandards);

module.exports = router;
