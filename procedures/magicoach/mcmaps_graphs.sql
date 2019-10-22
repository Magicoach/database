DELIMITER $$
CREATE PROCEDURE `mcmaps_graphs`(IN id_part int,  IN intervals double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SET @time_start = (SELECT MIN(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part AND X_percent BETWEEN 0 AND 1 AND Y_percent BETWEEN 0 AND 1 AND speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`));
  SET @time_end = (SELECT  MAX(`time`) FROM `1_analyzed_data_backup` WHERE ID_Participation = id_part AND X_percent BETWEEN 0 AND 1 AND Y_percent BETWEEN 0 AND 1 AND speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`));
  SET @time_start_ratio = (SUBTIME(@time_end, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)), 0))));
  SET @time_end_ratio = (ADDTIME(@time_start, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)), 0))));

  SELECT
     TRUNCATE ((TIME_TO_SEC(a.time) - TIME_TO_SEC(@time_start)) / (TIME_TO_SEC(@time_end) - TIME_TO_SEC(@time_start))*intervals, 0) / intervals AS `interval`,
      ROUND(SUM(a.distance)/1000, 2) AS distance,
      ROUND(IF(AVG(a.speed)/7.5>1, 1, AVG(a.speed)/7.5), 3) AS avg_speed,
      SUM(a.sprint_start) AS sprints,
      ROUND(IF(SUM(a.sprint_start)/4>1,1,SUM(a.sprint_start)/4),3) AS sprints_graph,
      ROUND(AVG(a.Y_percent), 2) AS attack_percentage,
      ROUND(AVG(a.X_percent), 2) AS lateral_percentage
    FROM `1_analyzed_data_backup` a
    WHERE a.ID_Participation = id_part AND
      a.X_percent BETWEEN 0 AND 1 AND
      a.Y_percent BETWEEN 0 AND 1 AND
      a.speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`)
    GROUP BY `interval`
    HAVING `interval` < 1;

END $$
DELIMITER ;
