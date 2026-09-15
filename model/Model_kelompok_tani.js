const connection = require('../config/db');
const { getOrSet, invalidatePrefix } = require('../utils/cache');

class Model_kelompok_tani {

    static async getAll(){
        return getOrSet('poktan_all', () => {
            return new Promise((resolve, reject) => {
                connection.query('SELECT * FROM kelompok_tani ORDER BY id DESC', (err, rows) => {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(rows);
                    }
                });
            });
        }, 180); // Cache 3 menit
    }

    static async Store(Data){
        return new Promise((resolve, reject) => {
            connection.query('INSERT INTO kelompok_tani SET ?', Data, function(err, result) {
                if (err) {
                    reject(err);
                } else {
                    invalidatePrefix('poktan_');
                    resolve(result);
                }
            });
        });
    }

    static async Login(email){
        return new Promise((resolve, reject) => {
            connection.query('SELECT * FROM kelompok_tani WHERE email = ?', [email], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async getId(id){
        return new Promise((resolve, reject) => {
            if (!id) return resolve([]);
            connection.query('SELECT * FROM kelompok_tani WHERE id = ?', [id], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        });
    }

    static async Update(id, Data){
        return new Promise((resolve, reject) => {
            if (!id) return resolve(null);
            connection.query('UPDATE kelompok_tani SET ? WHERE id = ?', [Data, id], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    invalidatePrefix('poktan_');
                    resolve(result);
                }
            });
        });
    }

    static async Delete(id){
        return new Promise((resolve, reject) => {
            if (!id) return resolve(null);
            connection.query('DELETE FROM kelompok_tani WHERE id = ?', [id], (err, result) => {
                if (err) {
                    reject(err);
                } else {
                    invalidatePrefix('poktan_');
                    resolve(result);
                }
            });
        });
    }

}

module.exports = Model_kelompok_tani;