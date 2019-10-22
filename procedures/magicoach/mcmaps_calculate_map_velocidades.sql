DELIMITER $$
CREATE PROCEDURE `mcmaps_calculate_map_velocidades`(IN id_part int, IN map_width int, IN map_height int, IN ratio_start double PRECISION, IN ratio_end double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  -- GameTimeline --> ### BEGIN ### HALFTIME ### END
  -- ratio_start: --------- 1 -------- 0.5 ------ 0
  -- ratio_end:   --------- 0 -------- 0.5 ------ 1

  -- Examples
  -- Full Game: ---- ratio_start=1 ---- ratio_end=1 
  -- First Half: --- ratio_start=1 ---- ratio_end=0.5
  -- Second Half: -- ratio_start=0.5 -- ratio_end=1

 
  SET @time_start = (SELECT MIN(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part);
  SET @time_end = (SELECT  MAX(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part);
  SET @time_start_ratio = (SELECT SUBTIME(@time_end, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)) * ratio_start, 0))));
  SET @time_end_ratio = (SELECT ADDTIME(@time_start, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)) * ratio_end, 0))));
  SET @map_value_scaling = ((SELECT ROUND(SUM(aa.delta_t) / 60, 0) FROM `1_analyzed_data_backup` aa WHERE aa.ID_Participation = id_part
             AND aa.time BETWEEN @time_start_ratio AND @time_end_ratio
             AND aa.X_percent BETWEEN 0 AND 1
             AND aa.Y_percent BETWEEN 0 AND 1
             AND aa.speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`) GROUP BY aa.ID_Participation) / 
           (SELECT Map_Y_grid_size FROM `1_algorithm_constants`) / 
           (SELECT Map_X_grid_size FROM `1_algorithm_constants`) * 
           (SELECT Map_value_treshold FROM `1_algorithm_constants`));
  set @radius = (ROUND(SQRT(POW(map_width, 2) + POW(map_height, 2)) / 17, 2))*2;

SELECT
      a.ID_Participation AS ID_Participation,
      ROUND((map_width * TRUNCATE(a.X_percent * 2, 1) / 2), 0) AS x,
      ROUND(ROUND((1 - TRUNCATE(a.Y_percent * 3, 1) / 3) * map_height, 0), 0) AS y,
      IF(a.speed > (SELECT Map_active_speed_treshold FROM `1_algorithm_constants`) AND SUM(a.delta_t) > 170 * @map_value_scaling, @radius, NULL) AS radius
    FROM `1_analyzed_data_backup` a
    WHERE a.ID_Participation = id_part
      AND a.time BETWEEN @time_start_ratio AND @time_end_ratio
      AND a.X_percent BETWEEN 0 AND 1
      AND a.Y_percent BETWEEN 0 AND 1
      AND a.speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`)
    GROUP BY TRUNCATE(a.X_percent * 2, 1) / 2,
            TRUNCATE(a.Y_percent * 3, 1) / 3
    HAVING radius IS NOT NULL;

 -- DELETE
 /*   FROM `2_stats`
  WHERE id_participation = id_part;

  INSERT INTO `2_stats` (id_participation, max_speed, avg_speed, distance, percent_running, time_played, sprints, defense, middle, attack, up, up_right, `right`, down_right, down, down_left, `left`, up_left, magicpoints, field_ocupation)
    SELECT
      id_participation AS id_participation,
      @max_speed := MAX(a.speed) AS max_speed,
      @avg_speed := AVG(a.speed) AS avg_speed,
      @distance := SUM(a.distance / 1000) AS distance,
      @percent_running := SUM(IF(a.speed >= (SELECT percent_running_treshold FROM `1_algorithm_constants`), a.delta_t, 0)) / SUM(a.delta_t) AS percent_running,
      ROUND(SUM(a.delta_t) / 60, 0) AS time_played,
      @sprints := SUM(a.sprint_start) AS sprints,
      SUM(IF(a.Y_percent <= 0.33, (a.distance), 0)) / 1000 AS defense,
      SUM(IF(a.Y_percent > 0.33 AND a.Y_percent < 0.66, (a.distance), 0)) / 1000 AS middle,
      SUM(IF(a.Y_percent >= 0.66, (a.distance), 0)) / 1000 AS attack,
      SUM(IF(a.direction >= 337.5 OR a.direction < 22.5, (a.distance), 0)) / 1000 * 0.5 AS up,
      SUM(IF(a.direction >= 22.5 AND a.direction < 67.5, (a.distance), 0)) / 1000 * 0.5 AS up_rigth,
      SUM(IF(a.direction >= 67.5 AND a.direction < 112.5, (a.distance), 0)) / 1000 * 0.5 AS rigth,
      SUM(IF(a.direction >= 112.5 AND a.direction < 157.5, (a.distance), 0)) / 1000 * 0.5 AS down_right,
      SUM(IF(a.direction >= 157.5 AND a.direction < 202.5, (a.distance), 0)) / 1000 * 0.5 AS down,
      SUM(IF(a.direction >= 202.5 AND a.direction < 247.5, (a.distance), 0)) / 1000 * 0.5 AS down_left,
      SUM(IF(a.direction >= 247.5 AND a.direction < 292.5, (a.distance), 0)) / 1000 * 0.5 AS `left`,
      SUM(IF(a.direction >= 292.5 AND a.direction < 337.5, (a.distance), 0)) / 1000 * 0.5 AS up_left,
      (SELECT Scale_Magicpoints_per_game FROM `1_algorithm_constants`) / 5 * (@max_speed / 
        (SELECT Scale_Magicpoints_max_speed FROM `1_algorithm_constants`) + @avg_speed / 
        (SELECT Scale_Magicpoints_avg_speed FROM `1_algorithm_constants`) + @sprints / 
        (SELECT Scale_Magicpoints_sprints FROM `1_algorithm_constants`) + @distance / 
        (SELECT Scale_Magicpoints_distance FROM `1_algorithm_constants`) + @percent_running / 
        (SELECT Scale_Magicpoints_percentage_running FROM `1_algorithm_constants`)) AS magicpoints,
        (SELECT COUNT(`12_map`.Map_value) FROM `12_map` WHERE `12_map`.ID_Participation = id_part) AS field_ocupation
    FROM `1_analyzed_data_filtered` a
    WHERE a.ID_Participation = id_part
    GROUP BY a.ID_Participation;

  --  UPDATE `21_participations` SET `21_participations`.status = 1 WHERE `21_participations`.ID_Participation = id_part;

  SELECT
    ROUND((m.Y_percent * map_width), 0) AS x,
    ROUND(map_height - ROUND((1 - m.X_percent) * map_height, 0), 0) AS y,
    ROUND(SQRT(POW(map_width, 2) + POW(map_height, 2)) / 17, 2) AS radius
  FROM `12_map` m
  WHERE m.ID_Participation = id_part
  ORDER BY X, Y;*/
END $$
DELIMITER ;
