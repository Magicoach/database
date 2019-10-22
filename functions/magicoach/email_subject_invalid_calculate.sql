DELIMITER $$
CREATE FUNCTION `email_subject_invalid_calculate`() RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN 'Magicoach - Invalid Calculate';
END $$
DELIMITER ;
