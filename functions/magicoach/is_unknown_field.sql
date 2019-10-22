DELIMITER $$
CREATE FUNCTION `is_unknown_field`(id_participation int) RETURNS tinyint(1) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT p.ID_Field FROM `21_participations` p WHERE p.ID_Participation = id_participation);
	RETURN IF(@result = 122, true, false);
END $$
DELIMITER ;
