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
            connection.query('select * from monitoring_lahan where id = ' + id , (err, result) => {
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
            connection.query('update monitoring_lahan set ? where id =' + id, Data, (err, result) => {
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
            connection.query('delete from monitoring_lahan where id =' + id , (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

    static async StorePenyuluh(Data){
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

    static async getAllPenyuluh(){
        return new Promise((resolve, reject) => {
            connection.query("select * from monitoring_lahan where tipe_penginput = 'penyuluh' or foto_daun is not null order by id desc", (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }

}

module.exports = Model_Monitoring_Lahan;