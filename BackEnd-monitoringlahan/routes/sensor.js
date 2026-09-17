var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_Monitoring_Lahan = require('../model/Model_Monitoring_Lahan');
var router = express.Router();

/* GET sensor data listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    if (!id) return res.redirect('/login');

    let Data = await Model_Users.getId(id);
    let rows = await Model_Monitoring_Lahan.getAll();
    if (Data && Data.length > 0) {
      res.render('admin/sensor/index', {
        currentRoute: '/sensor',
        email: Data[0].email,
        userRole: Data[0].role,
        data: rows
      });
    } else {
      res.redirect('/login');
    }
  } catch (error) {
    console.error('Sensor route error:', error);
    res.status(501).json({ error: 'cant access' });
  }
});

/* GET: Delete sensor data (SUPER ADMIN ONLY) */
router.get('/delete/(:id)', async function(req, res, next) {
  try {
    let userId = req.session.userId;
    if (!userId) {
      req.flash('error', 'Silakan login terlebih dahulu');
      return res.redirect('/login');
    }

    let user = await Model_Users.getId(userId);
    if (!user || user.length === 0 || Number(user[0].role) !== 1) {
      req.flash('error', 'Akses ditolak. Hanya Super Admin yang memiliki hak untuk menghapus data sensor.');
      return res.redirect('/sensor');
    }

    let id = req.params.id;
    await Model_Monitoring_Lahan.Delete(id);
    req.flash('success', 'Data sensor berhasil dihapus.');
    return res.redirect('/sensor');
  } catch (error) {
    console.error('Sensor Delete Error:', error);
    req.flash('error', 'Gagal menghapus data sensor.');
    return res.redirect('/sensor');
  }
});

module.exports = router;
