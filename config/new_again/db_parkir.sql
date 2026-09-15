-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 25, 2025 at 04:03 PM
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
-- Database: `db_parkir`
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
(1, 'jack@gmail.com', '$2b$10$8waE28bL8svTq/.zsQFwreoRyI4sUzb9h3QlEXWusC4HEXVU7/79i', '2', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `kendaraan`
--
ALTER TABLE `kendaraan`
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
