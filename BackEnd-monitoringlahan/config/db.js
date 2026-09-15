let mysql = require('mysql2');
let connection = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'db_pertanian',
    waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

connection.query('SELECT 1', (err) => {
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('Connection Success');
  }
});


module.exports = connection;