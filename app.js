require('dotenv').config();
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var flash = require('express-flash');
var session = require('express-session');
var compression = require('compression');
var helmet = require('helmet');
var rateLimit = require('express-rate-limit');

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

// Keamanan: Sembunyikan identitas server Express dari fingerprinting hacker
app.disable('x-powered-by');

// Optimasi Performa: Kompresi Gzip/Deflate HTTP responses (mengecilkan ukuran payload hingga 80%)
app.use(compression({
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  },
  level: 6 // Balanced compression level
}));

// Keamanan: HTTP Security Headers via Helmet & Content Security Policy (CSP)
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        "'unsafe-inline'",
        "'unsafe-eval'",
        "https://cdn.jsdelivr.net",
        "https://cdnjs.cloudflare.com",
        "https://unpkg.com",
        "https://cdn.datatables.net",
        "https://code.jquery.com"
      ],
      scriptSrcAttr: [
        "'unsafe-inline'"
      ],
      styleSrc: [
        "'self'",
        "'unsafe-inline'",
        "https://cdn.jsdelivr.net",
        "https://cdnjs.cloudflare.com",
        "https://unpkg.com",
        "https://cdn.datatables.net",
        "https://fonts.googleapis.com"
      ],
      fontSrc: [
        "'self'",
        "https://cdnjs.cloudflare.com",
        "https://fonts.gstatic.com",
        "data:"
      ],
      imgSrc: [
        "'self'",
        "data:",
        "blob:",
        "https:",
        "http:"
      ],
      connectSrc: [
        "'self'",
        "https:",
        "http:",
        "ws:",
        "wss:"
      ]
    }
  },
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" },
  referrerPolicy: { policy: "strict-origin-when-cross-origin" }
}));

// Keamanan: Rate Limiter Global untuk menangkal brute-force, scraping, dan DDoS
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 menit
  max: 600, // Maksimal 600 request per 15 menit per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    status: 429,
    message: 'Terlalu banyak permintaan dari IP ini. Silakan coba kembali beberapa saat lagi.'
  }
});
app.use(globalLimiter);

// Keamanan: Auth Rate Limiter khusus untuk /login dan /register (Brute-Force & Credential Stuffing Protection)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 menit
  max: 20, // Maksimal 20 percobaan login/registrasi per 15 menit
  standardHeaders: true,
  legacyHeaders: false,
  message: 'Terlalu banyak percobaan autentikasi dari IP Anda. Demi keamanan, silakan tunggu 15 menit.'
});
app.use('/login', authLimiter);
app.use('/register', authLimiter);

// View engine setup & caching template EJS
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.set('view cache', true); // Cache EJS compiled templates untuk rendering super cepat

app.use(logger('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
app.use(cookieParser());

// Performa: Caching Static Assets (CSS, JS, Images, Icons) dengan Cache-Control 1 hari & ETag
app.use(express.static(path.join(__dirname, 'public'), {
  maxAge: '1d',
  etag: true,
  lastModified: true
}));

// Keamanan: Session Management dengan proteksi cookie (HttpOnly, SameSite, Secure maxAge)
app.use(session({
  name: 'pens_agri_sid',
  cookie: {
    httpOnly: true, // Mencegah akses cookie via JavaScript (Anti-XSS Session Hijacking)
    sameSite: 'lax', // Proteksi CSRF
    secure: process.env.NODE_ENV === 'production', // HTTPS only di production
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 hari aktif
  },
  store: new session.MemoryStore(),
  saveUninitialized: false,
  resave: false,
  rolling: true, // Otomatis memperpanjang masa aktif cookie setiap kali user membuka halaman
  secret: process.env.SESSION_SECRET || 'pens_agri_presisi_ultra_secure_key_2026'
}));

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
