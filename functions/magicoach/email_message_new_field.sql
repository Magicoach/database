DELIMITER $$
CREATE FUNCTION `email_message_new_field`(`email` varchar(255),`id_participation` int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
   SET @time_start = (SELECT
      p.time_start
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @time_end = (SELECT
      p.time_end
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @goals = (SELECT
      p.my_goals
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @result = (SELECT
      p.result
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @version = (SELECT
      p.version
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @device = (SELECT
      p.device
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @player = (SELECT
      p.ID_player
    FROM `21_participations` p
    WHERE p.ID_Participation = id_participation);
  SET @email = (SELECT
      u.email
    FROM `21_participations` p
      JOIN `3_users` u
        ON u.ID = p.ID_player
    WHERE p.ID_Participation = id_participation);
  SET @GPS_POINTS = (SELECT
    COUNT(`0_positions`.time) AS expr1
  FROM `0_positions`
    INNER JOIN `21_participations`
      ON `0_positions`.ID_Participation = `21_participations`.ID_Participation
    WHERE `21_participations`.ID_Participation = id_participation
    GROUP BY `0_positions`.ID_Participation);
  SET @avg_lat = (SELECT
      AVG(`0_positions`.latitude)
    FROM `0_positions`
      INNER JOIN `21_participations`
    ON `0_positions`.ID_Participation = `21_participations`.ID_Participation
     WHERE `21_participations`.ID_Participation = id_participation
     GROUP BY `0_positions`.ID_Participation);
  SET @avg_long = (SELECT
      AVG(`0_positions`.longitude)
    FROM `0_positions`
      INNER JOIN `21_participations`
    ON `0_positions`.ID_Participation = `21_participations`.ID_Participation
     WHERE `21_participations`.ID_Participation = id_participation
     GROUP BY `0_positions`.ID_Participation);

  RETURN CONCAT('<b>GAME RESUME</b>',
  '<br>Email: ', IFNULL(@email, '?'),
  '<br>Time Start: ', IFNULL(@time_start, '?'),
  '<br>Time End: ', IFNULL(@time_end, '?'),
  '<br>Goals: ', IFNULL(@goals, '?'),
  '<br>Team Result: ', IFNULL(get_game_result(@result), '?'),
  '<br><br><b>GPS POSITIONS</b>',
  '<a href=" http://www.google.com/maps/place/',IFNULL(@avg_lat, '?'),',',IFNULL(@avg_long, '?'),'">Map Link</a>',
  '<br>GPS Points: ', IFNULL(@GPS_POINTS, '?'),
  '<br>AVG Lat: ', IFNULL(@avg_lat, '?'),
  '<br>AVG Long: ', IFNULL(@avg_long, '?'),
  '<br><br><b>INTERNAL CODES</b>',
  '<br>Participation: ', id_participation,
  '<br>Player: ', IFNULL(@player, '?'),
  '<br>Version: ', IFNULL(@version, '?'),
  '<br>Device: ', IFNULL(@device, '?'));

END $$
DELIMITER ;
