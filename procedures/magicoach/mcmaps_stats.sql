DELIMITER $$
CREATE PROCEDURE `mcmaps_stats`(IN id_part int, IN ratio_start double PRECISION, IN ratio_end double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SET @time_start = (SELECT MIN(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part AND X_percent BETWEEN 0 AND 1 AND Y_percent BETWEEN 0 AND 1);
  SET @time_end = (SELECT  MAX(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part AND X_percent BETWEEN 0 AND 1 AND Y_percent BETWEEN 0 AND 1);
  SET @time_start_ratio = (SELECT SUBTIME(@time_end, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)) * ratio_start, 0))));
  SET @time_end_ratio = (SELECT ADDTIME(@time_start, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)) * ratio_end, 0))));

  SELECT
      @max_speed := ROUND(MAX(a.speed), 2) AS max_speed,
      @avg_speed := ROUND(AVG(a.speed), 2) AS avg_speed,
      @distance := ROUND(SUM(a.distance / 1000), 2) AS distance,
      ROUND(SUM(a.delta_t) / 60, 0) AS time_played,
      @sprints := SUM(a.sprint_start) AS sprints,
      @percent_running := SUM(IF(a.speed >= (SELECT percent_running_treshold FROM `1_algorithm_constants`), a.delta_t, 0)) / SUM(a.delta_t) AS percent_running,
      ROUND(SUM(IF(a.Y_percent >= 0.50, (a.time), 0)) / SUM(a.time), 3) AS attack_percentage,
      ROUND(SUM(IF(a.Y_percent <= 0.33, (a.distance), 0)) / 1000, 2) AS defense,
      ROUND(SUM(IF(a.Y_percent > 0.33 AND a.Y_percent < 0.66, (a.distance), 0)) / 1000,2) AS middle,
      ROUND(SUM(IF(a.Y_percent >= 0.66, (a.distance), 0)) / 1000, 2) AS attack,
      (SELECT Scale_Magicpoints_per_game FROM `1_algorithm_constants`) / 5 * (@max_speed / 
        (SELECT Scale_Magicpoints_max_speed FROM `1_algorithm_constants`) + @avg_speed / 
        (SELECT Scale_Magicpoints_avg_speed FROM `1_algorithm_constants`) + @sprints / 
        (SELECT Scale_Magicpoints_sprints FROM `1_algorithm_constants`) + @distance / 
        (SELECT Scale_Magicpoints_distance FROM `1_algorithm_constants`) + @percent_running / 
        (SELECT Scale_Magicpoints_percentage_running FROM `1_algorithm_constants`)) AS magicpoints,
        (SELECT COUNT(`12_map`.Map_value) FROM `12_map` WHERE `12_map`.ID_Participation = id_part) AS field_ocupation
    FROM `1_analyzed_data_backup` a
    WHERE a.ID_Participation = id_part
      AND a.time BETWEEN @time_start_ratio AND @time_end_ratio
      AND a.X_percent BETWEEN 0 AND 1
      AND a.Y_percent BETWEEN 0 AND 1
      AND a.speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`)
    GROUP BY a.ID_Participation;

END $$
DELIMITER ;
