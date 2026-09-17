const connection = require('../config/db');

class Model_Forum {
  /**
   * Create a new forum post with optional custom standard attached
   */
  static async createPost(Data) {
    return new Promise((resolve, reject) => {
      connection.query('INSERT INTO forum_posts SET ?', Data, (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
  }

  /**
   * Add a comment to a forum post
   */
  static async createComment(Data) {
    return new Promise((resolve, reject) => {
      connection.query('INSERT INTO forum_comments SET ?', Data, (err, result) => {
        if (err) return reject(err);
        resolve(result);
      });
    });
  }

  /**
   * Get community forum feed with author details, attached standards, verification badges & comments count
   */
  static async getFeed(limit = 50, offset = 0) {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT 
          p.id AS post_id,
          p.title,
          p.body,
          p.created_at AS post_created_at,
          p.updated_at AS post_updated_at,
          
          -- Author Info
          u.id AS author_id,
          u.nama AS author_name,
          u.role AS author_role,
          u.foto_users AS author_photo,
          w.kecamatan AS author_kecamatan,
          w.desa AS author_desa,

          -- Attached Standard Info
          s.id AS attached_standar_id,
          s.komoditas AS standar_komoditas,
          s.varietas AS standar_varietas,
          s.min_ph, s.max_ph,
          s.min_moisture, s.max_moisture,
          s.min_n, s.max_n,
          s.min_p, s.max_p,
          s.min_k, s.max_k,
          s.min_temp, s.max_temp,
          s.min_ec, s.max_ec,
          s.min_fertility, s.max_fertility,
          s.status AS standar_status,
          s.catatan_penyuluh,

          -- Comments Count
          (SELECT COUNT(*) FROM forum_comments fc WHERE fc.post_id = p.id) AS total_comments

        FROM forum_posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
        LEFT JOIN standar_komoditas_petani s ON p.standar_id = s.id
        ORDER BY p.created_at DESC
        LIMIT ? OFFSET ?
      `;

      connection.query(query, [parseInt(limit, 10), parseInt(offset, 10)], (err, rows) => {
        if (err) return reject(err);

        // Process rows to compute explicit verification flags and warnings
        const processedRows = rows.map(r => {
          const hasAttachedStandard = r.attached_standar_id !== null;
          const isVerified = hasAttachedStandard && r.standar_status === 'verified';
          const verificationWarning = hasAttachedStandard && !isVerified
            ? 'Standar ini belum diverifikasi penyuluh'
            : null;

          let attachedStandard = null;
          if (hasAttachedStandard) {
            attachedStandard = {
              id: r.attached_standar_id,
              komoditas: r.standar_komoditas,
              varietas: r.standar_varietas,
              min_ph: r.min_ph,
              max_ph: r.max_ph,
              min_moisture: r.min_moisture,
              max_moisture: r.max_moisture,
              min_n: r.min_n,
              max_n: r.max_n,
              min_p: r.min_p,
              max_p: r.max_p,
              min_k: r.min_k,
              max_k: r.max_k,
              min_temp: r.min_temp,
              max_temp: r.max_temp,
              min_ec: r.min_ec,
              max_ec: r.max_ec,
              min_fertility: r.min_fertility,
              max_fertility: r.max_fertility,
              status: r.standar_status,
              is_verified: isVerified,
              warning_text: verificationWarning,
              catatan_penyuluh: r.catatan_penyuluh
            };
          }

          return {
            id: r.post_id,
            title: r.title,
            body: r.body,
            created_at: r.post_created_at,
            updated_at: r.post_updated_at,
            author: {
              id: r.author_id,
              name: r.author_name || 'Petani Sumenep',
              role: r.author_role,
              photo: r.author_photo,
              kecamatan: r.author_kecamatan,
              desa: r.author_desa
            },
            has_attached_standard: hasAttachedStandard,
            is_verified: isVerified,
            verification_status: r.standar_status,
            verification_warning: verificationWarning,
            attached_standard: attachedStandard,
            total_comments: r.total_comments
          };
        });

        resolve(processedRows);
      });
    });
  }

  /**
   * Get single forum post with its full comment thread
   */
  static async getPostById(post_id) {
    return new Promise((resolve, reject) => {
      const postQuery = `
        SELECT 
          p.id AS post_id,
          p.title,
          p.body,
          p.created_at AS post_created_at,
          
          u.id AS author_id,
          u.nama AS author_name,
          u.role AS author_role,
          u.foto_users AS author_photo,
          w.kecamatan AS author_kecamatan,
          w.desa AS author_desa,

          s.id AS attached_standar_id,
          s.komoditas AS standar_komoditas,
          s.varietas AS standar_varietas,
          s.min_ph, s.max_ph,
          s.min_moisture, s.max_moisture,
          s.min_n, s.max_n,
          s.min_p, s.max_p,
          s.min_k, s.max_k,
          s.min_temp, s.max_temp,
          s.min_ec, s.max_ec,
          s.min_fertility, s.max_fertility,
          s.status AS standar_status,
          s.catatan_penyuluh

        FROM forum_posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
        LEFT JOIN standar_komoditas_petani s ON p.standar_id = s.id
        WHERE p.id = ?
      `;

      const commentsQuery = `
        SELECT 
          c.id AS comment_id,
          c.comment,
          c.created_at AS comment_created_at,
          u.id AS user_id,
          u.nama AS user_name,
          u.role AS user_role,
          u.foto_users AS user_photo,
          w.kecamatan,
          w.desa
        FROM forum_comments c
        JOIN users u ON c.user_id = u.id
        LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
        WHERE c.post_id = ?
        ORDER BY c.created_at ASC
      `;

      connection.query(postQuery, [post_id], (err, postRows) => {
        if (err) return reject(err);
        if (!postRows || postRows.length === 0) return resolve(null);

        const r = postRows[0];
        const hasAttachedStandard = r.attached_standar_id !== null;
        const isVerified = hasAttachedStandard && r.standar_status === 'verified';
        const verificationWarning = hasAttachedStandard && !isVerified
          ? 'Standar ini belum diverifikasi penyuluh'
          : null;

        let attachedStandard = null;
        if (hasAttachedStandard) {
          attachedStandard = {
            id: r.attached_standar_id,
            komoditas: r.standar_komoditas,
            varietas: r.standar_varietas,
            min_ph: r.min_ph,
            max_ph: r.max_ph,
            min_moisture: r.min_moisture,
            max_moisture: r.max_moisture,
            min_n: r.min_n,
            max_n: r.max_n,
            min_p: r.min_p,
            max_p: r.max_p,
            min_k: r.min_k,
            max_k: r.max_k,
            min_temp: r.min_temp,
            max_temp: r.max_temp,
            min_ec: r.min_ec,
            max_ec: r.max_ec,
            min_fertility: r.min_fertility,
            max_fertility: r.max_fertility,
            status: r.standar_status,
            is_verified: isVerified,
            warning_text: verificationWarning,
            catatan_penyuluh: r.catatan_penyuluh
          };
        }

        connection.query(commentsQuery, [post_id], (err, commentRows) => {
          if (err) return reject(err);

          const comments = commentRows.map(c => ({
            id: c.comment_id,
            comment: c.comment,
            created_at: c.comment_created_at,
            author: {
              id: c.user_id,
              name: c.user_name || 'User',
              role: c.user_role,
              photo: c.user_photo,
              kecamatan: c.kecamatan,
              desa: c.desa
            }
          }));

          resolve({
            id: r.post_id,
            title: r.title,
            body: r.body,
            created_at: r.post_created_at,
            author: {
              id: r.author_id,
              name: r.author_name || 'Petani Sumenep',
              role: r.author_role,
              photo: r.author_photo,
              kecamatan: r.author_kecamatan,
              desa: r.author_desa
            },
            has_attached_standard: hasAttachedStandard,
            is_verified: isVerified,
            verification_status: r.standar_status,
            verification_warning: verificationWarning,
            attached_standard: attachedStandard,
            comments: comments,
            total_comments: comments.length
          });
        });
      });
    });
  }
}

module.exports = Model_Forum;
