const connection = require('../config/db');

class Model_Standar_Komoditas {
  /**
   * Submit a new custom baseline standard by a farmer
   */
  static async SubmitStandar(Data) {
    return new Promise((resolve, reject) => {
      // Ensure default status is 'pending'
      Data.status = 'pending';
      connection.query('INSERT INTO standar_komoditas_petani SET ?', Data, (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
  }

  /**
   * Fetch all pending standard submissions for a designated Penyuluh / village
   */
  static async getPendingByPenyuluh(penyuluh_id, desa_id) {
    return new Promise((resolve, reject) => {
      let query = `
        SELECT s.*, 
               u.nama AS nama_petani, u.email AS email_petani, u.no_hp AS no_hp_petani, u.foto_users AS foto_petani,
               w.kecamatan, w.desa
        FROM standar_komoditas_petani s
        JOIN users u ON s.petani_id = u.id
        JOIN master_wilayah_sumenep w ON s.desa_id = w.id
        WHERE s.status = 'pending'
      `;
      const params = [];
      if (desa_id) {
        query += ' AND s.desa_id = ?';
        params.push(desa_id);
      } else if (penyuluh_id) {
        query += ' AND s.penyuluh_id = ?';
        params.push(penyuluh_id);
      }
      query += ' ORDER BY s.created_at DESC';

      connection.query(query, params, (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }

  /**
   * Penyuluh verification action (Verify or Reject with notes)
   */
  static async VerifyStandar(id, penyuluh_id, status, catatan_penyuluh) {
    return new Promise((resolve, reject) => {
      const query = `
        UPDATE standar_komoditas_petani
        SET status = ?, penyuluh_id = ?, catatan_penyuluh = ?
        WHERE id = ?
      `;
      connection.query(query, [status, penyuluh_id, catatan_penyuluh, id], (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
  }

  /**
   * Get single standard by ID with farmer and village metadata
   */
  static async getById(id) {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT s.*, 
               u.nama AS nama_petani, u.email AS email_petani, u.no_hp AS no_hp_petani,
               p.nama AS nama_penyuluh, p.email AS email_penyuluh,
               w.kecamatan, w.desa
        FROM standar_komoditas_petani s
        JOIN users u ON s.petani_id = u.id
        LEFT JOIN users p ON s.penyuluh_id = p.id
        JOIN master_wilayah_sumenep w ON s.desa_id = w.id
        WHERE s.id = ?
      `;
      connection.query(query, [id], (err, rows) => {
        if (err) return reject(err);
        resolve(rows && rows.length > 0 ? rows[0] : null);
      });
    });
  }

  /**
   * Get all standards submitted by a specific farmer
   */
  static async getByPetani(petani_id) {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT s.*, 
               p.nama AS nama_penyuluh, p.no_hp AS no_hp_penyuluh,
               w.kecamatan, w.desa
        FROM standar_komoditas_petani s
        LEFT JOIN users p ON s.penyuluh_id = p.id
        JOIN master_wilayah_sumenep w ON s.desa_id = w.id
        WHERE s.petani_id = ?
        ORDER BY s.id DESC
      `;
      connection.query(query, [petani_id], (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }

  /**
   * Get all verified standards for a village or all Sumenep
   */
  static async getVerified(desa_id = null) {
    return new Promise((resolve, reject) => {
      let query = `
        SELECT s.*, 
               u.nama AS nama_petani, p.nama AS nama_penyuluh,
               w.kecamatan, w.desa
        FROM standar_komoditas_petani s
        JOIN users u ON s.petani_id = u.id
        LEFT JOIN users p ON s.penyuluh_id = p.id
        JOIN master_wilayah_sumenep w ON s.desa_id = w.id
        WHERE s.status = 'verified'
      `;
      const params = [];
      if (desa_id) {
        query += ' AND s.desa_id = ?';
        params.push(desa_id);
      }
      query += ' ORDER BY s.id DESC';

      connection.query(query, params, (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }
}

module.exports = Model_Standar_Komoditas;
