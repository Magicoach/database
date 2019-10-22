DELIMITER $$
CREATE FUNCTION `email_subject_calculate_for_users`() RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN CONCAT('Magicoach - New Match Available');
END $$
DELIMITER ;
