DELIMITER $$
CREATE PROCEDURE `mc_send_email`(IN `to` varchar(255), IN `subject` varchar(255), IN `message` mediumtext) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN
  INSERT INTO `4_emails_pending` (`to`, `subject`, `message`,`date`,`touch`) VALUES (`to`, `subject`, `message`, NOW(), 0);
END $$
DELIMITER ;
