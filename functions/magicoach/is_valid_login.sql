DELIMITER $$
CREATE FUNCTION `is_valid_login`(`email` varchar(255), `password` varchar(255)) RETURNS tinyint(1) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT COUNT(*) FROM `3_users` `u`
      JOIN `3_users_password` `up` ON `up`.`ID` = u.`ID`
      WHERE `u`.`active` = 1 AND `u`.`email` = `email` AND BINARY `up`.`password` = `password`);
  RETURN IF(@result = 1, TRUE, FALSE);
END $$
DELIMITER ;
