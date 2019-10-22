DELIMITER $$
CREATE FUNCTION `has_positions`(id_participation int) RETURNS tinyint(1) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT COUNT(*) FROM `0_positions` p WHERE p.ID_Participation = id_participation);
	RETURN IF(@result >= 1, true, false);
END $$
DELIMITER ;
