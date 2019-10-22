DELIMITER $$
CREATE FUNCTION `get_game_style`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN

	SET @result = (SELECT CASE
		WHEN ((`ps`.`distance` >= ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_distance`
									FROM `1_algorithm_constants`) / 2)) AND 
			  (`ps`.`sprints` < ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_sprints`
									FROM `1_algorithm_constants`) / 2))) THEN 'Combative'
		WHEN ((`ps`.`distance` < ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_distance`
									FROM `1_algorithm_constants`) / 2)) AND 
			  (`ps`.`sprints` >= ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_sprints`
									FROM `1_algorithm_constants`) / 2))) THEN 'Explosive'
		WHEN ((`ps`.`distance` >= ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_distance`
									FROM `1_algorithm_constants`) / 2)) AND 
			  (`ps`.`sprints` >= ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_sprints`
									FROM `1_algorithm_constants`) / 2))) THEN 'Box-to-Box'
		WHEN ((`ps`.`distance` < ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_distance`
									FROM `1_algorithm_constants`) / 2)) AND 
			  (`ps`.`sprints` < ((SELECT `1_algorithm_constants`.`Scale_Magicpoints_sprints`
									FROM `1_algorithm_constants`) / 2))) THEN 'Positional'
		ELSE 'Unknown' END
        FROM `12_physical_stats` ps
        WHERE `ps`.`ID_Participation` = id_participation);

	RETURN @result;
END $$
DELIMITER ;
