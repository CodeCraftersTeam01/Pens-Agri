const connection = require('../config/db');

class Model_Monitoring_Lahan {

    static async getAll(){
        return new Promise((resolve, reject) => {
            connection.query('select * from monitoring_lahan order by id desc', (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }

    static async getRecent(limit = 100){
        return new Promise((resolve, reject) => {
            connection.query('select * from monitoring_lahan order by id desc limit ?', [limit], (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }

    static async getStatisticalSummary(){
        return new Promise((resolve, reject) => {
            const statsQuery = `
                SELECT 
                    COUNT(*) AS total_titik,
                    ROUND(AVG(ph), 2) AS avg_ph,
                    ROUND(MIN(ph), 2) AS min_ph,
                    ROUND(MAX(ph), 2) AS max_ph,
                    ROUND(AVG(moisture), 2) AS avg_moisture,
                    ROUND(AVG(nitrogen), 2) AS avg_nitrogen,
                    ROUND(AVG(phosphorus), 2) AS avg_phosphorus,
                    ROUND(AVG(potassium), 2) AS avg_potassium,
                    ROUND(AVG(temp), 2) AS avg_temp,
                    ROUND(AVG(conductivity), 2) AS avg_conductivity,
                    SUM(CASE WHEN gagal_panen = 'ya' THEN 1 ELSE 0 END) AS total_gagal_panen,
                    SUM(CASE WHEN kondisi_air = 'Sulit' THEN 1 ELSE 0 END) AS total_air_sulit,
                    SUM(CASE WHEN irigasi = 'ya' THEN 1 ELSE 0 END) AS total_irigasi_aktif,
                    SUM(CASE WHEN pompa_air = 'ya' THEN 1 ELSE 0 END) AS total_pakai_pompa
                FROM monitoring_lahan
            `;

            const komoditasQuery = `
                SELECT 
                    COALESCE(komoditas, 'Lainnya') AS komoditas,
                    COUNT(*) AS jumlah_lahan,
                    ROUND(AVG(ph), 2) AS avg_ph,
                    ROUND(AVG(moisture), 2) AS avg_moisture,
                    ROUND(AVG(nitrogen), 2) AS avg_n,
                    ROUND(AVG(phosphorus), 2) AS avg_p,
                    ROUND(AVG(potassium), 2) AS avg_k,
                    SUM(CASE WHEN gagal_panen = 'ya' THEN 1 ELSE 0 END) AS kasus_gagal_panen
                FROM monitoring_lahan
                GROUP BY komoditas
                ORDER BY jumlah_lahan DESC
                LIMIT 10
            `;

            const criticalZonesQuery = `
                SELECT 
                    nama_desa,
                    kelompok_tani,
                    komoditas,
                    luas_lahan,
                    ph,
                    moisture,
                    nitrogen,
                    phosphorus,
                    potassium,
                    kondisi_air,
                    gagal_panen
                FROM monitoring_lahan
                WHERE ph < 6.0 OR ph > 7.5 OR moisture < 30 OR gagal_panen = 'ya' OR kondisi_air = 'Sulit'
                ORDER BY id DESC
                LIMIT 15
            `;

            Promise.all([
                new Promise((res, rej) => connection.query(statsQuery, (e, r) => e ? rej(e) : res(r[0]))),
                new Promise((res, rej) => connection.query(komoditasQuery, (e, r) => e ? rej(e) : res(r))),
                new Promise((res, rej) => connection.query(criticalZonesQuery, (e, r) => e ? rej(e) : res(r)))
            ]).then(([stats, komoditas, criticalZones]) => {
                resolve({
                    ringkasan_umum: stats,
                    distribusi_komoditas: komoditas,
                    sampel_titik_kritis: criticalZones
                });
            }).catch(reject);
        });
    }
    static async Store(Data){
        return new Promise((resolve, reject) => {
            connection.query('insert into monitoring_lahan set ?', Data, function(err, result) {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

    static async Login(email){
        return new Promise((resolve, reject) => {
            connection.query('select * from monitoring_lahan where email = ?', [email], (err, result) => {
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
            connection.query('select * from monitoring_lahan where id = ?', [id], (err, result) => {
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
            connection.query('update monitoring_lahan set ? where id = ?', [Data, id], (err, result) => {
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
            connection.query('delete from monitoring_lahan where id = ?', [id], (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

}

module.exports = Model_Monitoring_Lahan;