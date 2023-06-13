CREATE TABLE `adminmenu_records` (
  `idban` int(11) NOT NULL,
  `user` varchar(255) NOT NULL,
  `staff` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `type` int(11) NOT NULL,
  `ended_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `adminmenu_records`
  ADD PRIMARY KEY (`idban`);

ALTER TABLE `adminmenu_records`
  MODIFY `idban` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;