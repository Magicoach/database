DELIMITER $$
CREATE FUNCTION `email_message_new_user`(`email` varchar(255)) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
	RETURN CONCAT('Email: ',`email`);
END $$
DELIMITER ;
