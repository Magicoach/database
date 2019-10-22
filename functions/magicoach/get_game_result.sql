DELIMITER $$
CREATE FUNCTION `get_game_result`(participation_result int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT CASE WHEN IFNULL(participation_result, 0) = 1 THEN 'Loser'
						WHEN IFNULL(participation_result, 0) = 2 THEN 'Draw' 
						WHEN IFNULL(participation_result, 0) = 3 THEN 'Winner' ELSE 'Unknown' END);
  RETURN @result;
END $$
DELIMITER ;
