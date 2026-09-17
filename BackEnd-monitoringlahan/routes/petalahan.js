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
    if(Data && Data.length > 0) {
      res.render('admin/petalahan/index', {
        currentRoute: '/petalahan',
        email: Data[0].email,
        userRole: Data[0].role,
        data: rows
      });
    }else{
      res.redirect('/login');
    }
  } catch (error) {
    res.status(501).json({error: 'cant access'});
    
  }
  
});

module.exports = router;
