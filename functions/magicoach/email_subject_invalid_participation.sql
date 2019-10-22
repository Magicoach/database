DELIMITER $$
CREATE FUNCTION `email_subject_invalid_participation`() RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
RETURN 'Magicoach - Invalid Participation';
END $$
DELIMITER ;
