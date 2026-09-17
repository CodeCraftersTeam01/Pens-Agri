const connection = require('../config/db');

class Model_Wilayah_Sumenep {
  /**
   * Retrieve all distinct kecamatan in Kabupaten Sumenep
   */
  static async getAllKecamatan() {
    return new Promise((resolve, reject) => {
      connection.query('SELECT DISTINCT kecamatan FROM master_wilayah_sumenep ORDER BY kecamatan ASC', (err, rows) => {
        if (err) return reject(err);
        resolve(rows.map(r => r.kecamatan));
      });
    });
  }

  /**
   * Retrieve all villages (desa) for a specific kecamatan
   */
  static async getDesaByKecamatan(kecamatan) {
    return new Promise((resolve, reject) => {
      connection.query('SELECT id, kecamatan, desa FROM master_wilayah_sumenep WHERE kecamatan = ? ORDER BY desa ASC', [kecamatan], (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }

  /**
   * Retrieve complete list of all villages & sub-districts in Kabupaten Sumenep
   */
  static async getAll() {
    return new Promise((resolve, reject) => {
      connection.query('SELECT id, kecamatan, desa FROM master_wilayah_sumenep ORDER BY kecamatan ASC, desa ASC', (err, rows) => {
        if (err) return reject(err);
        resolve(rows);
      });
    });
  }

  /**
   * Get single village by ID
   */
  static async getById(id) {
    return new Promise((resolve, reject) => {
      connection.query('SELECT id, kecamatan, desa FROM master_wilayah_sumenep WHERE id = ?', [id], (err, rows) => {
        if (err) return reject(err);
        resolve(rows && rows.length > 0 ? rows[0] : null);
      });
    });
  }
}

module.exports = Model_Wilayah_Sumenep;
