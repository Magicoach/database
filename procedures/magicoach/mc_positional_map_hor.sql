DELIMITER $$
CREATE PROCEDURE `mc_positional_map_hor`(IN id_participation int, IN map_width int, IN map_height int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SELECT
    ROUND(m.Y_percent * map_width, 0) AS x,
    ROUND(map_height - ((1 - m.X_percent) * map_height), 0) AS y,
    ROUND(SQRT(POW(map_width,2)+POW(map_height,2))/17, 2) AS radius
  FROM `12_map` m
  WHERE m.ID_Participation = id_participation;

  COMMIT;
END $$
DELIMITER ;
