const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const Model_Users = require('../../model/Model_Users');
const Model_Wilayah_Sumenep = require('../../model/Model_Wilayah_Sumenep');

/**
 * POST /api/auth/register
 * Register Petani or Penyuluh with Sumenep village pairing
 * Enforces Invariant: Exactly 1 Penyuluh per Desa (1 Desa = 1 Penyuluh)
 */
router.post('/register', async (req, res) => {
  try {
    const { nama, email, password, no_hp, role, desa_id } = req.body;

    if (!email || !password || !role || !desa_id) {
      return res.status(400).json({
        status: false,
        message: 'Parameter wajib: email, password, role (petani/penyuluh), dan desa_id'
      });
    }

    const normalizedRole = role.toLowerCase();
    if (!['petani', 'penyuluh'].includes(normalizedRole)) {
      return res.status(400).json({
        status: false,
        message: 'Role harus berupa "petani" atau "penyuluh"'
      });
    }

    // 1. Verify village exists in Kabupaten Sumenep
    const wilayah = await Model_Wilayah_Sumenep.getById(desa_id);
    if (!wilayah) {
      return res.status(400).json({
        status: false,
        message: 'Desa ID tidak ditemukan dalam master wilayah Kabupaten Sumenep'
      });
    }

    // 2. Check if email already registered
    const existingUser = await Model_Users.Login(email);
    if (existingUser && existingUser.length > 0) {
      return res.status(400).json({
        status: false,
        message: 'Email sudah terdaftar. Silakan gunakan email lain.'
      });
    }

    // 3. Enforce INVARIANT: 1 Desa = 1 Penyuluh
    if (normalizedRole === 'penyuluh') {
      const existingPenyuluh = await Model_Users.checkPenyuluhExistsInDesa(desa_id);
      if (existingPenyuluh) {
        return res.status(400).json({
          status: false,
          message: `Desa ${wilayah.desa} (${wilayah.kecamatan}) sudah memiliki 1 Penyuluh binaan terdaftar (${existingPenyuluh.nama || existingPenyuluh.email}). Pilih desa lain.`
        });
      }
    }

    // 4. Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 5. Store user
    const newUser = {
      nama: nama || (normalizedRole === 'penyuluh' ? 'Penyuluh ' + wilayah.desa : 'Petani ' + wilayah.desa),
      email: email.trim().toLowerCase(),
      password: hashedPassword,
      no_hp: no_hp || '',
      role: normalizedRole,
      desa_id: parseInt(desa_id, 10),
      foto_users: null
    };

    const result = await Model_Users.Store(newUser);
    const createdUserId = result.insertId;

    // 6. If farmer, find designated village Penyuluh
    let pairedPenyuluh = null;
    if (normalizedRole === 'petani') {
      pairedPenyuluh = await Model_Users.getPenyuluhByDesa(desa_id);
    }

    return res.status(201).json({
      status: true,
      message: `Registrasi ${normalizedRole} berhasil di Desa ${wilayah.desa}, Kecamatan ${wilayah.kecamatan}`,
      data: {
        user: {
          id: createdUserId,
          nama: newUser.nama,
          email: newUser.email,
          no_hp: newUser.no_hp,
          role: newUser.role,
          desa_id: newUser.desa_id,
          kecamatan: wilayah.kecamatan,
          desa: wilayah.desa
        },
        paired_penyuluh: pairedPenyuluh
      }
    });

  } catch (error) {
    console.error('Error during registration:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal melakukan registrasi',
      error: error.message
    });
  }
});

/**
 * POST /api/auth/login
 * User login with auto village & paired penyuluh resolution
 */
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        status: false,
        message: 'Email dan password wajib diisi'
      });
    }

    const rows = await Model_Users.Login(email.trim().toLowerCase());
    if (!rows || rows.length === 0) {
      return res.status(401).json({
        status: false,
        message: 'Email atau password tidak valid'
      });
    }

    const user = rows[0];

    // Check password
    let isMatch = false;
    if (user.password.startsWith('$2b$') || user.password.startsWith('$2a$')) {
      isMatch = await bcrypt.compare(password, user.password);
    } else {
      isMatch = (password === user.password);
    }

    if (!isMatch) {
      return res.status(401).json({
        status: false,
        message: 'Email atau password tidak valid'
      });
    }

    // Auto resolve paired penyuluh if role is petani
    let pairedPenyuluh = null;
    if (user.role === 'petani' && user.desa_id) {
      pairedPenyuluh = await Model_Users.getPenyuluhByDesa(user.desa_id);
    }

    return res.status(200).json({
      status: true,
      message: 'Login berhasil',
      data: {
        user: {
          id: user.id,
          nama: user.nama,
          email: user.email,
          no_hp: user.no_hp,
          role: user.role,
          desa_id: user.desa_id,
          kecamatan: user.kecamatan,
          desa: user.desa,
          foto_users: user.foto_users
        },
        paired_penyuluh: pairedPenyuluh
      }
    });

  } catch (error) {
    console.error('Error during login:', error);
    return res.status(500).json({
      status: false,
      message: 'Gagal melakukan login',
      error: error.message
    });
  }
});

/**
 * GET /api/auth/me/:id
 * Get user profile and assigned pairing
 */
router.get('/me/:id', async (req, res) => {
  try {
    const rows = await Model_Users.getId(req.params.id);
    if (!rows || rows.length === 0) {
      return res.status(404).json({
        status: false,
        message: 'User tidak ditemukan'
      });
    }

    const user = rows[0];
    let pairedPenyuluh = null;
    if (user.role === 'petani' && user.desa_id) {
      pairedPenyuluh = await Model_Users.getPenyuluhByDesa(user.desa_id);
    }

    return res.status(200).json({
      status: true,
      data: {
        user,
        paired_penyuluh: pairedPenyuluh
      }
    });
  } catch (error) {
    return res.status(500).json({
      status: false,
      error: error.message
    });
  }
});

module.exports = router;
