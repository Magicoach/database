DELIMITER $$
CREATE FUNCTION `get_user_by_email`(email varchar(255)) RETURNS int(11) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT
      u.ID
    FROM `3_users` u
    WHERE u.email = email LIMIT 1);
  RETURN @result;
END $$
DELIMITER ;
