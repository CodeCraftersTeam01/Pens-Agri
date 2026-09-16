var express = require('express');
var router = express.Router();
const bcrypt = require('bcryptjs');

var Model_Users = require('../model/Model_Users');
/* GET home page & login page. */
router.get('/', function(req, res, next) {
  if (req.session && req.session.userId) {
    if (req.session.level == 1) return res.redirect('/superusers');
    return res.redirect('/users');
  }
  res.render('auth/login');
});

router.get('/login', function(req, res, next) {
  if (req.session && req.session.userId) {
    if (req.session.level == 1) return res.redirect('/superusers');
    return res.redirect('/users');
  }
  res.render('auth/login');
});

router.get('/register', function(req, res, next) {
  res.render('auth/register');
});

router.post('/register', async (req, res) => {
  let {email, password} = req.body;
  let enkripsi = await bcrypt.hash(password, 10);
  let Data = {
    email,
    password: enkripsi,
    role: 1,
  };
  await Model_Users.Store(Data);
  req.flash('success','Registrasi Berhasil');
  res.redirect('/login');
})

router.post('/login', async (req, res) => {
    let { email, password } = req.body;

    try {
        let Data = await Model_Users.Login(email);

        if (Data.length > 0) {
            let enkripsi = Data[0].password;
            let cek = await bcrypt.compare(password, enkripsi);

            if (cek) {
                req.session.userId = Data[0].id;
                req.session.level = Data[0].role; // simpan level di session
                req.session.userEmail = Data[0].email;

                // Simpan session secara eksplisit sebelum redirect ke dashboard
                req.session.save(function(err) {
                    if (err) console.error("Session save error:", err);

                    // pengecekan level
                    if (Data[0].role == 1) {
                        req.flash('success', 'Berhasil login sebagai Super User');
                        return res.redirect('/superusers');
                    } else if (Data[0].role == 2) {
                        req.flash('success', 'Berhasil login sebagai User');
                        return res.redirect('/users');
                    } else {
                        req.flash('error', 'Level user tidak dikenali');
                        return res.redirect('/login');
                    }
                });

            } else {
                req.flash('error', 'Email atau password salah');
                return res.redirect('/login');
            }

        } else {
            req.flash('error', 'Akun tidak ditemukan');
            return res.redirect('/login');
        }

    } catch (err) {
        console.error(err);
        req.flash('error', 'Terjadi kesalahan pada sistem');
        return res.redirect('/login');
    }
});

router.get('/logout', function(req, res){
  req.session.destroy(function(err){
    if(err){
      console.error(err);
    }
    res.clearCookie('pens_agri_sid');
    res.redirect('/login');
  });
});

router.get('/components', function(req, res, next) {
  res.render('admin/components', {
    currentRoute: '/components',
    email: (req.session && req.session.userId) ? 'admin@pens-agri.ac.id' : 'guest@pens-agri.ac.id'
  });
});

module.exports = router;
