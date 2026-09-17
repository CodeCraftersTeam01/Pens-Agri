const connection = require('../config/db');

class Model_Users {
    static async getAll(){
        return new Promise((resolve, reject) => {
            const query = `
                SELECT u.id, u.nama, u.email, u.no_hp, u.role, u.desa_id, u.foto_users, u.created_at,
                       w.kecamatan, w.desa
                FROM users u
                LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
                ORDER BY u.id DESC
            `;
            connection.query(query, (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }

    static async Store(Data){
        return new Promise((resolve, reject) => {
            connection.query('INSERT INTO users SET ?', Data, function(err, result) {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

    /**
     * Check if a Penyuluh is already assigned to a given village (desa_id)
     * Enforces the invariant: 1 Desa = 1 Penyuluh
     */
    static async checkPenyuluhExistsInDesa(desa_id) {
        return new Promise((resolve, reject) => {
            connection.query(
                "SELECT id, nama, email FROM users WHERE role = 'penyuluh' AND desa_id = ?",
                [desa_id],
                (err, rows) => {
                    if (err) return reject(err);
                    resolve(rows && rows.length > 0 ? rows[0] : null);
                }
            );
        });
    }

    /**
     * Get the designated Penyuluh for a given village
     */
    static async getPenyuluhByDesa(desa_id) {
        return new Promise((resolve, reject) => {
            const query = `
                SELECT u.id, u.nama, u.email, u.no_hp, u.foto_users, w.kecamatan, w.desa
                FROM users u
                LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
                WHERE u.role = 'penyuluh' AND u.desa_id = ?
                LIMIT 1
            `;
            connection.query(query, [desa_id], (err, rows) => {
                if (err) return reject(err);
                resolve(rows && rows.length > 0 ? rows[0] : null);
            });
        });
    }

    static async Login(email){
        return new Promise((resolve, reject) => {
            const query = `
                SELECT u.id, u.nama, u.email, u.password, u.no_hp, u.role, u.desa_id, u.foto_users,
                       w.kecamatan, w.desa
                FROM users u
                LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
                WHERE u.email = ?
            `;
            connection.query(query, [email], (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

    static async getId(id){
        return new Promise((resolve, reject) => {
            if (!id) return resolve([]);
            const query = `
                SELECT u.id, u.nama, u.email, u.no_hp, u.role, u.desa_id, u.foto_users, u.created_at,
                       w.kecamatan, w.desa
                FROM users u
                LEFT JOIN master_wilayah_sumenep w ON u.desa_id = w.id
                WHERE u.id = ?
            `;
            connection.query(query, [id], (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

    static async Update(id, Data){
        return new Promise((resolve, reject) => {
            if (!id) return resolve(null);
            connection.query('UPDATE users SET ? WHERE id = ?', [Data, id], (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

    static async Delete(id){
        return new Promise((resolve, reject) => {
            if (!id) return resolve(null);
            connection.query('DELETE FROM users WHERE id = ?', [id], (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }
}

module.exports = Model_Users;