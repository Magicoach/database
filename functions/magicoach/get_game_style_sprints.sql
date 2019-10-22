DELIMITER $$
CREATE FUNCTION `get_game_style_sprints`(id_participation int) RETURNS int(11) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
	SET @result = (SELECT CASE WHEN IFNULL(`ps`.`sprints`, 0) >= (SELECT `a`.`Scale_Magicpoints_sprints` FROM `1_algorithm_constants` a)
			THEN 100 ELSE `ps`.`sprints` END
        FROM `12_physical_stats` `ps`
        WHERE `ps`.`ID_Participation` = id_participation);

	RETURN @result;
END $$
DELIMITER ;
