DELIMITER $$
CREATE PROCEDURE `calculate_part_all4_dev_strava`(IN new_part int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SET @new_part = new_part;
  SET @lastTIME = '2015-01-19 03:14:07';
  SET @lastPART = 0;
  SET @lastX = 0;
  SET @lastY = 0;

  -- >>>>>>>> CALCULATE X,Y,DELTA_T from LAT.LONG,TIMESTAMP  
  INSERT INTO magic_table_1 (ID, time, X_temp, Y_temp, delta_t, last_time, last_part)
    SELECT
      `dev_strava_positions`.id AS ID,
     TIMESTAMP('2000.10.01 12:00:00', SEC_TO_TIME(`dev_strava_positions`.`time`)) AS time,
      6371000 / `dev_field_dimensions`.X_dir_baliza1 * ((`dev_strava_positions`.longitude - `dev_field_coordinates`.Long_esq_baliza1) * PI() / 180 * COS(`dev_field_coordinates`.Lat_esq_baliza1 * PI() / 180) * COS(`dev_field_dimensions`.Rotation) - (`dev_strava_positions`.latitude - `dev_field_coordinates`.Lat_esq_baliza1) * PI() / 180 * SIN(`dev_field_dimensions`.Rotation)) AS X_temp,
      6371000 / `dev_field_dimensions`.Y_esq_baliza2 * ((`dev_strava_positions`.longitude - `dev_field_coordinates`.Long_esq_baliza1) * PI() / 180 * COS(`dev_field_coordinates`.Lat_esq_baliza1 * PI() / 180) * SIN(`dev_field_dimensions`.Rotation) + (`dev_strava_positions`.latitude - `dev_field_coordinates`.Lat_esq_baliza1) * PI() / 180 * COS(`dev_field_dimensions`.Rotation)) AS Y_temp,
      IF(@lastPART = `dev_strava_positions`.id, TIMESTAMPDIFF(SECOND, @lastTIME, TIMESTAMP('2000.10.01 12:00:00', SEC_TO_TIME(`dev_strava_positions`.`time`))), 0) AS delta_t,
      @lastTIME := TIMESTAMP('2000.10.01 12:00:00', SEC_TO_TIME(`dev_strava_positions`.`time`)),
      @lastPART := `dev_strava_positions`.id
    FROM `dev_strava_positions`
      INNER JOIN `dev_field_dimensions` ON `dev_field_dimensions`.ID_Field = 0
      INNER JOIN `dev_field_coordinates` ON `dev_field_coordinates`.ID_Field = 0
    WHERE `dev_strava_positions`.id = @new_part;

  -- >>>>>>>> CHECK "MY GOAL"
  SET @goal_check = IF((SELECT SUM(delta_t)
  FROM `magic_table_1`
  WHERE X_temp >= 0 AND Y_temp >= 0 AND X_temp <= 1 AND Y_temp <= 0.7 AND ID = @new_part) > (SELECT SUM(delta_t)
  FROM `magic_table_1`
  WHERE X_temp >= 0 AND Y_temp >= 0.3 AND X_temp <= 1 AND Y_temp <= 1 AND ID = @new_part), 1, - 1);

  -- >>>>>>>> ROTATE Y AND X IF GOAL IS OPOSITE
  INSERT INTO magic_table_2 (ID, time, X_temp, Y_temp, delta_t)
    SELECT
      `magic_table_1`.ID AS ID,
      `magic_table_1`.`time` AS time,
      IF(@goal_check = - 1, 1 - `magic_table_1`.X_temp, `magic_table_1`.X_temp) AS X_temp,
      IF(@goal_check = - 1, 1 - `magic_table_1`.Y_temp, `magic_table_1`.Y_temp) AS Y_temp,
      `magic_table_1`.delta_t AS delta_t
    FROM `magic_table_1`
    WHERE `magic_table_1`.ID = @new_part;

  -- >>>>>>>> CALCULATE DISTANCE, SPEED AND DIRECTION
  INSERT INTO magic_table_3 (ID, time, X_temp, Y_temp, delta_t, distance, speed, direction, last_x, last_y)
    SELECT
      `magic_table_2`.ID AS ID,
      `magic_table_2`.`time` AS time,
      `magic_table_2`.X_temp AS X_temp,
      `magic_table_2`.Y_temp AS Y_temp,
      `magic_table_2`.delta_t AS delta_t,
      SQRT(POW(((`magic_table_2`.X_temp - @lastX) * X_dir_baliza1), 2) + POW(((`magic_table_2`.Y_temp - @lastY) * Y_esq_baliza2), 2)) AS distance,
      SQRT(POW(((`magic_table_2`.X_temp - @lastX) * X_dir_baliza1), 2) + POW(((`magic_table_2`.Y_temp - @lastY) * Y_esq_baliza2), 2)) / `magic_table_2`.delta_t * 3.6 AS speed,
      ATAN2((`magic_table_2`.Y_temp - @lastY) * Y_esq_baliza2, (`magic_table_2`.X_temp - @lastX) * X_dir_baliza1) * 180 / PI() + 180 AS direction,
      @lastX := `magic_table_2`.X_temp,
      @lastY := `magic_table_2`.Y_temp
    FROM `magic_table_2`
      INNER JOIN `dev_field_dimensions` ON `dev_field_dimensions`.ID_Field = 0
      INNER JOIN `dev_field_coordinates` ON `dev_field_coordinates`.ID_Field = 0
    WHERE `magic_table_2`.ID = @new_part;

  -- >>>>>>>> CALCULATE SPRINT_FLAG
  SET @sprint_vel = (SELECT Sprint_treshold FROM `1_algorithm_constants`);
  SET @sprint_counter = 3;

  INSERT INTO magic_table_4 (ID, time, X_temp, Y_temp, delta_t, distance, speed, direction, test, sprint_flag)
    SELECT
      `magic_table_3`.ID AS ID,
      `magic_table_3`.`time` AS time,
      `magic_table_3`.X_temp AS X_temp,
      `magic_table_3`.Y_temp AS Y_temp,
      `magic_table_3`.delta_t AS delta_t,
      `magic_table_3`.distance AS distance,
      `magic_table_3`.speed AS speed,
      `magic_table_3`.direction AS direction,
      IF(`magic_table_3`.speed > @sprint_vel, IF(@sprint_counter != 0, @sprint_counter := @sprint_counter - 1, 0), @sprint_counter := 3) AS test,
      IF(@sprint_counter = 0 AND `magic_table_3`.speed > @sprint_vel, 1, 0) AS sprint_flag
    FROM `magic_table_3`
    WHERE `magic_table_3`.ID = @new_part;
  SET @last_flag = 0;

  -- >>>>>>>> CALCULATE SPRINT_START
  INSERT INTO magic_table_5 (ID, time, X_temp, Y_temp, delta_t, distance, speed, direction, sprint_flag, sprint_start, test)
    SELECT
      `magic_table_4`.ID AS ID,
      `magic_table_4`.`time` AS time,
      `magic_table_4`.X_temp AS X_temp,
      `magic_table_4`.Y_temp AS Y_temp,
      `magic_table_4`.delta_t AS delta_t,
      `magic_table_4`.distance AS distance,
      `magic_table_4`.speed AS speed,
      `magic_table_4`.direction AS direction,
      `magic_table_4`.sprint_flag AS sprint_flag,
      IF(`magic_table_4`.sprint_flag = 1 AND @last_flag = 0, 1, 0) AS sprint_start,
      @last_flag := `magic_table_4`.sprint_flag AS test
    FROM `magic_table_4`
    WHERE `magic_table_4`.ID = @new_part;

  DELETE FROM `dev_analyzed_data_backup` WHERE `dev_analyzed_data_backup`.ID_Participation = @new_part;

  -- >>>>>>>> INSERT CALCULATED DATA INTO "ANALYSED_DATA"
  INSERT INTO `dev_analyzed_data_backup` (ID_Participation, time, X_percent, Y_percent, delta_t, distance, speed, direction, sprint_flag, sprint_start)
    SELECT
      ID,
      `time`,
      @a1 := X_temp,
      @a2 := Y_temp,
      @a3 := delta_t,
      @a4 := distance,
      @a5 := speed,
      @a6 := direction,
      @a7 := sprint_flag,
      @a8 := sprint_start
    FROM `magic_table_5`
    WHERE `magic_table_5`.ID = @new_part;

  DELETE FROM magic_table_1 WHERE magic_table_1.ID = @new_part;
  DELETE FROM magic_table_2 WHERE magic_table_2.ID = @new_part;
  DELETE FROM magic_table_3 WHERE magic_table_3.ID = @new_part;
  DELETE FROM magic_table_4 WHERE magic_table_4.ID = @new_part;
  DELETE FROM magic_table_5 WHERE magic_table_5.ID = @new_part;

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
        (SELECT COUNT(`12_map`.Map_value) FROM `12_map` WHERE `12_map`.ID_Participation = @new_part) AS field_ocupation
    FROM `dev_analyzed_data_backup` a
    WHERE a.ID_Participation = @new_part
    GROUP BY a.ID_Participation;

END $$
DELIMITER ;
