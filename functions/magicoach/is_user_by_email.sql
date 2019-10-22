DELIMITER $$
CREATE FUNCTION `is_user_by_email`(email varchar(255)) RETURNS tinyint(1) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
	SET @result = (SELECT COUNT(*) FROM `3_users` u WHERE u.email = email);
	RETURN IF(@result = 1, true, false);
END $$
DELIMITER ;
