-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 25, 2026 at 02:55 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_pertanian`
--

-- --------------------------------------------------------

--
-- Table structure for table `kendaraan`
--

CREATE TABLE `kendaraan` (
  `id` int(11) NOT NULL,
  `nopol` varchar(255) DEFAULT NULL,
  `type` enum('Motor','Mobil') DEFAULT NULL,
  `warna` varchar(255) DEFAULT NULL,
  `tanggal_masuk` date DEFAULT NULL,
  `jam_masuk` time DEFAULT NULL,
  `tanggal_keluar` date DEFAULT NULL,
  `jam_keluar` time DEFAULT NULL,
  `status` enum('In','Out') DEFAULT NULL,
  `id_tarif` int(11) DEFAULT NULL,
  `id_users` int(11) DEFAULT NULL,
  `total_biaya` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kendaraan`
--

INSERT INTO `kendaraan` (`id`, `nopol`, `type`, `warna`, `tanggal_masuk`, `jam_masuk`, `tanggal_keluar`, `jam_keluar`, `status`, `id_tarif`, `id_users`, `total_biaya`) VALUES
(16, 'M 7644 KG', 'Mobil', 'Hitam', '2025-09-25', '09:32:23', '2025-09-25', '20:26:13', 'Out', NULL, 1, 10000),
(17, 'M 7644 KG', 'Motor', 'Hitam', '2025-09-25', '09:04:53', '2025-09-25', '20:33:05', 'Out', NULL, 1, 7500);

-- --------------------------------------------------------

--
-- Table structure for table `monitoring_lahan`
--

CREATE TABLE `monitoring_lahan` (
  `id` bigint(20) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `irigasi` varchar(255) DEFAULT NULL,
  `listrik` varchar(255) DEFAULT NULL,
  `pompa_air` varchar(255) DEFAULT NULL,
  `sumber_air` varchar(255) DEFAULT NULL,
  `kondisi_air` varchar(255) DEFAULT NULL,
  `sumber_energi_pompa` varchar(255) DEFAULT NULL,
  `pembajak` varchar(255) DEFAULT NULL,
  `tadahan_hujan` varchar(255) DEFAULT NULL,
  `komoditas` varchar(255) DEFAULT NULL,
  `luas_lahan` varchar(255) DEFAULT NULL,
  `status_lahan` varchar(255) DEFAULT NULL,
  `kelompok_tani` varchar(255) DEFAULT NULL,
  `gagal_panen` varchar(255) DEFAULT NULL,
  `temp` float DEFAULT NULL,
  `moisture` float DEFAULT NULL,
  `conductivity` float DEFAULT NULL,
  `ph` float DEFAULT NULL,
  `nitrogen` float DEFAULT NULL,
  `phosphorus` float DEFAULT NULL,
  `potassium` float DEFAULT NULL,
  `fertility` float DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `monitoring_lahan`
--

INSERT INTO `monitoring_lahan` (`id`, `latitude`, `longitude`, `irigasi`, `listrik`, `pompa_air`, `sumber_air`, `kondisi_air`, `sumber_energi_pompa`, `pembajak`, `tadahan_hujan`, `komoditas`, `luas_lahan`, `status_lahan`, `kelompok_tani`, `gagal_panen`, `temp`, `moisture`, `conductivity`, `ph`, `nitrogen`, `phosphorus`, `potassium`, `fertility`, `created_at`) VALUES
(2, -7.01234500, 113.85432100, 'ya', 'tidak', 'ya', 'Sumur Bor', 'Tersedia', 'BBM', 'Traktor', 'tidak', 'Jagung', '0.5 Hektar', 'Milik Sendiri', 'ya', 'tidak', 28.5, 65.2, 120, 6.5, 45, 30.2, 15.5, 85, '2026-05-25 12:53:15'),
(3, -7.01234500, 113.85432100, 'ya', 'tidak', 'ya', 'Sumur Bor', 'Tersedia', 'BBM', 'Traktor', 'tidak', 'Jagung', '0.5 Hektar', 'Milik Sendiri', 'ya', 'tidak', 28.5, 65.2, 120, 6.5, 45, 30.2, 15.5, 85, '2026-05-25 12:54:23');

-- --------------------------------------------------------

--
-- Table structure for table `pengunjung`
--

CREATE TABLE `pengunjung` (
  `id` int(11) NOT NULL,
  `wajah` varchar(255) DEFAULT NULL,
  `pakaian` varchar(255) DEFAULT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `id_kendaraan` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengunjung`
--

INSERT INTO `pengunjung` (`id`, `wajah`, `pakaian`, `jenis_kelamin`, `id_kendaraan`) VALUES
(1, NULL, NULL, 'Laki-laki', 6),
(2, NULL, NULL, 'Laki-laki', 7),
(3, 'function now() { [native code] }.PNG', 'function now() { [native code] }.PNG', 'Laki-laki', 8),
(4, NULL, NULL, 'Laki-laki', 9),
(5, NULL, NULL, 'Laki-laki', 10),
(6, NULL, NULL, 'Laki-laki', 12),
(7, 'function now() { [native code] }.png', 'function now() { [native code] }.png', 'Laki-laki', 13),
(8, '1757597509820.png', '1757597509891.png', 'Laki-laki', 14),
(9, '1757641652963.png', '1757641653121.png', 'Laki-laki', 15),
(10, '1758771142980.png', '1758771143038.png', 'Laki-laki', 16),
(11, NULL, NULL, 'Laki-laki', 17),
(12, NULL, NULL, 'Laki-laki', 0),
(13, '1758806773825.png', '1758806773881.png', 'Laki-laki', 0),
(14, NULL, NULL, 'Laki-laki', 0);

-- --------------------------------------------------------

--
-- Table structure for table `tarif`
--

CREATE TABLE `tarif` (
  `id` int(11) NOT NULL,
  `harga` varchar(255) DEFAULT NULL,
  `waktu` varchar(255) DEFAULT NULL,
  `jenis` enum('Motor','Mobil') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tarif`
--

INSERT INTO `tarif` (`id`, `harga`, `waktu`, `jenis`) VALUES
(2, '2000', '1', 'Motor'),
(3, '5000', '1', 'Mobil');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('1','2') DEFAULT NULL,
  `foto_users` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `role`, `foto_users`) VALUES
(1, 'jack@gmail.com', '$2b$10$8waE28bL8svTq/.zsQFwreoRyI4sUzb9h3QlEXWusC4HEXVU7/79i', '2', NULL),
(2, 'p@gmail.com', '$2b$10$sjL4Xgfi3rf4jGkq2mtWPuYNrzId9eueML9wQ3Y7K/de3Jwfh0phq', '2', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `kendaraan`
--
ALTER TABLE `kendaraan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `monitoring_lahan`
--
ALTER TABLE `monitoring_lahan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pengunjung`
--
ALTER TABLE `pengunjung`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tarif`
--
ALTER TABLE `tarif`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `kendaraan`
--
ALTER TABLE `kendaraan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `monitoring_lahan`
--
ALTER TABLE `monitoring_lahan`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pengunjung`
--
ALTER TABLE `pengunjung`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `tarif`
--
ALTER TABLE `tarif`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
