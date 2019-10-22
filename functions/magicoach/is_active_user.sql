DELIMITER $$
CREATE FUNCTION `is_active_user`(id_user int) RETURNS tinyint(1) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT
      COUNT(*)
    FROM `3_users` u
    WHERE u.ID = id_user
    AND u.active = 1);
  RETURN IF(@result = 1, TRUE, FALSE);
END $$
DELIMITER ;
