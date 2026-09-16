var express = require('express');
const Model_Users = require('../../model/Model_Users');
var router = express.Router();

/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    if(Data && Data.length > 0) {
      res.render('admin/master_data/statistik_pertanian/biofarmaka', {
        currentRoute: '/biofarmaka',
        email: Data[0].email,
      });
    }else{
      res.redirect('/');
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
  }
});

router.get('/luas_panen', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    if(Data && Data.length > 0) {
      res.render('admin/master_data/statistik_pertanian/luas_panen_biofarmaka', {
        currentRoute: '/luas_panen_biofarmaka',
        email: Data[0].email,
      });
    }else{
      res.redirect('/');
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
    
  }
  
});

module.exports = router;
