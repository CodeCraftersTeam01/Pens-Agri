var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_Monitoring_Lahan = require('../model/Model_Monitoring_Lahan');
var router = express.Router();

/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    let rows = await Model_Monitoring_Lahan.getAll();
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        res.redirect('/logout')
      }else{
        // res.send('User biasa');
        res.render('admin/sensor/index', {
          currentRoute: '/sensor',
          email: Data[0].email,
          data: rows
        });
      }
    }else{
      res.status(401).json({error: 'user not found'});
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
    
  }
  
});


router.get('/delete/(:id)', async function(req, res, next){
  let id = req.params.id;
  await Model_Monitoring_Lahan.Delete(id);
  req.flash('error', 'Berhasil Menghapus Data');
  return res.redirect('/sensor');
})

module.exports = router;
