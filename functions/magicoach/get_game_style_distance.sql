DELIMITER $$
CREATE FUNCTION `get_game_style_distance`(id_participation int) RETURNS int(11) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
	SET @result = (SELECT CASE WHEN IFNULL(`ps`.`distance`, 0) >= (SELECT `a`.`Scale_Magicpoints_distance` FROM `1_algorithm_constants` a)
			THEN 100 ELSE ROUND(`ps`.`distance`*100/8, 0) END
        FROM `12_physical_stats` `ps`
        WHERE `ps`.`ID_Participation` = id_participation);

	RETURN @result;
END $$
DELIMITER ;
