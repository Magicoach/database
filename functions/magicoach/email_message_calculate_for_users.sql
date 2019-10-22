DELIMITER $$
CREATE FUNCTION `email_message_calculate_for_users`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
   SET @id_user = (SELECT
      p.ID_player
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @username = (SELECT
      u.username
    FROM `3_users` u
    WHERE u.ID = @id_user);
  SET @time_start = (SELECT
      p.time_start
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @time_end = (SELECT
      p.time_end
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @minutes_played = (SELECT
      TIMESTAMPDIFF(MINUTE, `p`.`time_start`, `p`.`time_end`)
    FROM `21_participations` `p`
    WHERE (`p`.`ID_Participation` = id_participation));
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

  RETURN CONCAT('Hello ', @username, ',',
  '<br><br>Your new match was analysed and is now available.Go to the App and re-click "Duel" to refresh the data.',
  '<br><br><b>NEW GAME DATA</b>',
  '<br> Start: ', IFNULL(@time_start, '?'),
  '<br> End: ', IFNULL(@time_end, '?'),
  '<br>Minutes Played: ', IFNULL(@minutes_played, '?'),
  '<br>Goals: ', IFNULL(@goals, '?'),
  '<br>Team Result: ', IFNULL(get_game_result(@result), '?'),
  '<br><br><b>PHYSIC PERFORMANCE</b>',
  '<br>Magicpoints: ', IFNULL(@magicpoints, '?'),
  '<br>Distance: ', IFNULL(CONCAT(@distance, ' Km'), '?'),
  '<br>Running: ', IFNULL(CONCAT(@perc_running, '%'), '?'),
  '<br>Sprints: ', IFNULL(@sprints, '?'),
  '<br>Avg Speed: ', IFNULL(CONCAT(@avg_speed, ' (km/h)'), '?'),
  '<br>Max Speed: ', IFNULL(CONCAT(@max_speed, ' (km/h)'), '?'),
  '<br><br><b>FIELD OCCUPATION: </b>',
  IFNULL(CONCAT(@perc_field_ocup, '%'), '?'),
  '<br><br><b>FIELD ZONES: </b>',
  IFNULL(get_field_zone(id_participation), '?'),
  '<br>Defense: ', IFNULL(CONCAT(@defense, ' Km'), '?'),
  '<br>Middle: ', IFNULL(CONCAT(@middle, ' Km'), '?'),
  '<br>Attack: ', IFNULL(CONCAT(@attack, ' Km'), '?'),
  '<br><br><b>GAME STYLE: </b>',
  IFNULL(get_game_style(id_participation), '?'),
  '<br><br>Best Regards,',
  '<br>support@magicoach.com',
  '<br>Magicoach - No More Friendlies',
  '<br>www.magicoach.com');
END $$
DELIMITER ;
