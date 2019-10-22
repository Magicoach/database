DELIMITER $$
CREATE PROCEDURE `mcmaps_calculate_map_pro`(IN id_player int, IN map_width double PRECISION, IN map_height double PRECISION, IN ratio_start double PRECISION, IN ratio_end double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  -- GameTimeline --> ### BEGIN ### HALFTIME ### END
  -- ratio_start: --------- 1 -------- 0.5 ------ 0
  -- ratio_end:   --------- 0 -------- 0.5 ------ 1

  -- Examples
  -- Full Game: ---- ratio_start=1 ---- ratio_end=1 
  -- First Half: --- ratio_start=1 ---- ratio_end=0.5
  -- Second Half: -- ratio_start=0.5 -- ratio_end=1

  SET @time_start = (SELECT
      ADDTIME('2000.01.01 00:00:00', MIN(SEC_TO_TIME(minutes * seconds + additional_minutes)))
    FROM dev_participations_pro
    WHERE player_id = id_player);
  SET @time_end = (SELECT
      ADDTIME('2000.01.01 00:00:00', MAX(SEC_TO_TIME(minutes * seconds + additional_minutes)))
    FROM dev_participations_pro
    WHERE player_id = id_player);
  SET @time_start_ratio = (SELECT
      SUBTIME(@time_end, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)) * ratio_start, 0))));
  SET @time_end_ratio = (SELECT
      ADDTIME(@time_start, SEC_TO_TIME(ROUND((TO_SECONDS(@time_end) - TO_SECONDS(@time_start)) * ratio_end, 0))));
  SET @radius = (ROUND(SQRT(POW(map_width, 2) + POW(map_height, 2)) / 7, 2));

  CREATE TEMPORARY TABLE IF NOT EXISTS filter AS (SELECT
      SEC_TO_TIME(CONCAT(minutes * seconds + additional_minutes)) AS time,
      IF(period = 1, fc_y / 70, (70 - fc_y) / 70) AS X_percent,
      IF(period = 1, fc_x / 105, (105 - fc_x) / 105) AS Y_percent,
      flip_fc AS flip
    FROM dev_participations_pro
    WHERE player_id = id_player
    AND fc_x IS NOT NULL
    AND fc_y IS NOT NULL);

  SET @positions = (SELECT
      COUNT(*)
    FROM filter
    WHERE `time` BETWEEN @time_start_ratio AND @time_end_ratio);

  SELECT
    ROUND(IF(a.flip = 1, map_width * TRUNCATE(a.X_percent * 2, 1) / 2, map_width * (1 - TRUNCATE(a.X_percent * 2, 1) / 2)), 0) AS x,
    ROUND(IF(a.flip = 1, map_height * (1 - TRUNCATE(a.Y_percent * 3, 1) / 3), map_height * TRUNCATE(a.Y_percent * 3, 1) / 3), 0) AS y,
    IF(COUNT(a.time) > @positions / 100, @radius, NULL) AS radius
  FROM filter a
  WHERE a.time BETWEEN @time_start_ratio AND @time_end_ratio
  GROUP BY TRUNCATE(a.X_percent * 2, 1) / 2,
           TRUNCATE(a.Y_percent * 3, 1) / 3
  HAVING radius IS NOT NULL;

  DROP TEMPORARY TABLE IF EXISTS filter;
END $$
DELIMITER ;
