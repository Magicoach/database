DELIMITER $$
CREATE FUNCTION `email_subject_calculate`(`username` varchar(255), `fieldname` varchar(255)) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN CONCAT('Magicoach - ', `username`, ' at ', `fieldname`);
END $$
DELIMITER ;
