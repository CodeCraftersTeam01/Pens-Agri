var express = require('express');
const Model_Users = require('../model/Model_Users');
var router = express.Router();

/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    if (!id) {
      return res.redirect('/');
    }
    let Data = await Model_Users.getId(id);
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        return res.redirect('/logout');
      }else{
        return res.render('admin/index', {
          currentRoute: '/users',
          email: Data[0].email
        });
      }
    }else{
      return res.redirect('/');
    }
  } catch (error) {
    console.error(error);
    return res.redirect('/');
  }
});

module.exports = router;
