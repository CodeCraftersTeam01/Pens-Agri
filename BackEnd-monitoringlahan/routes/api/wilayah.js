const express = require('express');
const router = express.Router();
const Model_Wilayah_Sumenep = require('../../model/Model_Wilayah_Sumenep');

/**
 * GET /api/wilayah/sumenep
 * Returns master list of subdistricts (kecamatan) and villages (desa) in Kabupaten Sumenep
 * Query params: ?kecamatan=... or ?q=...
 */
router.get('/sumenep', async (req, res) => {
  try {
    const { kecamatan, q } = req.query;
    let list;

    if (kecamatan) {
      list = await Model_Wilayah_Sumenep.getDesaByKecamatan(kecamatan);
    } else {
      list = await Model_Wilayah_Sumenep.getAll();
    }

    if (q && q.trim().length > 0) {
      const search = q.toLowerCase();
      list = list.filter(item => 
        item.kecamatan.toLowerCase().includes(search) || 
        item.desa.toLowerCase().includes(search)
      );
    }

    // Also get grouped kecamatan list
    const kecamatanList = await Model_Wilayah_Sumenep.getAllKecamatan();

    return res.status(200).json({
      status: true,
      message: 'Master Wilayah Kabupaten Sumenep',
      kabupaten: 'Kabupaten Sumenep',
      total_kecamatan: kecamatanList.length,
      total_desa: list.length,
      kecamatan_list: kecamatanList,
      data: list
    });
  } catch (error) {
    console.error('Error fetching Sumenep wilayah:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal mengambil master wilayah Kabupaten Sumenep',
      error: error.message
    });
  }
});

module.exports = router;
