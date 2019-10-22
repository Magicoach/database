DELIMITER $$
CREATE PROCEDURE `central_position_field`(IN id_participation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN
  
  SET @sum = 0;
  SET @total_positions = (SELECT COUNT(*) FROM `0_positions` p WHERE p.ID_Participation = id_participation);

  -- TODO: remove outliers. hint: limit speed change.
  -- Don't use speed column from 0_positions. it's not accurate
  SELECT
    AVG(p2.latitude) AS latitude,
    AVG(p2.longitude) AS longitude
  FROM `0_positions` p2
    JOIN (SELECT
          p.time AS time,
          p.latitude AS latitude,
          p.longitude AS longitude,
          @sum := @sum + 100 / @total_positions AS percentage -- filter initial and final positions
        FROM `0_positions` p
        WHERE p.ID_Participation = id_participation
        GROUP BY percentage
        HAVING percentage > 20
        AND percentage < 60) AS filter
        ON filter.time = p2.time
  WHERE p2.ID_Participation = id_participation
  GROUP BY p2.ID_Participation;

END $$
DELIMITER ;
