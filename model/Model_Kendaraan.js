const connection = require('../config/db');

class Model_Kendaraan {

    static async getAll(){
        return new Promise((resolve, reject) => {
            connection.query('select * from kendaraan a join pengunjung b on b.id_kendaraan=a.id  order by a.id desc', (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }
    
    static async getParkirIn(){
        return new Promise((resolve, reject) => {
            connection.query("select * from kendaraan a join pengunjung b on b.id_kendaraan=a.id where a.status = 'In' order by a.id desc", (err, rows) => {
                if(err){
                    reject(err);
                }else{
                    resolve(rows);
                }
            });
        });
    }
    static async getParkirOut(){
        return new Promise((resolve, reject) => {
            connection.query("select * from kendaraan where status = 'Out' order by id desc", (err, rows) => {
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
            connection.query('insert into kendaraan set ?', Data, function(err, result) {
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
            connection.query('select * from kendaraan where id = ' + id , (err, result) => {
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
            connection.query('update kendaraan set ? where id =' + id, Data, (err, result) => {
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
            connection.query('delete from kendaraan where id =' + id , (err, result) => {
                if(err){
                    reject(err);
                }else{
                    resolve(result);
                }
            });
        });
    }

}

module.exports = Model_Kendaraan;