var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_Kendaraan = require('../model/Model_Kendaraan');
const Model_Pengunjung = require('../model/Model_Pengunjung');
const Model_Tarif = require('../model/Model_Tarif');
var router = express.Router();

const moment = require('moment');

const fs = require('fs');
const multer = require('multer');
const path = require('path');
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/images/parkir_in')
  },
  filename: (req, file, cb) => {
    console.log(file)
    cb(null, Date.now() + path.extname(file.originalname))
  }
})
const upload = multer({storage: storage})


/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    let ParkirIn = await Model_Kendaraan.getParkirIn();
    let ParkirOut = await Model_Kendaraan.getParkirOut();
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        res.redirect('/logout')
      }else{
        // res.send('User biasa');
        res.render('parkir/index', {
          email: Data[0].email,
          parkirIn: ParkirIn,
          ParkirOut: ParkirOut,
        });
      }
    }else{
      res.status(401).json({error: 'user not found'});
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
    // res.redirect('/logout')
    
  }
  
});



router.post('/masuk', upload.fields([{ name: "wajah" }, { name: "pakaian" }]), async (req, res) => {
  let {nopol, type, jenis_kelamin} = req.body;
  let id = req.session.userId;
  let Users = await Model_Users.getId(id);

  let now = new Date();
  let tanggal = moment(now).format("YYYY-MM-DD");
  let jam = moment(now).format("HH:mm:ss");
  let Data = {
    nopol,
    type,
    warna: "Hitam",
    tanggal_masuk: tanggal,
    jam_masuk: jam,
    status: "In",
    id_users: Users[0].id,
  };
  let result = await Model_Kendaraan.Store(Data);

      // Ambil id kendaraan yang baru disimpan
      let id_kendaraan = result.insertId;

      // Ambil file wajah & pakaian dari multer
      let wajahFile = req.files["wajah"] ? req.files["wajah"][0].filename : null;
      let pakaianFile = req.files["pakaian"] ? req.files["pakaian"][0].filename : null;

      // Simpan ke tabel pengunjung
      let DataPengunjung = {
        wajah: wajahFile,
        pakaian: pakaianFile,
        jenis_kelamin: jenis_kelamin,
        id_kendaraan,
      };

      await Model_Pengunjung.Store(DataPengunjung);

  req.flash('success','Registrasi Berhasil');
  res.redirect('/parkir');
})

router.post('/keluar/(:id)', upload.fields([{ name: "wajah-out" }, { name: "pakaian-out" }]), async (req, res) => {
  let {total_biaya, jenis_kelamin_out} = req.body;
   let id = req.params.id;

  let now = new Date();
  let tanggal = moment(now).format("YYYY-MM-DD");
  let jam = moment(now).format("HH:mm:ss");
  let Data = {
    total_biaya,
    tanggal_keluar: tanggal,
    jam_keluar: jam,
    status: "Out",
  };
  let result = await Model_Kendaraan.Update(id, Data);

      // let id_kendaraan = result.insertId;
      let wajahFile = req.files["wajah-out"] ? req.files["wajah-out"][0].filename : null;
      let pakaianFile = req.files["pakaian-out"] ? req.files["pakaian-out"][0].filename : null;

      let DataPengunjung = {
        wajah: wajahFile,
        pakaian: pakaianFile,
        jenis_kelamin: jenis_kelamin_out,
        id_kendaraan: id,
      };

      await Model_Pengunjung.Store(DataPengunjung);

  req.flash('success','Registrasi Berhasil');
  res.redirect('/parkir');
})


router.get('/deleteparkirin/(:id)', async function(req, res, next){
  let id = req.params.id;
  await Model_Kendaraan.Delete(id);
  req.flash('success','Hapus Transaksi Berhasil');
  res.redirect('/parkir');
})



router.post('/cek', async function(req, res, next) {
  try {
    let idUser = req.session.userId;
    let Data = await Model_Users.getId(idUser);

    if (Data.length > 0 && Data[0].role == 2) {
      let kodeParkir = req.body.kode_parkir;

      let kendaraanData = await Model_Kendaraan.getId(kodeParkir);
      let ParkirIn = await Model_Kendaraan.getParkirIn();
      let ParkirOut = await Model_Kendaraan.getParkirOut();

      if (kendaraanData.length > 0) {
        let kendaraan = kendaraanData[0];

         if (kendaraan.status === "Out") {
          return res.render('parkir/index', {
            email: Data[0].email,
            kendaraan: null,
            parkirIn: ParkirIn,
            ParkirOut: ParkirOut,
            error: "Kendaraan sudah keluar."
          });
        }

        let tanggal = moment(kendaraan.tanggal_masuk).format('YYYY-MM-DD');
        let jam = kendaraan.jam_masuk;
        let masuk = moment(`${tanggal} ${jam}`, 'YYYY-MM-DD HH:mm:ss');

        let sekarang = moment();

        // Hitung 
        let durasiJam = Math.ceil(moment.duration(sekarang.diff(masuk)).asHours());

        let tarifData = await Model_Tarif.getByJenis(kendaraan.type);

        let totalTarif = 0;
        let biayaTambahan = 0;
        let tarifDasar = 0;

        if (tarifData.length > 0) {
          let tarif = tarifData[0];
          tarifDasar = parseInt(tarif.harga);

          if (durasiJam <= 1) {
            totalTarif = tarifDasar;
          } else {
            biayaTambahan = (durasiJam - 1) * 500;
            totalTarif = tarifDasar + biayaTambahan;
          }
        }

        res.render('parkir/index', {
           email: Data[0].email,
          kendaraan: kendaraan,
          durasiJam: durasiJam,
          tarifDasar: tarifDasar,
          biayaTambahan: biayaTambahan,
          totalTarif: totalTarif,
          parkirIn: ParkirIn,
          ParkirOut: ParkirOut,
        });
      } else {
        res.render('parkir/index', {
          email: Data[0].email,
          kendaraan: null,
          parkirIn: ParkirIn,
          ParkirOut: ParkirOut,
          error: 'Kode parkir tidak ditemukan.'
        });
      }
    } else {
      res.redirect('/logout');
    }
  } catch (error) {
    console.error(error);
    res.status(500).send('Terjadi kesalahan server');
  }
});


module.exports = router;
