DELIMITER $$
CREATE FUNCTION `email_message_calculate`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @time_start = (SELECT
      p.time_start
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @time_end = (SELECT
      p.time_end
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @perc_movement = (SELECT
      ROUND((((SUM(IF((`a`.`speed` <> 0), 1, 0)) + 1) / COUNT(`a`.`delta_t`)) * 100), 1)
    FROM `1_analyzed_data_backup` `a`
    WHERE a.ID_Participation = id_participation
    GROUP BY `a`.`ID_Participation`);
  SET @hit_rate = (SELECT
      ROUND(((COUNT(`a`.`time`) / (TIMESTAMPDIFF(SECOND, MIN(`a`.`time`), MAX(`a`.`time`)) + 1)) * 100), 1)
    FROM `1_analyzed_data_backup` `a`
    WHERE a.ID_Participation = id_participation
    GROUP BY `a`.`ID_Participation`);
  SET @goals = (SELECT
      p.my_goals
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @result = (SELECT
      p.result
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @magicpoints = (SELECT
      m.magicpoints
    FROM `12_magicpoints` m
    WHERE m.ID_Participation = id_participation);
  SET @avg_speed = (SELECT
      ROUND(ps.avg_speed, 1)
    FROM `12_physical_stats` ps
    WHERE ps.ID_Participation = id_participation);
  SET @distance = (SELECT
      ROUND(ps.distance, 1)
    FROM `12_physical_stats` ps
    WHERE ps.ID_Participation = id_participation);
  SET @perc_running = (SELECT
      ROUND(ps.percent_running * 100, 0)
    FROM `12_physical_stats` ps
    WHERE ps.ID_Participation = id_participation);
  SET @sprints = (SELECT
      ps.sprints
    FROM `12_physical_stats` ps
    WHERE ps.ID_Participation = id_participation);
  SET @avg_speed = (SELECT
      ROUND(ps.avg_speed, 1)
    FROM `12_physical_stats` ps
    WHERE ps.ID_Participation = id_participation);
  SET @max_speed = (SELECT
      ROUND(ps.max_speed, 1)
    FROM `12_physical_stats` ps
    WHERE ps.ID_Participation = id_participation);
  SET @defense = (SELECT
      ROUND(`a`.`defense`, 1)
    FROM `12_areas` a
    WHERE a.ID_Participation = id_participation);
  SET @middle = (SELECT
      ROUND(`a`.`middle`, 1)
    FROM `12_areas` a
    WHERE a.ID_Participation = id_participation);
  SET @attack = (SELECT
      ROUND(`a`.`attack`, 1)
    FROM `12_areas` a
    WHERE a.ID_Participation = id_participation);
  SET @perc_field_ocup = (SELECT
      ROUND((`m`.`field_ocupation` / 6), 0)
    FROM `12_magicpoints` m
    WHERE m.ID_Participation = id_participation);
  SET @version = (SELECT
      p.version
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @device = (SELECT
      p.device
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @player = (SELECT
      p.ID_player
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @email = (SELECT
      u.email
    FROM `21_participations` p
      JOIN `3_users` u
        ON u.ID = p.ID_player
    WHERE p.ID_Participation = id_participation);

  RETURN CONCAT('<b>GAME RESUME</b>',
  '<br>Email: ', IFNULL(@email, '?'),
  '<br>Time Start: ', IFNULL(@time_start, '?'),
  '<br>Time End: ', IFNULL(@time_end, '?'),
  '<br>Goals: ', IFNULL(@goals, '?'),
  '<br>Team Result: ', IFNULL(get_game_result(@result), '?'),
  '<br><br><b>GPS POSITIONS</b>',
  '<br>Hit Rate: ', IFNULL(CONCAT(@hit_rate, '%'), '?'),
  '<br>In Movement: ', IFNULL(CONCAT(@perc_movement, '%'), '?'),
  '<br><br><b>PHYSIC PERFORMANCE</b>',
  '<br>Magicpoints: ', IFNULL(@magicpoints, '?'),
  '<br>Distance: ', IFNULL(CONCAT(@distance, ' Km'), '?'),
  '<br>Running: ', IFNULL(CONCAT(@perc_running, '%'), '?'),
  '<br>Sprints: ', IFNULL(@sprints, '?'),
  '<br>Avg Speed: ', IFNULL(CONCAT(@avg_speed, ' (km/h)'), '?'),
  '<br>Max Speed: ', IFNULL(CONCAT(@max_speed, ' (km/h)'), '?'),
  '<br><br><b> POSITIONAL MAP: </b>',
  IFNULL(CONCAT(@perc_field_ocup, '%'), '?'),
  '<br><br><b>FIELD ZONES: </b>',
  IFNULL(get_field_zone(id_participation), '?'),
  '<br>Defense: ', IFNULL(CONCAT(@defense, ' Km'), '?'),
  '<br>Middle: ', IFNULL(CONCAT(@middle, ' Km'), '?'),
  '<br>Attack: ', IFNULL(CONCAT(@attack, ' Km'), '?'),
  '<br><br><b>GAME STYLE: </b>',
  IFNULL(get_game_style(id_participation), '?'),
  '<br><br><b>INTERNAL CODES</b>',
  '<br>Participation: ', id_participation,
  '<br>Player: ', IFNULL(@player, '?'),
  '<br>Version: ', IFNULL(@version, '?'),
  '<br>Device: ', IFNULL(@device, '?'));
END $$
DELIMITER ;
