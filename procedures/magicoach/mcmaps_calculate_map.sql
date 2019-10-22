DELIMITER $$
CREATE PROCEDURE `mcmaps_calculate_map`(IN id_part int, IN map_width double PRECISION, IN map_height double PRECISION, IN ratio_start double PRECISION, IN ratio_end double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  -- GameTimeline --> ### BEGIN ### HALFTIME ### END
  -- ratio_start: --------- 1 -------- 0.5 ------ 0
  -- ratio_end:   --------- 0 -------- 0.5 ------ 1

  -- Examples
  -- Full Game: ---- ratio_start=1 ---- ratio_end=1 
  -- First Half: --- ratio_start=1 ---- ratio_end=0.5
  -- Second Half: -- ratio_start=0.5 -- ratio_end=1

  SET @time_start = (SELECT MIN(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part AND X_percent BETWEEN 0 AND 1 AND Y_percent BETWEEN 0 AND 1 AND speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`));
  SET @time_end = (SELECT  MAX(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part AND X_percent BETWEEN 0 AND 1 AND Y_percent BETWEEN 0 AND 1 AND speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`));
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
  SET @radius = (ROUND(SQRT(POW(map_width, 2) + POW(map_height, 2)) / 17, 2))*2;

  SELECT
      ROUND(map_width * TRUNCATE(a.X_percent * 2, 1) / 2, 0) AS x,
      ROUND(map_height * (1 - TRUNCATE(a.Y_percent * 3, 1) / 3), 0) AS y,
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

END $$
DELIMITER ;
