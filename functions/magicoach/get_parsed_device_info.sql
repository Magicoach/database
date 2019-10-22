DELIMITER $$
CREATE FUNCTION `get_parsed_device_info`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT
      p.device
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  RETURN IF(LOCATE('iPhone', @result) <> 0, SUBSTR(@result, LOCATE('iPhone', @result), 10), SUBSTR(@result, LOCATE('manufacturer', @result) + 14, 10));
END $$
DELIMITER ;
