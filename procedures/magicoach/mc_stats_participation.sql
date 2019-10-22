DELIMITER $$
CREATE PROCEDURE `mc_stats_participation`(IN id_participation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SELECT
    id_participation,
    get_challenge(id_participation) AS challenge_type,
    TIMESTAMPDIFF(SECOND, `p`.`time_start`, `p`.`time_end`) AS `duration_seconds`,
    TIMESTAMPDIFF(MINUTE, `p`.`time_start`, `p`.`time_end`) AS `duration_minutes`,
    IFNULL(p.my_goals, 0) AS `goals`,
    get_game_result(p.result) AS `game_result`,
	  IFNULL(`m`.`magicpoints`, 0) AS `magicpoints`,
    IFNULL(ROUND(`ps`.`max_speed`, 1), 0) AS `max_speed`,
    get_medal(`ps`.`max_speed`, 'max_speed') as max_speed_medal,
    IFNULL(ROUND(`ps`.`avg_speed`, 1), 0) AS `avg_speed`,
    get_medal(`ps`.`avg_speed`, 'avg_speed') as avg_speed_medal,
    IFNULL(ROUND(`ps`.`distance`, 1), 0) AS `distance`,
    get_medal(`ps`.`distance`, 'distance') as distance_medal,
    IFNULL(ROUND((`ps`.`percent_running`*100), 0), 0) AS `perc_running`,
    get_medal(`ps`.`percent_running`*100, 'perc_running') as perc_running_medal,
    IFNULL(`ps`.`sprints`, 0) AS `sprints`,
    get_medal(`ps`.`sprints`, 'sprints') as sprints_medal,
    IFNULL(ROUND(`a`.`defense`, 1), 0) AS `defense_km`,
    IFNULL(ROUND(`a`.`middle`, 1), 0) AS `middle_km`,
    IFNULL(ROUND(`a`.`attack`, 1), 0) AS `attack_km`,
    get_field_zone(id_participation) AS `field_zone`,
	  IFNULL(ROUND((`m`.`field_ocupation` / 6), 0), 0) AS `perc_positional_map`,
    get_game_style_sprints(id_participation) AS `game_style_sprints_x`,
    get_game_style_distance(id_participation) AS `game_style_distance_y`,
    IFNULL(ROUND(((get_game_style_sprints(id_participation) + get_game_style_distance(id_participation)) / 2), 1), 0) AS `game_style_xy`,
  	get_game_style(id_participation) AS `game_style`
    FROM `21_participations` `p`
      JOIN `12_areas` `a` ON `p`.`ID_Participation` = `a`.`id_participation`
      JOIN `12_physical_stats` `ps` ON `a`.`id_participation` = `ps`.`ID_Participation`
      JOIN `12_magicpoints` `m` ON `ps`.`ID_Participation` = `m`.`ID_Participation`
    WHERE `p`.`ID_Participation` = id_participation;

  COMMIT;
END $$
DELIMITER ;
