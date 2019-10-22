DELIMITER $$
CREATE FUNCTION `email_message_invalid_participation`(id_field int, goals int, time_start datetime, time_end datetime, result int, id_user int, device mediumtext, `version` varchar(255)) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN CONCAT('User: ', `id_user`, '<br>Field: ', `id_field`, '<br>Goals: ', `goals`, '<br>Result: ', `result`,
    '<br>Time Start: ', `time_start`, '<br>Time End: ', `time_end`, '<br>Device: ',`device` ,'<br>Version: ', `version`);
END $$
DELIMITER ;
