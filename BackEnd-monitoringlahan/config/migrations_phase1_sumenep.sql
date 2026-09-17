-- =========================================================================================
-- DATABASE MIGRATION SCRIPT - PHASE 1: SUMENEP LOCALIZATION & PRECISION AGRICULTURE ECOSYSTEM
-- Database: DB_MonitoringLahan / PENS Agri
-- Target Engine: MySQL / MariaDB (InnoDB, utf8mb4_general_ci)
-- =========================================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------------------
-- 1. Table: master_wilayah_sumenep
-- Master list of 27 Kecamatan and their corresponding Desa/Kelurahan in Kabupaten Sumenep
-- -----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `master_wilayah_sumenep` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `kecamatan` VARCHAR(100) NOT NULL,
  `desa` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_kec_desa` (`kecamatan`, `desa`),
  KEY `idx_kecamatan` (`kecamatan`),
  KEY `idx_desa` (`desa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------------------------------------------
-- 2. Table: users
-- Supports role-based access ('petani', 'penyuluh', 'admin'), credentials, and village pairing
-- -----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(255) DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `no_hp` VARCHAR(50) DEFAULT NULL,
  `role` ENUM('petani','penyuluh','admin') NOT NULL DEFAULT 'petani',
  `desa_id` INT(11) DEFAULT NULL,
  `foto_users` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_desa_id` (`desa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------------------------------------------
-- 3. Table: standar_komoditas_petani
-- Farmer-submitted custom threshold standards requiring Penyuluh verification
-- -----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `standar_komoditas_petani` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `petani_id` INT(11) NOT NULL,
  `penyuluh_id` INT(11) DEFAULT NULL,
  `desa_id` INT(11) NOT NULL,
  `komoditas` VARCHAR(255) NOT NULL,
  `varietas` VARCHAR(255) NOT NULL,
  `min_ph` DECIMAL(4,2) NOT NULL DEFAULT 6.00,
  `max_ph` DECIMAL(4,2) NOT NULL DEFAULT 7.00,
  `min_moisture` DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  `max_moisture` DECIMAL(5,2) NOT NULL DEFAULT 80.00,
  `min_n` INT(11) NOT NULL DEFAULT 100,
  `max_n` INT(11) NOT NULL DEFAULT 150,
  `min_p` INT(11) NOT NULL DEFAULT 25,
  `max_p` INT(11) NOT NULL DEFAULT 45,
  `min_k` INT(11) NOT NULL DEFAULT 150,
  `max_k` INT(11) NOT NULL DEFAULT 220,
  `min_temp` DECIMAL(4,2) NOT NULL DEFAULT 20.00,
  `max_temp` DECIMAL(4,2) NOT NULL DEFAULT 35.00,
  `min_ec` INT(11) NOT NULL DEFAULT 1000,
  `max_ec` INT(11) NOT NULL DEFAULT 2000,
  `min_fertility` INT(11) NOT NULL DEFAULT 50,
  `max_fertility` INT(11) NOT NULL DEFAULT 100,
  `status` ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  `catatan_penyuluh` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_petani_id` (`petani_id`),
  KEY `idx_penyuluh_id` (`penyuluh_id`),
  KEY `idx_desa_id` (`desa_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------------------------------------------
-- 4. Table: forum_posts
-- Inter-farmer community discussions with optional custom baseline attachments
-- -----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `forum_posts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `standar_id` INT(11) DEFAULT NULL,
  `title` VARCHAR(255) NOT NULL,
  `body` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_standar_id` (`standar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------------------------------------------
-- 5. Table: forum_comments
-- Comment thread on community forum posts
-- -----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `forum_comments` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `post_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `comment` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- -----------------------------------------------------------------------------------------
-- SEED DATA: Master Wilayah Kabupaten Sumenep (27 Kecamatan)
-- -----------------------------------------------------------------------------------------
INSERT IGNORE INTO `master_wilayah_sumenep` (`kecamatan`, `desa`) VALUES
-- 1. Kota Sumenep
('Kota Sumenep', 'Bangselok'), ('Kota Sumenep', 'Pajagalan'), ('Kota Sumenep', 'Kepanjin'),
('Kota Sumenep', 'Karangduak'), ('Kota Sumenep', 'Kolor'), ('Kota Sumenep', 'Pabian'),
('Kota Sumenep', 'Marengan Daya'), ('Kota Sumenep', 'Parsanga'), ('Kota Sumenep', 'Pangarangan'),
('Kota Sumenep', 'Pamolokan'), ('Kota Sumenep', 'Kebunan'), ('Kota Sumenep', 'Pandian'),
('Kota Sumenep', 'Paberasan'), ('Kota Sumenep', 'Kacongan'), ('Kota Sumenep', 'Torbang'),

-- 2. Kalianget
('Kalianget', 'Kalianget Timur'), ('Kalianget', 'Kalianget Barat'), ('Kalianget', 'Kalimo\'ok'),
('Kalianget', 'Kertasada'), ('Kalianget', 'Karanganyar'), ('Kalianget', 'Pinggirpapas'), ('Kalianget', 'Mares'),

-- 3. Talango (Kepulauan)
('Talango', 'Talango'), ('Talango', 'Gapurana'), ('Talango', 'Padike'), ('Talango', 'Cabbiya'),
('Talango', 'Kombang'), ('Talango', 'Palasa'), ('Talango', 'Essang'), ('Talango', 'Gowa-Gowa'),

-- 4. Saronggi
('Saronggi', 'Saronggi'), ('Saronggi', 'Tanah Merah'), ('Saronggi', 'Juluk'), ('Saronggi', 'Nambakor'),
('Saronggi', 'Langsar'), ('Saronggi', 'Kebundadap Timur'), ('Saronggi', 'Kebundadap Barat'),
('Saronggi', 'Pagarbatu'), ('Saronggi', 'Tanjung'), ('Saronggi', 'Moangan'),

-- 5. Bluto
('Bluto', 'Bluto'), ('Bluto', 'Aengbaja Raja'), ('Bluto', 'Aengbaja Kenek'), ('Bluto', 'Pakandangan Barat'),
('Bluto', 'Pakandangan Tengah'), ('Bluto', 'Pakandangan Sangra'), ('Bluto', 'Sera Barat'),
('Bluto', 'Sera Timur'), ('Bluto', 'Karang Cempaka'), ('Bluto', 'Lobuk'), ('Bluto', 'Gulukmanjung'),

-- 6. Lenteng
('Lenteng', 'Lenteng Timur'), ('Lenteng', 'Lenteng Barat'), ('Lenteng', 'Ellak Laok'),
('Lenteng', 'Ellak Daya'), ('Lenteng', 'Taraban'), ('Lenteng', 'Banaresep Timur'),
('Lenteng', 'Banaresep Barat'), ('Lenteng', 'Poreh'), ('Lenteng', 'Cangkreng'),
('Lenteng', 'Meddelan'), ('Lenteng', 'Sendir'),

-- 7. Gapura
('Gapura', 'Gapura Barat'), ('Gapura', 'Gapura Timur'), ('Gapura', 'Gapura Tengah'),
('Gapura', 'Andulang'), ('Gapura', 'Balo'), ('Gapura', 'Banjar Barat'), ('Gapura', 'Banjar Timur'),
('Gapura', 'Batudinding'), ('Gapura', 'Beraji'), ('Gapura', 'Braji'), ('Gapura', 'Karangbudi'),
('Gapura', 'Longos'), ('Gapura', 'Mandala'), ('Gapura', 'Paloloan'), ('Gapura', 'Panagan'), ('Gapura', 'Poja'),

-- 8. Batang-Batang
('Batang-Batang', 'Batang-Batang Laok'), ('Batang-Batang', 'Batang-Batang Daya'),
('Batang-Batang', 'Banuaju Barat'), ('Batang-Batang', 'Banuaju Timur'), ('Batang-Batang', 'Bilangan'),
('Batang-Batang', 'Dapenda'), ('Batang-Batang', 'Jangkong'), ('Batang-Batang', 'Jenang'),
('Batang-Batang', 'Kolpo'), ('Batang-Batang', 'Legung Barat'), ('Batang-Batang', 'Legung Timur'),
('Batang-Batang', 'Lombang'), ('Batang-Batang', 'Nyabakan Barat'), ('Batang-Batang', 'Nyabakan Timur'),
('Batang-Batang', 'Tamedung'),

-- 9. Dungkek
('Dungkek', 'Dungkek'), ('Dungkek', 'Bicabi'), ('Dungkek', 'Bungin-Bungin'), ('Dungkek', 'Candi'),
('Dungkek', 'Ginih'), ('Dungkek', 'Jadung'), ('Dungkek', 'Lapa Daya'), ('Dungkek', 'Lapa Laok'),
('Dungkek', 'Lapa Taman'), ('Dungkek', 'Romben Barat'), ('Dungkek', 'Romben Guna'),
('Dungkek', 'Romben Rana'), ('Dungkek', 'Taman Sare'),

-- 10. Rubaru
('Rubaru', 'Rubaru'), ('Rubaru', 'Banasare'), ('Rubaru', 'Basoka'), ('Rubaru', 'Bunbarat'),
('Rubaru', 'Duko'), ('Rubaru', 'Kalebengan'), ('Rubaru', 'Karangnangka'), ('Rubaru', 'Mandala'),
('Rubaru', 'Matanair'), ('Rubaru', 'Pakondang'), ('Rubaru', 'Tambaksari'),

-- 11. Ambunten
('Ambunten', 'Ambunten Timur'), ('Ambunten', 'Ambunten Barat'), ('Ambunten', 'Ambunten Tengah'),
('Ambunten', 'Belluk Ares'), ('Ambunten', 'Belluk Raja'), ('Ambunten', 'Campor Barat'),
('Ambunten', 'Campor Timur'), ('Ambunten', 'Tambaagung Ares'), ('Ambunten', 'Tambaagung Barat'),
('Ambunten', 'Tambaagung Timur'), ('Ambunten', 'Tambaagung Tengah'), ('Ambunten', 'Keles'), ('Ambunten', 'Sogian'),

-- 12. Pasongsongan
('Pasongsongan', 'Pasongsongan'), ('Pasongsongan', 'Panaongan'), ('Pasongsongan', 'Padangdangan'),
('Pasongsongan', 'Montorna'), ('Pasongsongan', 'Campaka'), ('Pasongsongan', 'Rajun'),
('Pasongsongan', 'Soddara'), ('Pasongsongan', 'Lebeng Barat'), ('Pasongsongan', 'Lebeng Timur'),

-- 13. Guluk-Guluk
('Guluk-Guluk', 'Guluk-Guluk'), ('Guluk-Guluk', 'Payudan Dundang'), ('Guluk-Guluk', 'Payudan Karangsokon'),
('Guluk-Guluk', 'Payudan Nangger'), ('Guluk-Guluk', 'Bragung'), ('Guluk-Guluk', 'Batuampar'),
('Guluk-Guluk', 'Pordapor'), ('Guluk-Guluk', 'Bakeong'), ('Guluk-Guluk', 'Pananggungan'),

-- 14. Ganding
('Ganding', 'Ganding'), ('Ganding', 'Ketawang Larangan'), ('Ganding', 'Ketawang Karay'),
('Ganding', 'Ketawang Parebaan'), ('Ganding', 'Rombiya Barat'), ('Ganding', 'Rombiya Timur'),
('Ganding', 'Bataal Barat'), ('Ganding', 'Bataal Timur'), ('Ganding', 'Talaga'),

-- 15. Pragaan
('Pragaan', 'Pragaan Laok'), ('Pragaan', 'Pragaan Daya'), ('Pragaan', 'Karduluk'),
('Pragaan', 'Pakamban Laok'), ('Pragaan', 'Pakamban Daya'), ('Pragaan', 'Sendang'),
('Pragaan', 'Jaddung'), ('Pragaan', 'Aeng Panas'), ('Pragaan', 'Larangan Perreng'), ('Pragaan', 'Kaduara Timur'),

-- 16. Manding
('Manding', 'Manding Laok'), ('Manding', 'Manding Daya'), ('Manding', 'Manding Timur'),
('Manding', 'Gadding'), ('Manding', 'Gunung Kembar'), ('Manding', 'Jaba\'an'),
('Manding', 'Kasengan'), ('Manding', 'Lanjuk'), ('Manding', 'Tenonan'),

-- 17. Dasuk
('Dasuk', 'Dasuk Laok'), ('Dasuk', 'Dasuk Barat'), ('Dasuk', 'Dasuk Timur'),
('Dasuk', 'Bringin'), ('Dasuk', 'Jelbudan'), ('Dasuk', 'Kecer'),
('Dasuk', 'Kerta Barat'), ('Dasuk', 'Kerta Timur'), ('Dasuk', 'Nyapar'),
('Dasuk', 'Semaan'), ('Dasuk', 'Slopeng'),

-- 18. Batuputih
('Batuputih', 'Batuputih Laok'), ('Batuputih', 'Batuputih Daya'), ('Batuputih', 'Batuputih Kenek'),
('Batuputih', 'Badur'), ('Batuputih', 'Bantelan'), ('Batuputih', 'Bulla\'an'),
('Batuputih', 'Juruan Daya'), ('Batuputih', 'Juruan Laok'), ('Batuputih', 'Larangan Barma'),
('Batuputih', 'Larangan Kerta'), ('Batuputih', 'Sergang'), ('Batuputih', 'Tengedan'),

-- 19. Batuan
('Batuan', 'Batuan'), ('Batuan', 'Babbalan'), ('Batuan', 'Gedungan'),
('Batuan', 'Gelugur'), ('Batuan', 'Gunggung'), ('Batuan', 'Patean'), ('Batuan', 'Torbang'),

-- 20. Arjasa (Kepulauan Kangean)
('Arjasa (Kangean)', 'Arjasa'), ('Arjasa (Kangean)', 'Angkatan'), ('Arjasa (Kangean)', 'Bilis-Bilis'),
('Arjasa (Kangean)', 'Buddi'), ('Arjasa (Kangean)', 'Duko'), ('Arjasa (Kangean)', 'Kalikatak'),
('Arjasa (Kangean)', 'Kalinganyar'), ('Arjasa (Kangean)', 'Kalisangka'), ('Arjasa (Kangean)', 'Kolo-Kolo'),
('Arjasa (Kangean)', 'Laok Jang-Jang'), ('Arjasa (Kangean)', 'Pabian'), ('Arjasa (Kangean)', 'Pajanangger'),
('Arjasa (Kangean)', 'Pandeman'), ('Arjasa (Kangean)', 'Paseraman'), ('Arjasa (Kangean)', 'Sambakati'),
('Arjasa (Kangean)', 'Sawah Sumur'), ('Arjasa (Kangean)', 'Sumber Nangka'),

-- 21. Kangayan (Kepulauan Kangean)
('Kangayan (Kangean)', 'Kangayan'), ('Kangayan (Kangean)', 'Batuputih'), ('Kangayan (Kangean)', 'Cangkramaan'),
('Kangayan (Kangean)', 'Daandung'), ('Kangayan (Kangean)', 'Jikakenek'), ('Kangayan (Kangean)', 'Saobi'),
('Kangayan (Kangean)', 'Tamberu'), ('Kangayan (Kangean)', 'Timur Jang-Jang'), ('Kangayan (Kangean)', 'Torjek'),

-- 22. Sapeken (Kepulauan Sapeken)
('Sapeken', 'Sapeken'), ('Sapeken', 'Pagerungan Besar'), ('Sapeken', 'Pagerungan Kecil'),
('Sapeken', 'Paliat'), ('Sapeken', 'Sabuntan'), ('Sapeken', 'Sadulang'),
('Sapeken', 'Sakala'), ('Sapeken', 'Saur Saebus'), ('Sapeken', 'Sepanjang'), ('Sapeken', 'Tanjung Kiaok'),

-- 23. Nonggunong (Kepulauan Sapudi)
('Nonggunong (Sapudi)', 'Nonggunong'), ('Nonggunong (Sapudi)', 'Rosong'),
('Nonggunong (Sapudi)', 'Sokarame Pesisir'), ('Nonggunong (Sapudi)', 'Sokarame Timur'),
('Nonggunong (Sapudi)', 'Sonok'), ('Nonggunong (Sapudi)', 'Talaga'),
('Nonggunong (Sapudi)', 'Tarebung'), ('Nonggunong (Sapudi)', 'Tanah Merah'),

-- 24. Gayam (Kepulauan Sapudi)
('Gayam (Sapudi)', 'Gayam'), ('Gayam (Sapudi)', 'Gendang Barat'), ('Gayam (Sapudi)', 'Gendang Timur'),
('Gayam (Sapudi)', 'Jambuir'), ('Gayam (Sapudi)', 'Kalowang'), ('Gayam (Sapudi)', 'Karang Tengah'),
('Gayam (Sapudi)', 'Karyaki'), ('Gayam (Sapudi)', 'Nyamplong'), ('Gayam (Sapudi)', 'Pancor'),
('Gayam (Sapudi)', 'Prambanan'), ('Gayam (Sapudi)', 'Tarebung'),

-- 25. Raas (Kepulauan Raas)
('Raas', 'Alasmalang'), ('Raas', 'Berakit'), ('Raas', 'Brakas'),
('Raas', 'Guwa-Guwa'), ('Raas', 'Jungkat'), ('Raas', 'Karangnangka'),
('Raas', 'Ketupat'), ('Raas', 'Kropoh'), ('Raas', 'Poteran'), ('Raas', 'Tonduk'),

-- 26. Masalembu (Kepulauan Masalembu)
('Masalembu', 'Sukajeruk'), ('Masalembu', 'Masalima'), ('Masalembu', 'Masakambing'), ('Masalembu', 'Karamian'),

-- 27. Giligenting (Kepulauan Giligenting)
('Giligenting', 'Aeng Anyar'), ('Giligenting', 'Banbaru'), ('Giligenting', 'Banmaleng'),
('Giligenting', 'Bringsang'), ('Giligenting', 'Galis'), ('Giligenting', 'Gedugan'),
('Giligenting', 'Jombag'), ('Giligenting', 'Lombang');

SET FOREIGN_KEY_CHECKS = 1;
