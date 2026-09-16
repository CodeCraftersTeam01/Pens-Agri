const connection = require('../config/db');

class Model_Tarif {

    static async getAll(){
        return new Promise((resolve, reject) => {
            connection.query('select * from tarif order by id desc', (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }

    static async getByJenis(jenis){
        return new Promise((resolve, reject) => {
            connection.query('SELECT * FROM tarif WHERE jenis = ?', [jenis], (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }


    static async Store(Data){
        return new Promise((resolve, reject) => {
            connection.query('insert into tarif set ?', Data, function(err, result) {
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
            connection.query('select * from tarif where id = ' + id , (err, result) => {
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
            connection.query('update tarif set ? where id =' + id, Data, (err, result) => {
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
            connection.query('delete from tarif where id =' + id , (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

}

module.exports = Model_Tarif;