const connection = require('../config/db');

class Model_Pengunjung {

    static async getAll(){
        return new Promise((resolve, reject) => {
            connection.query('select * from pengunjung order by id desc', (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }

    static async Store(DataPengunjung){
        return new Promise((resolve, reject) => {
            connection.query('insert into pengunjung set ?', DataPengunjung, function(err, result) {
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
            connection.query('select * from pengunjung where id = ' + id , (err, result) => {
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
            connection.query('update pengunjung set ? where id =' + id, Data, (err, result) => {
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
            connection.query('delete from pengunjung where id =' + id , (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

}

module.exports = Model_Pengunjung;