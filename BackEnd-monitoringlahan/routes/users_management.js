const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const Model_Users = require('../model/Model_Users');

// Middleware: Hanya Super Admin (role = 1) yang diizinkan mengakses
async function checkSuperAdmin(req, res, next) {
  try {
    const id = req.session.userId;
    if (!id) {
      req.flash('error', 'Silakan login terlebih dahulu');
      return res.redirect('/login');
    }
    const userData = await Model_Users.getId(id);
    if (!userData || userData.length === 0 || Number(userData[0].role) !== 1) {
      req.flash('error', 'Akses ditolak: Menu Manajemen Akun hanya dapat diakses oleh Super Admin.');
      return res.redirect('/users');
    }
    req.currentUser = userData[0];
    next();
  } catch (error) {
    console.error('SuperAdmin Guard Error:', error);
    return res.redirect('/login');
  }
}

// 1. GET: Halaman Manajemen Akun
router.get('/', checkSuperAdmin, async function(req, res, next) {
  try {
    const allUsers = await Model_Users.getAll();

    const superAdminCount = allUsers.filter(u => Number(u.role) === 1).length;
    const petaniCount = allUsers.filter(u => Number(u.role) === 2).length;

    res.render('admin/users_management/index', {
      currentRoute: '/users_management',
      email: req.currentUser.email,
      currentUserId: req.currentUser.id,
      userRole: Number(req.currentUser.role),
      users: allUsers,
      totalUsers: allUsers.length,
      superAdminCount,
      petaniCount,
      messages: req.flash()
    });
  } catch (error) {
    console.error('Users Management Error:', error);
    req.flash('error', 'Gagal memuat data manajemen akun');
    res.redirect('/users');
  }
});

// 2. POST: Tambah User Baru
router.post('/create', checkSuperAdmin, async function(req, res) {
  try {
    const { email, password, role } = req.body;
    if (!email || !password) {
      req.flash('error', 'Email dan password wajib diisi.');
      return res.redirect('/users_management');
    }

    const existing = await Model_Users.Login(email.trim());
    if (existing && existing.length > 0) {
      req.flash('error', `Email ${email} sudah terdaftar di sistem.`);
      return res.redirect('/users_management');
    }

    const encrypted = await bcrypt.hash(password, 10);
    const newUser = {
      email: email.trim(),
      password: encrypted,
      role: parseInt(role, 10) === 1 ? 1 : 2
    };

    await Model_Users.Store(newUser);
    req.flash('success', `Pengguna ${email} (${newUser.role === 1 ? 'Super Admin' : 'Petani/User'}) berhasil ditambahkan.`);
    res.redirect('/users_management');
  } catch (error) {
    console.error('Create User Error:', error);
    req.flash('error', 'Gagal menambahkan pengguna baru.');
    res.redirect('/users_management');
  }
});

// 3. POST: Ubah Role User
router.post('/update-role/:id', checkSuperAdmin, async function(req, res) {
  try {
    const targetId = req.params.id;
    const newRole = parseInt(req.body.role, 10);

    if (parseInt(targetId, 10) === req.currentUser.id && newRole !== 1) {
      req.flash('error', 'Anda tidak dapat menurunkan hak akses akun Super Admin Anda sendiri.');
      return res.redirect('/users_management');
    }

    await Model_Users.Update(targetId, { role: newRole === 1 ? 1 : 2 });
    req.flash('success', 'Hak akses akun pengguna berhasil diperbarui.');
    res.redirect('/users_management');
  } catch (error) {
    console.error('Update Role Error:', error);
    req.flash('error', 'Gagal memperbarui hak akses pengguna.');
    res.redirect('/users_management');
  }
});

// 4. GET: Hapus User
router.get('/delete/:id', checkSuperAdmin, async function(req, res) {
  try {
    const targetId = req.params.id;

    if (parseInt(targetId, 10) === req.currentUser.id) {
      req.flash('error', 'Anda tidak dapat menghapus akun Anda sendiri saat sedang aktif.');
      return res.redirect('/users_management');
    }

    await Model_Users.Delete(targetId);
    req.flash('success', 'Akun pengguna berhasil dihapus.');
    res.redirect('/users_management');
  } catch (error) {
    console.error('Delete User Error:', error);
    req.flash('error', 'Gagal menghapus pengguna.');
    res.redirect('/users_management');
  }
});

module.exports = router;
