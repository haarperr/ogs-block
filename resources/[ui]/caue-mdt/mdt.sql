CREATE TABLE IF NOT EXISTS `mdt_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `image` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `gallery` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mdt_bulletins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `title` text NOT NULL,
  `description` text NOT NULL,
  `job` varchar(255) NOT NULL DEFAULT 'police',
  `time` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mdt_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `message` varchar(255) DEFAULT NULL,
  `job` varchar(255) NOT NULL DEFAULT 'police',
  `time` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mdt_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text NOT NULL,
  `time` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mdt_incidents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `title` text NOT NULL,
  `details` text NOT NULL,
  `tags` text NOT NULL,
  `officers` text NOT NULL,
  `civilians` text NOT NULL,
  `evidence` text NOT NULL,
  `associated` text NOT NULL,
  `job` varchar(255) NOT NULL DEFAULT 'police',
  `time` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `title` text DEFAULT NULL,
  `type` text DEFAULT NULL,
  `detail` text DEFAULT NULL,
  `tags` text NOT NULL,
  `gallery` text NOT NULL,
  `officers` text NOT NULL,
  `civsinvolved` text NOT NULL,
  `job` varchar(255) NOT NULL DEFAULT 'police',
  `time` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mdt_bolos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `title` text DEFAULT NULL,
  `plate` text DEFAULT NULL,
  `owner` text DEFAULT NULL,
  `individual` text DEFAULT NULL,
  `detail` text DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `gallery` text DEFAULT NULL,
  `officers` text DEFAULT NULL,
  `job` varchar(255) NOT NULL DEFAULT 'police',
  `time` bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `mdt_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plate` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `image` text DEFAULT NULL,
  `code5` tinyint(1) DEFAULT '0',
  `stolen` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

























CREATE TABLE `mdt_penalcode` (
  `id` int NOT NULL,
  `type` int NOT NULL,
  `category` int NOT NULL DEFAULT '1',
  `label` varchar(255) DEFAULT NULL,
  `sentence` int NOT NULL DEFAULT '0',
  `fine` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

CREATE TABLE `mdt_penalcode_types` (
  `tid` int NOT NULL,
  `type` int NOT NULL,
  PRIMARY KEY (`tid`),
  UNIQUE KEY `tid` (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci



INSERT INTO `mdt_penalcode` (`type`, `category`, `label`, `sentence`, `fine`) VALUES
	(1, 1, 'Assault & Battery', 11, 825),
	(1, 1, 'Unlawful Imprisonment', 11, 825),
	(1, 2, 'Kidnapping', 14, 1050),
	(1, 2, 'Kidnapping a Gov Employee', 25, 1875),
	(1, 2, 'Assault with a Deadly Weapon', 21, 1575),
	(1, 2, 'Manslaughter', 150, 11250),
	(1, 2, 'Attempted 2nd Degree Murder', 25, 1875),
	(1, 2, '2nd Degree Murder', 300, 22500),
	(1, 2, 'Attempted 1st Degree Murder', 35, 2625),
	(1, 2, '1st Degree Murder', 600, 50000),
	(1, 1, 'Criminal Threats', 14, 1050),
	(1, 2, 'Attempted Murder of a Government Employee', 45, 3375),
	(1, 2, 'Murder of a Government Employee', 100, 10000),
	(1, 2, 'Gang Related Shooting', 75, 500),
	(1, 2, 'Reckless Endangerment ', 11, 825),
	(1, 1, 'Brandishing of a Firearm', 7, 525),
	(1, 2, 'Accessory to Attempted Murder', 35, 2625),
	(1, 2, 'Accessory to Murder', 60, 15000),
	(1, 2, 'Accessory to Attempted Murder of a Government Employee', 45, 3375),
	(1, 2, ' Accessory to Murder of a Government Employee', 75, 22350),
	(1, 2, "Forcer's Law", 150, 74550),














INSERT INTO `carshop_vehicles` VALUES
  ('dilettante', 765, 'compacts', 10, 'pdm'),
  ('club', 11111, 'compacts', 0, 'pdm'),
  ('kanjo', 11111, 'compacts', 0, 'pdm'),
  ('prairie', 11111, 'compacts', 0, 'pdm'),
  ('rhapsody', 11111, 'compacts', 0, 'pdm'),
  ('manchez', 11111, 'motorcycles', 0, 'pdm'),
  ('enduro', 11111, 'motorcycles', 0, 'pdm'),
  ('sanchez2', 11111, 'motorcycles', 0, 'pdm'),
  ('stryder', 11111, 'motorcycles', 0, 'pdm'),
  ('blade', 11111, 'muscle', 0, 'pdm'),
  ('buccaneer', 11111, 'muscle', 0, 'pdm'),
  ('buccaneer2', 11111, 'muscle', 0, 'pdm'),
  ('chino', 11111, 'muscle', 0, 'pdm'),
  ('chino2', 11111, 'muscle', 0, 'pdm'),
  ('deviant', 11111, 'muscle', 0, 'pdm'),
  ('dukes', 11111, 'muscle', 0, 'pdm'),
  ('faction', 11111, 'muscle', 0, 'pdm'),
  ('faction2', 11111, 'muscle', 0, 'pdm'),
  ('faction3', 11111, 'muscle', 0, 'pdm'),
  ('moonbeam', 11111, 'muscle', 0, 'pdm'),
  ('moonbeam2', 11111, 'muscle', 0, 'pdm'),
  ('phoenix', 11111, 'muscle', 0, 'pdm'),
  ('picador', 11111, 'muscle', 0, 'pdm'),
  ('ruiner', 11111, 'muscle', 0, 'pdm'),
  ('', 11111, 'aaaaa', 0, 'pdm'),
  ('', 11111, 'aaaaa', 0, 'pdm'),
  ('', 11111, 'aaaaa', 0, 'pdm'),
  ('', 11111, 'aaaaa', 0, 'pdm'),





