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
})


module.exports = router;
