var express = require('express');
const Model_Users = require('../../model/Model_Users');
var router = express.Router();

/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        res.redirect('/logout')
      }else{
        // res.send('User biasa');
        res.render('admin/master_data/statistik_pertanian/sayur_buah_semusim', {
          currentRoute: '/sayur_buah',
          email: Data[0].email,
        });
      }
    }else{
      res.status(401).json({error: 'user not found'});
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
    
  }
  
});


router.get('/luas_panen', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        res.redirect('/logout')
      }else{
        // res.send('User biasa');
        res.render('admin/master_data/statistik_pertanian/luas_panen_sayur_buah_semusim', {
          currentRoute: '/luas_panen_sayur_buah',
          email: Data[0].email,
        });
      }
    }else{
      res.status(401).json({error: 'user not found'});
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
    
  }
  
});


module.exports = router;
