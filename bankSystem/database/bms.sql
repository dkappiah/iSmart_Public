
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";




--
-- Database: `bms`
--

-- --------------------------------------------------------

--
-- Table structure for table `balance`
--

CREATE TABLE `balance` (
  `AccNo` int(11) NOT NULL,
  `Balance` decimal(15,0) DEFAULT NULL,
  `Interest` decimal(15,0) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `balance`
--

INSERT INTO `balance` (`AccNo`, `Balance`, `Interest`) VALUES
(197, 35, 2),
(198, 5, 0),
(199, 45, 2),
(200, 207, 12);

-- --------------------------------------------------------

--
-- Table structure for table `credentials`
--

CREATE TABLE `credentials` (
  `AccNo` int(11) NOT NULL,
  `Pass` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `credentials`
--

INSERT INTO `credentials` (`AccNo`, `Pass`) VALUES
(197, '$2y$10$7IIfksddC.juTraxmYGTceLp.81mwMB2e2NOBB9YZy.ii9oY1Li8W'),


-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `Sender` int(11) NOT NULL,
  `Receiver` int(11) NOT NULL,
  `Amount` decimal(10,0) NOT NULL,
  `Remarks` varchar(50) NOT NULL,
  `DateTime` datetime NOT NULL DEFAULT current_timestamp(),
  `SenBalance` decimal(10,0) NOT NULL,
  `RecBalance` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`Sender`, `Receiver`, `Amount`, `Remarks`, `DateTime`, `SenBalance`, `RecBalance`) VALUES
(200, 197, 10, 'Hired as Accountant', '2024-12-19 15:46:17', 59, 79),


-- --------------------------------------------------------

--
-- Table structure for table `userinfo`
--

CREATE TABLE `userinfo` (
  `AccNo` int(11) NOT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `Address` varchar(100) DEFAULT NULL,
  `Email` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `userinfo`
--

INSERT INTO `userinfo` (`AccNo`, `Name`, `Address`, `Email`) VALUES
(197, 'Ram Bahadur', 'Syanjga', 'ram@bahadur.com'),


--
-- Indexes for dumped tables
--

--
-- Indexes for table `balance`
--
ALTER TABLE `balance`
  ADD PRIMARY KEY (`AccNo`);

--
-- Indexes for table `credentials`
--
ALTER TABLE `credentials`
  ADD PRIMARY KEY (`AccNo`);

--
-- Indexes for table `userinfo`
--
ALTER TABLE `userinfo`
  ADD PRIMARY KEY (`AccNo`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `credentials`
--
ALTER TABLE `credentials`
  MODIFY `AccNo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `balance`
--
ALTER TABLE `balance`
  ADD CONSTRAINT `balance_ibfk_1` FOREIGN KEY (`AccNo`) REFERENCES `credentials` (`AccNo`);

--
-- Constraints for table `userinfo`
--
ALTER TABLE `userinfo`
  ADD CONSTRAINT `userinfo_ibfk_1` FOREIGN KEY (`AccNo`) REFERENCES `credentials` (`AccNo`);
COMMIT;

