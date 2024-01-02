

CREATE TABLE IF NOT EXISTS `job_application_requests` (
  `id` varchar(50) NOT NULL,
  `charidentifier` int(11) NOT NULL DEFAULT 0,
  `identifier` varchar(50) DEFAULT NULL,
  `username` varchar(50) CHARACTER SET utf16 COLLATE utf16_unicode_ci DEFAULT NULL,
  `job` varchar(50) DEFAULT NULL,
  `description` longtext CHARACTER SET utf16 COLLATE utf16_unicode_ci NOT NULL,
  `date` varchar(50) DEFAULT 'N/A',
  `approved` int(11) DEFAULT 0,
  `received` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;