DELIMITER $$
CREATE PROCEDURE `calculate_part_all3`(IN new_part int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SET @new_part = new_part;
  SET @lastTIME = '2015-01-19 03:14:07';
  SET @lastPART = 0;
  SET @lastX = 0;
  SET @lastY = 0;

  /*
DROP TABLE IF EXISTS magic_table_1;
DROP TABLE IF EXISTS magic_table_2;
DROP TABLE IF EXISTS magic_table_3;
DROP TABLE IF EXISTS magic_table_4;
DROP TABLE IF EXISTS magic_table_5;
DROP TABLE IF EXISTS map_value_tot_1;

CREATE TABLE magic_table_1
(
  ID int,
  time datetime,
  X_temp double,
  Y_temp double,
  delta_t bigint(21),
  last_time varchar(19),
  last_part int
);

CREATE TABLE magic_table_2
(
  ID int,
  time datetime,
  X_temp double,
  Y_temp double,
  delta_t bigint(21)
);

CREATE TABLE magic_table_3
(
  ID int,
  time datetime,
  X_temp double,
  Y_temp double,  
  delta_t bigint(21),
  distance double,
  speed double,
  direction double,
  last_x double,
  last_y double
);

CREATE TABLE magic_table_4
(
  ID int,
  time datetime,
  X_temp double,
  Y_temp double,  
  delta_t bigint(21),
  distance double,
  speed double,
  direction double,
  test bigint(63),
  sprint_flag int
);

CREATE TABLE magic_table_5
(
  ID int,
  time datetime,
  X_temp double,
  Y_temp double,  
  delta_t bigint(21),
  distance double,
  speed double,
  direction double,
  sprint_flag int(1),
  sprint_start int(1),
  test int(11)
);

CREATE TABLE map_value_tot_1
(
  ID_Participation int,
  Map_value int
);
*/

  -- >>>>>>>> CALCULATE X,Y,DELTA_T from LAT.LONG,TIMESTAMP  
  INSERT INTO magic_table_1 (ID, time, X_temp, Y_temp, delta_t, last_time, last_part)
    SELECT
      `0_positions`.ID_Participation AS ID,
      `0_positions`.`time` AS time,
      6371000 / `12_field_dimensions`.X_dir_baliza1 * ((`0_positions`.longitude - `21_field_coordinates`.Long_esq_baliza1) * PI() / 180 * COS(`21_field_coordinates`.Lat_esq_baliza1 * PI() / 180) * COS(`12_field_dimensions`.Rotation) - (`0_positions`.latitude - `21_field_coordinates`.Lat_esq_baliza1) * PI() / 180 * SIN(`12_field_dimensions`.Rotation)) AS X_temp,
      6371000 / `12_field_dimensions`.Y_esq_baliza2 * ((`0_positions`.longitude - `21_field_coordinates`.Long_esq_baliza1) * PI() / 180 * COS(`21_field_coordinates`.Lat_esq_baliza1 * PI() / 180) * SIN(`12_field_dimensions`.Rotation) + (`0_positions`.latitude - `21_field_coordinates`.Lat_esq_baliza1) * PI() / 180 * COS(`12_field_dimensions`.Rotation)) AS Y_temp,
      IF(@lastPART = `0_positions`.ID_Participation, TIMESTAMPDIFF(SECOND, @lastTIME, `0_positions`.`time`), 0) AS delta_t,
      @lastTIME := `0_positions`.`time`,
      @lastPART := `0_positions`.ID_Participation
    FROM `0_positions`
      INNER JOIN `21_participations` ON `0_positions`.ID_Participation = `21_participations`.ID_Participation
      INNER JOIN `12_field_dimensions` ON `12_field_dimensions`.ID_Field = `21_participations`.ID_Field
      INNER JOIN `21_field_coordinates` ON `21_field_coordinates`.ID_Field = `21_participations`.ID_Field
    WHERE `0_positions`.ID_Participation = @new_part;

  -- >>>>>>>> CHECK "MY GOAL"
  SET @goal_check = IF((SELECT
    SUM(delta_t)
  FROM `magic_table_1`
  WHERE X_temp >= 0 AND Y_temp >= 0 AND X_temp <= 1 AND Y_temp <= 0.7 AND ID = @new_part) > (SELECT
    SUM(delta_t)
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

  -- >>>>>>>> SMOOTH X AND Y (MOOVING AVERAGE)
  -- CREATE TABLE tmp_table_31 
  --  SELECT 
  -- tmp_table_21.ID AS ID,
  --    tmp_table_21.`time` AS time,
  --    tmp_table_21.X_temp AS X_old,
  --    tmp_table_21.Y_temp AS Y_old,
  --    avg(`tmp_table_past`.X_temp) AS X_temp,
  --    avg(`tmp_table_past`.Y_temp) AS Y_temp,
  --    `tmp_table_21`.delta_t AS delta_t
  -- from tmp_table_21
  -- join tmp_table_21 as `tmp_table_past` 
  --  on `tmp_table_past`.time BETWEEN SUBDATE(tmp_table_21.`time`,INTERVAL 1 SECOND) and ADDDATE(tmp_table_21.`time`,INTERVAL 1 SECOND)
  -- group by 1, 2;

  -- >>>>>>>> DUPLICATE SMOOTH EFFECT
  -- CREATE TABLE tmp_table_2 
  --  SELECT 
  -- tmp_table_31.ID AS ID,
  --     tmp_table_31.`time` AS time,
  --     tmp_table_31.X_temp AS X_old,
  --     tmp_table_31.Y_temp AS Y_old,
  --     avg(`tmp_table_past_2`.X_temp) AS X_temp,
  --    avg(`tmp_table_past_2`.Y_temp) AS Y_temp,
  --     `tmp_table_31`.delta_t AS delta_t
  -- from tmp_table_31
  -- join tmp_table_31 as `tmp_table_past_2` 
  --   on `tmp_table_past_2`.time between SUBDATE(tmp_table_31.`time`,INTERVAL 1 SECOND) and ADDDATE(tmp_table_31.`time`,INTERVAL 1 SECOND)
  -- group by 1, 2;

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
      INNER JOIN `21_participations`
        ON `magic_table_2`.ID = `21_participations`.ID_Participation
      INNER JOIN `12_field_dimensions`
        ON `12_field_dimensions`.ID_Field = `21_participations`.ID_Field
      INNER JOIN `21_field_coordinates`
        ON `21_field_coordinates`.ID_Field = `21_participations`.ID_Field
    WHERE `magic_table_2`.ID = @new_part;

  -- >>>>>>>> SPEED SMOOTH EFFECT
  -- CREATE TABLE tmp_table_3 
  --   SELECT 
  --    tmp_table_32.ID AS ID,
  --    tmp_table_32.`time` AS time,
  --    tmp_table_32.X_temp AS X_temp,
  --    tmp_table_32.Y_temp AS Y_temp,
  --    tmp_table_32.delta_t AS delta_t,
  --    tmp_table_32.distance AS distance,
  --    avg(`tmp_table_past_3`.speed) AS speed,
  --    tmp_table_32.direction AS direction
  -- from tmp_table_32
  -- join tmp_table_32 as `tmp_table_past_3` 
  --   on `tmp_table_past_3`.time between SUBDATE(tmp_table_32.`time`,INTERVAL 1 SECOND) and ADDDATE(tmp_table_32.`time`,INTERVAL 1 SECOND)
  -- group by 1, 2;

  -- >>>>>>>> CALCULATE SPRINT_FLAG
  SET @sprint_vel = (SELECT
    Sprint_treshold
  FROM `1_algorithm_constants`);
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

  -- >>>>>>>> INSERT CALCULATED DATA INTO "ANALYSED_DATA"
  INSERT INTO `1_analyzed_data` (ID_Participation, time, X_percent, Y_percent, delta_t, distance, speed, direction, sprint_flag, sprint_start)
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
    WHERE `magic_table_5`.ID = @new_part
  ON DUPLICATE KEY UPDATE X_percent = @a1, Y_percent = @a2, delta_t = @a3, distance = @a4, speed = @a5, direction = @a6, sprint_flag = @a7, sprint_start = @a8;

  INSERT INTO `1_analyzed_data_backup` (ID_Participation, time, X_percent, Y_percent, delta_t, distance, speed, direction, sprint_flag, sprint_start)
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
    WHERE `magic_table_5`.ID = @new_part
  ON DUPLICATE KEY UPDATE X_percent = @a1, Y_percent = @a2, delta_t = @a3, distance = @a4, speed = @a5, direction = @a6, sprint_flag = @a7, sprint_start = @a8;

  -- >>>>>>>> STATS
  INSERT INTO `12_physical_stats` (ID_Participation, max_speed, avg_speed, distance, percent_running, time_played, sprints)
    SELECT
      `21_participations`.ID_Participation AS ID_Participation,
      @f1 := MAX(speed) AS max_speed,
      @f2 := AVG(speed) AS avg_speed,
      @f3 := SUM(distance / 1000) AS distance,
      @f4 := SUM(IF(speed >= (SELECT
        percent_running_treshold
      FROM `1_algorithm_constants`), delta_t, NULL)) / SUM(delta_t) AS percent_running,
      @f5 := ROUND(SUM(delta_t) / 60, 0) AS time_played,
      @f6 := SUM(`1_analyzed_data`.sprint_start) AS sprints
    FROM `1_analyzed_data`
      INNER JOIN `21_participations`
        ON `21_participations`.ID_Participation = `1_analyzed_data`.ID_Participation
    WHERE `21_participations`.ID_Participation = @new_part AND X_percent >= 0 AND Y_percent >= 0 AND X_percent <= 1 AND Y_percent <= 1 AND speed <= (SELECT
      Max_allowed_speed
    FROM `1_algorithm_constants`)
    GROUP BY `21_participations`.ID_Participation
  ON DUPLICATE KEY UPDATE max_speed = @f1, avg_speed = @f2, distance = CAST(@f3 AS decimal(10, 5)), percent_running = CAST(@f4 AS decimal(10, 6)), time_played = @f5, sprints = @f6;

  -- >>>>>>>> AREAS 
  INSERT INTO `12_areas` (id_participation, defense, middle, attack)
    SELECT
      ID_Participation AS id_participation,
      @defense_1 := SUM(IF(Y_percent <= 0.33, (DISTANCE), 0)) / 1000 AS defense,
      @middle_1 := SUM(IF(Y_percent > 0.33 AND Y_percent < 0.66, (DISTANCE), 0)) / 1000 AS middle,
      @attack_1 := SUM(IF(Y_percent >= 0.66, (DISTANCE), 0)) / 1000 AS attack
    FROM `1_analyzed_data`
    WHERE ID_Participation = @new_part AND X_percent >= 0 AND Y_percent >= 0 AND X_percent <= 1 AND Y_percent <= 1 AND speed <= (SELECT
      Max_allowed_speed
    FROM `1_algorithm_constants`)
    GROUP BY id_participation
  ON DUPLICATE KEY UPDATE defense = @defense_1, middle = @middle_1, attack = @attack_1;

  -- >>>>>>>> MAPS
  DELETE
    FROM `12_map`
  WHERE ID_Participation = @new_part;

  INSERT `12_map` (ID_Participation, X_percent, Y_percent, Map_value)
    SELECT
      `1_analyzed_data`.ID_Participation AS ID_Participation,
      @f1 := TRUNCATE(`1_analyzed_data`.X_percent * 2, 1) / 2 AS X_percent,
      @f2 := TRUNCATE(`1_analyzed_data`.Y_percent * 3, 1) / 3 AS Y_percent,
      @f3 := IF(`1_analyzed_data`.speed > (SELECT
        Map_active_speed_treshold
      FROM `1_algorithm_constants`) AND
      SUM(`1_analyzed_data`.delta_t) > 60 * `12_physical_stats`.time_played
      / (SELECT
        Map_Y_grid_size
      FROM `1_algorithm_constants`) / (SELECT
        Map_X_grid_size
      FROM `1_algorithm_constants`) * (SELECT
        Map_value_treshold
      FROM `1_algorithm_constants`), 1, NULL) AS Map_value
    FROM `1_analyzed_data`
      INNER JOIN `12_physical_stats`
        ON `1_analyzed_data`.ID_Participation = `12_physical_stats`.ID_Participation
      INNER JOIN `21_participations`
        ON `12_physical_stats`.ID_Participation = `21_participations`.ID_Participation
    WHERE `1_analyzed_data`.ID_Participation = @new_part AND `1_analyzed_data`.X_percent >= 0 AND `1_analyzed_data`.Y_percent >= 0 AND `1_analyzed_data`.X_percent <= 1 AND `1_analyzed_data`.Y_percent <= 1 AND `1_analyzed_data`.speed <= (SELECT
      Max_allowed_speed
    FROM `1_algorithm_constants`)
    GROUP BY TRUNCATE(`1_analyzed_data`.X_percent * 2, 1) / 2,
             TRUNCATE(`1_analyzed_data`.Y_percent * 3, 1) / 3,
             `1_analyzed_data`.ID_Participation
    HAVING Map_value = 1
    ORDER BY ID_Participation, X_percent, Y_percent
  ON DUPLICATE KEY UPDATE X_percent = @f1, Y_percent = @f2, Map_value = @f3;

  -- >>>>>>>> DIRECTIONS
  INSERT `12_directions` (id_participation, up, up_right, `right`, down_right, down, down_left, `left`, up_left)
    SELECT
      ID_Participation AS id_participation,
      @h1 := SUM(IF(direction >= 337.5 OR direction < 22.5, (DISTANCE), 0)) / 1000 * 0.5 AS up,
      @h2 := SUM(IF(direction >= 22.5 AND direction < 67.5, (DISTANCE), 0)) / 1000 * 0.5 AS up_rigth,
      @h3 := SUM(IF(direction >= 67.5 AND direction < 112.5, (DISTANCE), 0)) / 1000 * 0.5 AS rigth,
      @h4 := SUM(IF(direction >= 112.5 AND direction < 157.5, (DISTANCE), 0)) / 1000 * 0.5 AS down_right,
      @h5 := SUM(IF(direction >= 157.5 AND direction < 202.5, (DISTANCE), 0)) / 1000 * 0.5 AS down,
      @h6 := SUM(IF(direction >= 202.5 AND direction < 247.5, (DISTANCE), 0)) / 1000 * 0.5 AS down_left,
      @h7 := SUM(IF(direction >= 247.5 AND direction < 292.5, (DISTANCE), 0)) / 1000 * 0.5 AS `left`,
      @h8 := SUM(IF(direction >= 292.5 AND direction < 337.5, (DISTANCE), 0)) / 1000 * 0.5 AS up_left
    FROM `1_analyzed_data`
    WHERE `1_analyzed_data`.ID_Participation = @new_part AND X_percent >= 0 AND Y_percent >= 0 AND `1_analyzed_data`.X_percent <= 1 AND `1_analyzed_data`.Y_percent <= 1 AND `1_analyzed_data`.speed > (SELECT
      Sprint_treshold
    FROM `1_algorithm_constants`) AND `1_analyzed_data`.speed <= (SELECT
      Max_allowed_speed
    FROM `1_algorithm_constants`)
    GROUP BY `1_analyzed_data`.ID_Participation
  ON DUPLICATE KEY UPDATE up = @h1, up_right = @h2, `right` = @h3, down_right = @h4, down = @h5, down_left = @h6, `left` = @h7, up_left = @h8;

  -- >>>>>>>> MAGICPOINTS
  --  CREATE TEMPORARY TABLE map_value_tot
  INSERT INTO map_value_tot_1 (ID_Participation, Map_value)
    SELECT
      ID_Participation AS ID_Participation,
      COUNT(Map_value) AS Map_value
    FROM `12_map`
    WHERE `12_map`.ID_Participation = @new_part
    GROUP BY ID_Participation;

  INSERT `12_magicpoints` (ID_Participation, magicpoints, tactic_zones, field_ocupation, game_style)
    SELECT
      `21_participations`.ID_Participation AS ID,
      @f1 := (SELECT
        Scale_Magicpoints_per_game
      FROM `1_algorithm_constants`) / 5 *
      (`12_physical_stats`.max_speed / (SELECT
        Scale_Magicpoints_max_speed
      FROM `1_algorithm_constants`) + `12_physical_stats`.avg_speed / (SELECT
        Scale_Magicpoints_avg_speed
      FROM `1_algorithm_constants`) + `12_physical_stats`.sprints / (SELECT
        Scale_Magicpoints_sprints
      FROM `1_algorithm_constants`) + `12_physical_stats`.distance / (SELECT
        Scale_Magicpoints_distance
      FROM `1_algorithm_constants`) + `12_physical_stats`.percent_running / (SELECT
        Scale_Magicpoints_percentage_running
      FROM `1_algorithm_constants`)) AS magicpoints,
      @f2 := (`12_areas`.defense + `12_areas`.middle + `12_areas`.attack) / 3 AS tactic_zones,
      @f3 := `map_value_tot_1`.Map_value AS field_ocupation,
      @f4 := `12_physical_stats`.sprints / 100 + `12_physical_stats`.distance / 5 AS game_style
    FROM `21_participations`
      INNER JOIN `1_analyzed_data`
        ON `1_analyzed_data`.ID_Participation = `21_participations`.ID_Participation
      INNER JOIN `12_physical_stats`
        ON `12_physical_stats`.ID_Participation = `21_participations`.ID_Participation
      INNER JOIN `12_areas`
        ON `12_areas`.id_participation = `21_participations`.ID_Participation
      INNER JOIN `map_value_tot_1`
        ON `map_value_tot_1`.ID_Participation = `21_participations`.ID_Participation
    WHERE `1_analyzed_data`.ID_Participation = @new_part
    GROUP BY `21_participations`.ID_Participation
  ON DUPLICATE KEY UPDATE magicpoints = @f1, tactic_zones = @f2, field_ocupation = @f3, game_style = @f4;

  -- >>>>>>>> PLAYER TOTALS
  SET @player = (SELECT
    `21_participations`.ID_player
  FROM `21_participations`
  WHERE `21_participations`.ID_Participation = @new_part);

  INSERT `12_player_totals` (ID_player, Total_goals, Total_points, Total_won_cups, Total_won_medals)
    SELECT
      `21_participations`.ID_player AS ID_player,
      @f1 := SUM(`21_participations`.my_goals) AS Total_goals,
      @f2 := SUM(`12_magicpoints`.magicpoints) AS Total_points,
      @f3 := 0 AS Total_won_cups,
      @f4 := 0 AS Total_won_medals
    FROM `21_participations`
      INNER JOIN `12_magicpoints`
        ON `12_magicpoints`.ID_Participation = `21_participations`.ID_Participation
    WHERE ID_player = @player
    GROUP BY `21_participations`.ID_player
  ON DUPLICATE KEY UPDATE Total_goals = @f1, Total_points = @f2;

  -- >>>>>>>> REARANGE DATA
  UPDATE `21_participations` SET status = 1 WHERE ID_Participation = @new_part;


  -- SELECT ID_player INTO check_part FROM `21_participations` WHERE ID_Participation=@new_part;

  DELETE
    FROM `1_analyzed_data`
  WHERE ID_Participation = @new_part;

  -- INSERT INTO `0_positions_backup`
  --  SELECT * FROM `0_positions`
  -- WHERE ID_Participation = @new_part;

  -- DELETE FROM `0_positions`
  -- WHERE ID_Participation = @new_part;

  DELETE
    FROM magic_table_1
  WHERE ID = @new_part;
  DELETE
    FROM magic_table_2
  WHERE ID = @new_part;
  DELETE
    FROM magic_table_3
  WHERE ID = @new_part;
  DELETE
    FROM magic_table_4
  WHERE ID = @new_part;
  DELETE
    FROM magic_table_5
  WHERE ID = @new_part;
  DELETE
    FROM map_value_tot_1
  WHERE ID_Participation = @new_part;

END $$
DELIMITER ;
