DELIMITER $$
CREATE PROCEDURE `mc_strava_calculate_part`(IN strava_id_part varchar(40), IN id_participation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

SET @input_strava_id_part = strava_id_part;
SET @input_id_participation = id_participation;

 INSERT INTO `0_positions` (ID_Participation, time, latitude, longitude, altitude, speed)
  SELECT
    @input_id_participation, 
    dev_strava_positions_3.time,
    dev_strava_positions_3.latitude,
    dev_strava_positions_3.longitude,
    NULL,
    NULL
  FROM dev_strava_positions_3
WHERE dev_strava_positions_3.id =@input_strava_id_part;

CALL mc_calculate_participation(@input_id_participation);

END $$
DELIMITER ;
