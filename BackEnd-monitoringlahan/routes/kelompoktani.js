var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_kelompok_tani = require('../model/Model_kelompok_tani');
var router = express.Router();

/* GET kelompok tani listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    if (!id) return res.redirect('/login');

    let Data = await Model_Users.getId(id);
    let rows = await Model_kelompok_tani.getAll();
    if (Data && Data.length > 0) {
      res.render('admin/kelompoktani/index', {
        currentRoute: '/kelompoktani',
        email: Data[0].email,
        userRole: Data[0].role,
        data: rows
      });
    } else {
      res.redirect('/login');
    }
  } catch (error) {
    console.error('Kelompok tani route error:', error);
    res.status(501).json({ error: 'cant access' });
  }
});

/* GET: Delete kelompok tani (SUPER ADMIN ONLY) */
router.get('/delete/(:id)', async function(req, res, next) {
  try {
    let userId = req.session.userId;
    if (!userId) {
      req.flash('error', 'Silakan login terlebih dahulu');
      return res.redirect('/login');
    }

    let user = await Model_Users.getId(userId);
    if (!user || user.length === 0 || Number(user[0].role) !== 1) {
      req.flash('error', 'Akses ditolak: Hanya Super Admin yang memiliki hak menghapus data kelompok tani.');
      return res.redirect('/kelompoktani');
    }

    let id = req.params.id;
    await Model_kelompok_tani.Delete(id);
    req.flash('success', 'Data kelompok tani berhasil dihapus.');
    return res.redirect('/kelompoktani');
  } catch (error) {
    console.error('Kelompok Tani Delete Error:', error);
    req.flash('error', 'Gagal menghapus data kelompok tani.');
    return res.redirect('/kelompoktani');
  }
});

module.exports = router;
