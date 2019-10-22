DELIMITER $$
CREATE PROCEDURE `mc_stats_user`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

    SELECT
      p.ID_player as id_player,
      @games := (SELECT
          IFNULL(COUNT(*), 0)
        FROM `21_participations` p
          JOIN `12_magicpoints` m
            ON m.ID_Participation = p.ID_Participation
        WHERE p.ID_player = id_user
        AND YEAR(p.time_start) >= '2016'
        AND m.magicpoints > 0) AS games,
      (SELECT
          IFNULL(SUM(m.magicpoints), 0)
        FROM `21_participations` p
          JOIN `12_magicpoints` m
            ON m.ID_Participation = p.ID_Participation
        WHERE p.ID_player = id_user
        AND YEAR(p.time_start) >= '2016') AS magicpoints,
      (SELECT
          IFNULL(COUNT(*), 0)
        FROM `21_participations` p1
          JOIN `12_magicpoints` m1
            ON m1.ID_Participation = p1.ID_Participation
        WHERE p1.result = 3
        AND p1.ID_player = id_user
        AND YEAR(p1.time_start) >= '2016'
        AND m1.magicpoints > 0) AS games_won,
      (SELECT
          IFNULL(COUNT(*), 0)
        FROM `21_participations` p2
          JOIN `12_magicpoints` m2
            ON m2.ID_Participation = p2.ID_Participation
        WHERE p2.result = 2
        AND p2.ID_player = id_user
        AND YEAR(p2.time_start) >= '2016'
        AND m2.magicpoints > 0) AS games_drawn,
      (SELECT
          IFNULL(COUNT(*), 0)
        FROM `21_participations` p3
          JOIN `12_magicpoints` m3
            ON m3.ID_Participation = p3.ID_Participation
        WHERE p3.result = 1
        AND p3.ID_player = id_user
        AND YEAR(p3.time_start) >= '2016'
        AND m3.magicpoints > 0) AS games_lost,
      @goals := (SELECT
          IFNULL(SUM(p4.my_goals), 0)
        FROM `21_participations` p4
          JOIN `12_magicpoints` m4
            ON m4.ID_Participation = p4.ID_Participation
        WHERE p4.ID_player = id_user
        AND YEAR(p4.time_start) >= '2016'
        AND m4.magicpoints > 0) AS goals,
      IFNULL(ROUND(@goals / @games, 1), 0) AS avg_goals,
      (SELECT
          IFNULL(SUM(TIMESTAMPDIFF(MINUTE, p5.time_start, p5.time_end)), 0)
        FROM `21_participations` p5
          JOIN `12_magicpoints` m5
            ON m5.ID_Participation = p5.ID_Participation
        WHERE p5.ID_player = id_user
        AND YEAR(p5.time_start) >= '2016'
        AND m5.magicpoints > 0) AS minutes_played,
      (SELECT
          get_game_result(p6.result)
        FROM `21_participations` p6
          JOIN `12_magicpoints` m6
            ON m6.ID_Participation = p6.ID_Participation
        WHERE p6.ID_player = id_user
        AND YEAR(p6.time_start) >= '2016'
        AND m6.magicpoints > 0
        ORDER BY p6.ID_Participation DESC LIMIT 1) AS result_last_game,
      (SELECT
          get_game_result(p7.result)
        FROM `21_participations` p7
          JOIN `12_magicpoints` m7
            ON m7.ID_Participation = p7.ID_Participation
        WHERE p7.ID_player = id_user
        AND YEAR(p7.time_start) >= '2016'
        AND m7.magicpoints > 0
        ORDER BY p7.ID_Participation DESC LIMIT 1 OFFSET 1) AS result_2_games_ago,
      (SELECT
          get_game_result(p8.result)
        FROM `21_participations` p8
          JOIN `12_magicpoints` m8
            ON m8.ID_Participation = p8.ID_Participation
        WHERE p8.ID_player = id_user
        AND YEAR(p8.time_start) >= '2016'
        AND m8.magicpoints > 0
        ORDER BY p8.ID_Participation DESC LIMIT 1 OFFSET 2) AS result_3_games_ago,
      (SELECT
          get_game_result(p9.result)
        FROM `21_participations` p9
          JOIN `12_magicpoints` m9
            ON m9.ID_Participation = p9.ID_Participation
        WHERE p9.ID_player = id_user
        AND YEAR(p9.time_start) >= '2016'
        AND m9.magicpoints > 0
        ORDER BY p9.ID_Participation DESC LIMIT 1 OFFSET 3) AS result_4_games_ago,
      (SELECT
          get_game_result(p10.result)
        FROM `21_participations` p10
          JOIN `12_magicpoints` m10
            ON m10.ID_Participation = p10.ID_Participation
        WHERE p10.ID_player = id_user
        AND YEAR(p10.time_start) >= '2016'
        AND m10.magicpoints > 0
        ORDER BY p10.ID_Participation DESC LIMIT 1 OFFSET 4) AS result_5_games_ago,
        
      (SELECT
          IFNULL(SUM(CASE WHEN player.distance_medal = 'gold' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.sprints_medal = 'gold' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.max_speed_medal = 'gold' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.avg_speed_medal = 'gold' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.perc_running_medal = 'gold' THEN 1 ELSE 0 END), 0)
        FROM (SELECT
			get_medal(`ps1`.`distance`, 'distance') AS distance_medal,
            get_medal(`ps1`.`sprints`, 'sprints') AS sprints_medal,
            get_medal(`ps1`.`max_speed`, 'max_speed') AS max_speed_medal,
            get_medal(`ps1`.`avg_speed`, 'avg_speed') AS avg_speed_medal,
            get_medal(`ps1`.`percent_running`*100, 'perc_running') AS perc_running_medal
          FROM `21_participations` p11
            JOIN `12_physical_stats` `ps1`
              ON p11.ID_Participation = `ps1`.`ID_Participation`
            JOIN `12_magicpoints` m11
              ON p11.`ID_Participation` = m11.`ID_Participation`
          WHERE p11.ID_player = id_user AND YEAR(p11.time_start) >= '2016'AND m11.magicpoints > 0) AS player
        WHERE player.distance_medal = 'gold'
        OR player.sprints_medal = 'gold'
        OR player.max_speed_medal = 'gold'
        OR player.avg_speed_medal = 'gold'
        OR player.perc_running_medal = 'gold') AS gold_medals,

      (SELECT
          IFNULL(SUM(CASE WHEN player.distance_medal = 'silver' THEN 1 ELSE 0 END)
         + SUM(CASE WHEN player.sprints_medal = 'silver' THEN 1 ELSE 0 END)
         + SUM(CASE WHEN player.max_speed_medal = 'silver' THEN 1 ELSE 0 END)
         + SUM(CASE WHEN player.avg_speed_medal = 'silver' THEN 1 ELSE 0 END)
         + SUM(CASE WHEN player.perc_running_medal = 'silver' THEN 1 ELSE 0 END), 0)
        FROM (SELECT
            get_medal(`ps2`.`distance`, 'distance') AS distance_medal,
            get_medal(`ps2`.`sprints`, 'sprints') AS sprints_medal,
            get_medal(`ps2`.`max_speed`, 'max_speed') AS max_speed_medal,
            get_medal(`ps2`.`avg_speed`, 'avg_speed') AS avg_speed_medal,
            get_medal(`ps2`.`percent_running`*100, 'perc_running') AS perc_running_medal
          FROM `21_participations` p11
            JOIN `12_physical_stats` `ps2` ON p11.ID_Participation = `ps2`.`ID_Participation`
            JOIN `12_magicpoints` m11 ON p11.`ID_Participation` = m11.`ID_Participation`
          WHERE p11.ID_player = id_user AND YEAR(p11.time_start) >= '2016' AND m11.magicpoints > 0) AS player
        WHERE player.distance_medal = 'silver'
        OR player.sprints_medal = 'silver'
        OR player.max_speed_medal = 'silver'
        OR player.avg_speed_medal = 'silver'
        OR player.perc_running_medal = 'silver') AS silver_medals,

      (SELECT
          IFNULL(SUM(CASE WHEN player.distance_medal = 'bronze' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.sprints_medal = 'bronze' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.max_speed_medal = 'bronze' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.avg_speed_medal = 'bronze' THEN 1 ELSE 0 END)
          + SUM(CASE WHEN player.perc_running_medal = 'bronze' THEN 1 ELSE 0 END), 0)
        FROM (SELECT
            get_medal(`ps3`.`distance`, 'distance') AS distance_medal,
            get_medal(`ps3`.`sprints`, 'sprints') AS sprints_medal,
            get_medal(`ps3`.`max_speed`, 'max_speed') AS max_speed_medal,
            get_medal(`ps3`.`avg_speed`, 'avg_speed') AS avg_speed_medal,
            get_medal(`ps3`.`percent_running`*100, 'perc_running') AS perc_running_medal
          FROM `21_participations` p11
            JOIN `12_physical_stats` `ps3` ON p11.ID_Participation = `ps3`.`ID_Participation`
            JOIN `12_magicpoints` m11 ON p11.`ID_Participation` = m11.`ID_Participation`
          WHERE p11.ID_player = id_user AND YEAR(p11.time_start) >= '2016' AND m11.magicpoints > 0) AS player
        WHERE player.distance_medal = 'bronze'
        OR player.sprints_medal = 'bronze'
        OR player.max_speed_medal = 'bronze'
        OR player.avg_speed_medal = 'bronze'
        OR player.perc_running_medal = 'bronze') AS bronze_medals

    FROM `21_participations` p
    WHERE p.ID_player = id_user
    GROUP BY p.ID_player;

  COMMIT;
END $$
DELIMITER ;
