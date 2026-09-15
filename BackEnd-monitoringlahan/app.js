var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var flash = require('express-flash');
var session = require('express-session');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var superusersRouter = require('./routes/superusers');
var parkirRouter = require('./routes/parkir');
var tarifRouter = require('./routes/tarif');

var monitoring_lahanRouter = require('./routes/api/monitoring_lahan');
var sensorRouter = require('./routes/sensor');
var kelompoktaniRouter = require('./routes/kelompoktani');
var petalahanRouter = require('./routes/petalahan');
var sayur_buahRouter = require('./routes/master_data/sayur_buah');
var biofarmakaRouter = require('./routes/master_data/biofarmaka');
var luastanamperkebunanrakyatRouter = require('./routes/master_data/luas_tanam_perkebunan_rakyat');
var policybriefRouter = require('./routes/policy_brief');

var app = express();


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use(session({
  cookie: {
    maxAge: 6000000000
  },
  store: new session.MemoryStore,
  saveUninitialized: true,
  resave: 'true',
  secret: 'secret'
}))

app.use(flash());

app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/superusers', superusersRouter);
app.use('/parkir', parkirRouter);
app.use('/tarif', tarifRouter);

app.use('/api/soil', monitoring_lahanRouter);
app.use('/sensor', sensorRouter);
app.use('/kelompoktani', kelompoktaniRouter);
app.use('/petalahan', petalahanRouter);
app.use('/sayur_buah', sayur_buahRouter);
app.use('/biofarmaka', biofarmakaRouter);
app.use('/luas_tanam_perkebunan_rakyat', luastanamperkebunanrakyatRouter);
app.use('/policy_brief', policybriefRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
