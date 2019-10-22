DELIMITER $$
CREATE FUNCTION `email_subject_new_password`() RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN 'Magicoach - New Password';
END $$
DELIMITER ;
