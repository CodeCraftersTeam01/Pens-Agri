const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const connection = require('./db');

/**
 * Helper to execute a multi-statement SQL string via Promise
 */
function executeSqlFile(filePath, description) {
  return new Promise((resolve, reject) => {
    if (!fs.existsSync(filePath)) {
      console.warn(`[WARN] SQL file not found: ${filePath}`);
      return resolve(false);
    }

    console.log(`[INIT] Reading and executing ${description} (${path.basename(filePath)})...`);
    const sqlContent = fs.readFileSync(filePath, 'utf8');

    connection.query(sqlContent, (err, results) => {
      if (err) {
        console.error(`[ERROR] Failed to execute ${description}:`, err.message);
        return reject(err);
      }
      console.log(`[SUCCESS] ${description} executed successfully.`);
      resolve(results);
    });
  });
}

/**
 * Check if a table exists in the current database
 */
function checkTableExists(tableName) {
  return new Promise((resolve, reject) => {
    connection.query(
      "SELECT COUNT(*) AS count FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?",
      [tableName],
      (err, rows) => {
        if (err) return reject(err);
        resolve(rows && rows[0] && rows[0].count > 0);
      }
    );
  });
}

/**
 * Main Database Initialization & Migration Procedure
 */
async function initSumenepDatabase() {
  try {
    console.log('========================================================');
    console.log('🚀 PENS AGRI - DATABASE INITIALIZATION & MIGRATION');
    console.log('========================================================');

    // 1. Check if base agriculture tables (monitoring_lahan / kelompok_tani) exist
    const hasBaseTables = await checkTableExists('monitoring_lahan');

    if (!hasBaseTables) {
      console.log('[INFO] Base tables not found. Importing base database schema...');
      const baseSqlNew = path.join(__dirname, 'db_pertanian_new.sql');
      const baseSqlOriginal = path.join(__dirname, 'db_pertanian.sql');

      if (fs.existsSync(baseSqlNew)) {
        await executeSqlFile(baseSqlNew, 'Base Agricultural Database (db_pertanian_new.sql)');
      } else if (fs.existsSync(baseSqlOriginal)) {
        await executeSqlFile(baseSqlOriginal, 'Base Agricultural Database (db_pertanian.sql)');
      }
    } else {
      console.log('[INFO] Base agriculture tables already exist. Skipping base import.');
    }

    // 2. Execute Phase 1 Sumenep Migration (master_wilayah_sumenep, enhanced users, standar_komoditas_petani, forum_posts, forum_comments)
    const migrationPhase1 = path.join(__dirname, 'migrations_phase1_sumenep.sql');
    await executeSqlFile(migrationPhase1, 'Phase 1 Sumenep Migration & Master Seed (migrations_phase1_sumenep.sql)');

    // 3. Verify Tables and Seed Count
    return new Promise((resolve, reject) => {
      connection.query('SHOW TABLES;', (err, tableRows) => {
        if (err) return reject(err);

        const tables = tableRows.map(r => Object.values(r)[0]);
        console.log('\n📊 Current Tables in Database (`' + (process.env.DB_NAME || 'db_pertanian') + '`):');
        tables.forEach((t, idx) => console.log(`   ${idx + 1}. ${t}`));

        connection.query('SELECT COUNT(*) AS total_desa FROM master_wilayah_sumenep;', (err, countRows) => {
          if (!err && countRows && countRows[0]) {
            console.log(`\n📍 Master Wilayah Sumenep Seeded: ${countRows[0].total_desa} desa/kelurahan.`);
          }
          console.log('========================================================\n');
          resolve(tables);
        });
      });
    });

  } catch (error) {
    console.error('[FATAL] Database initialization failed:', error);
    throw error;
  }
}

// If executed directly from CLI (e.g. `node config/db_init_sumenep.js`)
if (require.main === module) {
  initSumenepDatabase()
    .then(() => {
      console.log('✅ Database initialization completed successfully.');
      process.exit(0);
    })
    .catch((err) => {
      console.error('❌ Database initialization failed:', err);
      process.exit(1);
    });
}

module.exports = { initSumenepDatabase };
