DELIMITER $$
CREATE FUNCTION `email_message_invalid_calculate`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN CONCAT('Participation: ', id_participation);
END $$
DELIMITER ;
