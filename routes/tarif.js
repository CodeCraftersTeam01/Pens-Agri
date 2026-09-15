var express = require('express');
const Model_Users = require('../model/Model_Users');
const Model_Tarif = require('../model/Model_Tarif');
var router = express.Router();

/* GET users listing. */
router.get('/', async function(req, res, next) {
  try {
    let id = req.session.userId;
    let Data = await Model_Users.getId(id);
    let rows = await Model_Tarif.getAll();
    if(Data.length > 0 ) {
      if(Data[0].role != 2){
        res.redirect('/logout')
      }else{
        // res.send('User biasa');
        res.render('parkir/tarif/index', {
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

router.post('/save', async (req, res) => {
  let {harga, waktu, jenis} = req.body;
  let Data = {
    harga,
    waktu,
    jenis: jenis,
  };
  
  await Model_Tarif.Store(Data);

  req.flash('success','Berhasil menyiman data tarif');
  res.redirect('/tarif');
})


router.post('/update/(:id)', async function(req, res, next){
  let id = req.params.id;
  let {harga, waktu, jenis} = req.body;
  let Data = {
    harga,
    waktu,
    jenis: jenis,
  };
  await Model_Tarif.Update(id, Data);
  req.flash('success','Update Tarif Berhasil');
  res.redirect('/tarif');
})

router.get('/delete/(:id)', async function(req, res, next){
  let id = req.params.id;
  await Model_Tarif.Delete(id);
  req.flash('success','Hapus Tarif Berhasil');
  res.redirect('/tarif');
})


module.exports = router;
