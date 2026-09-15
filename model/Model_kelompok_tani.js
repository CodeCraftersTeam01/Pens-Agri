const connection = require('../config/db');

class Model_kelompok_tani {

    static async getAll(){
        return new Promise((resolve, reject) => {
            connection.query('select * from kelompok_tani order by id desc', (err, rows) => {
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
            connection.query('insert into kelompok_tani set ?', Data, function(err, result) {
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
            connection.query('select * from kelompok_tani where email = ?', [email], (err, result) => {
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
            connection.query('select * from kelompok_tani where id = ' + id , (err, result) => {
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
            connection.query('update kelompok_tani set ? where id =' + id, Data, (err, result) => {
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
            connection.query('delete from kelompok_tani where id =' + id , (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

}

module.exports = Model_kelompok_tani;