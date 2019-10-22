DELIMITER $$
CREATE PROCEDURE `calculate_automatic_field_for_test`() 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SET @id_participation = 5310;

  SET @sum = 0;
  SET @total_positions = (SELECT COUNT(*) FROM `0_positions` p WHERE p.ID_Participation = @id_participation);
  SET @center_latitude = (
  SELECT
    AVG(p2.latitude)
  FROM `0_positions` p2
    JOIN (SELECT
          p.time AS time,
          p.latitude AS latitude,
          p.longitude AS longitude,
          @sum := @sum + 100 / @total_positions AS percentage -- filter initial and final positions
        FROM `0_positions` p
        WHERE p.ID_Participation = @id_participation
        GROUP BY percentage
        HAVING percentage > 20
        AND percentage < 60) AS filter
        ON filter.time = p2.time
  WHERE p2.ID_Participation = @id_participation
  GROUP BY p2.ID_Participation);

  SET @sum = 0;
  SET @total_positions = (SELECT COUNT(*) FROM `0_positions` p WHERE p.ID_Participation = @id_participation);
  SET @center_longitude = (
  SELECT
    AVG(p2.longitude)
  FROM `0_positions` p2
    JOIN (SELECT
          p.time AS time,
          p.latitude AS latitude,
          p.longitude AS longitude,
          @sum := @sum + 100 / @total_positions AS percentage -- filter initial and final positions
        FROM `0_positions` p
        WHERE p.ID_Participation = @id_participation
        GROUP BY percentage
        HAVING percentage > 20
        AND percentage < 60) AS filter
        ON filter.time = p2.time
  WHERE p2.ID_Participation = @id_participation
  GROUP BY p2.ID_Participation);

 -- SET @center_latitude = 38.72589;
 -- SET @center_longitude = -9.209841;
  -- CALL central_position_field(@id_participation);
  -- ------------------------------------------

  -- average value for lat/lon.
  SET @EARTH_MILES_DEGREE = 69; 
  SET @M_TO_MILES = 0.00062137;

  -- one big virtual field 200x200 where center is at [center_latitude, center_longitude].
  SET @base_field_size = 200;
  SET @radius = SQRT(POWER(@base_field_size/2, 2) + POWER(@base_field_size/2, 2));
  SET @dist = @radius * @M_TO_MILES;
  SET @lon1 = @center_longitude - (@dist / (COS(RADIANS(@center_latitude)) * @EARTH_MILES_DEGREE));
  SET @lon2 = @center_longitude + (@dist / (COS(RADIANS(@center_latitude)) * @EARTH_MILES_DEGREE));
  SET @lon3 = @center_longitude + (@dist / (COS(RADIANS(@center_latitude)) * @EARTH_MILES_DEGREE));
  SET @lat1 = @center_latitude - (@dist / @EARTH_MILES_DEGREE);
  SET @lat2 = @center_latitude - (@dist / @EARTH_MILES_DEGREE);
  SET @lat3 = @center_latitude + (@dist / @EARTH_MILES_DEGREE);

  -- calculate field coordinates for 200x200.
  UPDATE `dev_field_coordinates` fc SET 
    fc.Lat_esq_baliza1 = @lat1,
    fc.Long_esq_baliza1 = @lon1,
    fc.Lat_dir_baliza1 = @lat2,
    fc.Long_dir_baliza1 = @lon2,
    fc.Lat_esq_baliza2 = @lat3,
    fc.Long_esq_baliza2 = @lon3,
    fc.Lat_avg = @center_latitude,
    fc.Long_avg = @center_longitude,
    fc.date_created = NOW()
    WHERE fc.ID_Field = 0;

  -- create smaller virtual fields, diff sizes and rotations. JUST FOR INITIAL TESTS TABLES
/*  DELETE FROM dev_field_sizes3;
  SET @width = 110;
  SET @angle = 90;
  WHILE @angle >= -90 DO
    WHILE @width >= 30 DO
      INSERT INTO dev_field_sizes3 VALUES (@width, @width * 0.5, @angle);
      INSERT INTO dev_field_sizes3 VALUES (@width, @width * 0.6, @angle);
      INSERT INTO dev_field_sizes3 VALUES (@width, @width * 0.7, @angle);
      INSERT INTO dev_field_sizes3 VALUES (@width, @width * 0.8, @angle);
      SET @width = @width - 5;
    END WHILE;
    SET @width = 110;
    SET @angle = @angle - 10;
  END WHILE;
*/

-- SIMPLIFIED VERSION OF CALCULATE (JUST ANALYSED DATA)
 CALL calculate_part_all4_dev(@id_participation);

SET @real_base_field_dimension = (SELECT X_dir_baliza1 FROM dev_field_dimensions WHERE ID_Field = 0) ; -- correction needed!

-- ADAPT ALL BASIC FIELDS TO CURRENT FIELDS (MULTIPLE FIELD CONSTRUCTION)
 TRUNCATE TABLE `dev_analyzed_fields`;
 INSERT INTO `dev_analyzed_fields` (id, width, height, rotation, x_rotation, y_rotation, inside) 
  SELECT
    a.ID_Participation AS id,
    c.width AS width,
    c.height AS height,
    c.rotation AS rotation,
    @x := (a.X_percent-0.5)*COS(RADIANS(c.rotation)) - (a.Y_percent-0.5)*SIN(RADIANS(c.rotation))+0.5 AS x_rotation,
    @y := (a.Y_percent-0.5)*COS(RADIANS(c.rotation)) + (a.X_percent-0.5)*SIN(RADIANS(c.rotation))+0.5 AS y_rotation,
    IF(@x BETWEEN (0.5 - (c.width/@real_base_field_dimension)/2) AND (0.5 + (c.width/@real_base_field_dimension)/2) AND 
      @y BETWEEN (0.5 - (c.height/@real_base_field_dimension)/2) AND (0.5 + (c.height/@real_base_field_dimension)/2), 1 ,0) AS inside
    FROM `dev_analyzed_data_backup` a
    JOIN dev_field_sizes4 c
    WHERE a.ID_Participation = @id_participation 
    --  AND a.speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`)
    GROUP BY c.width,
             c.height,
             c.rotation,
              a.time;
            -- (a.X_percent-0.5)*COS(RADIANS(c.rotation)) - (a.Y_percent-0.5)*SIN(RADIANS(c.rotation))+0.5,
            -- (a.Y_percent-0.5)*COS(RADIANS(c.rotation)) + (a.X_percent-0.5)*SIN(RADIANS(c.rotation))+0.5;


   -- FIND NEW FIELD ROTATION 
SET @new_rotation = 
 (  SELECT
    daf.rotation
    FROM dev_analyzed_fields daf
    WHERE daf.id = 5311
    GROUP BY CONCAT(concat(daf.width, daf.height), daf.rotation)
    ORDER BY POWER(SUM(daf.inside)/count(daf.inside)*100,5)/(daf.width * daf.height)  DESC
    LIMIT 1);

 -- FIND NEW FIELD WIDTH 
SET @new_width = (
  SELECT
    daf.width
    FROM dev_analyzed_fields daf
    WHERE daf.id = 5311
    GROUP BY CONCAT(concat(daf.width, daf.height), daf.rotation)
    ORDER BY POWER(SUM(daf.inside)/count(daf.inside)*100,5)/(daf.width * daf.height)  DESC
    LIMIT 1);

 -- FIND NEW FIELD HEIGHT  
SET @new_height = (  SELECT
    daf.height
    FROM dev_analyzed_fields daf
    WHERE daf.id = 5311
    GROUP BY CONCAT(concat(daf.width, daf.height), daf.rotation)
    ORDER BY POWER(SUM(daf.inside)/count(daf.inside)*100,5)/(daf.width * daf.height)  DESC
    LIMIT 1);

   -- FIND NEW FIELD ROTATION OLF METHOD
--   SELECT
--    daf.width,
--    daf.height,
--  (daf.width * daf.height),
--    daf.rotation,
--  SUM(daf.inside)/count(daf.inside)*100 AS inside_perce,
--    SUM(daf.inside) AS inside,
--      count(daf.inside) AS tot,
--    POWER(SUM(daf.inside)/count(daf.inside)*100,5),
--    (daf.width * daf.height) / SUM(daf.inside) AS density,
--    POWER(SUM(daf.inside)/count(daf.inside)*100,5)/(daf.width * daf.height) AS INDEX_finder
--    FROM dev_analyzed_fields daf
--    WHERE daf.id =  @id_participation
--    GROUP BY daf.width, daf.height, daf.rotation
--    ORDER BY (daf.width * daf.height) / SUM(daf.inside) DESC;

SET @Distance_to_corners = SQRT(POWER(@new_height/2,2)+POWER(@new_width/2,2))/(6.371*1000000);
  SELECT @Distance_to_corners;

SET @angle_to_corner =  180/PI()*ATAN(@new_width/@new_height);

SET @Lat_esq_baliza1 = 180/PI()*asin(sin(RADIANS(@center_latitude))*cos(@Distance_to_corners)+cos(RADIANS(@center_latitude))*sin(@Distance_to_corners)*cos(RADIANS(@new_rotation-180+@angle_to_corner)));
set @Long_esq_baliza1 = 180/PI()*(RADIANS(@center_longitude) + atan2(sin(RADIANS(@new_rotation-180+@angle_to_corner))*sin(@Distance_to_corners)*cos(RADIANS(@center_latitude)),cos(@Distance_to_corners)-sin(RADIANS(@center_latitude))*sin(RADIANS(@Lat_esq_baliza1))));
SET @Lat_dir_baliza1 = 180/PI()*asin(sin(RADIANS(@center_latitude))*cos(@Distance_to_corners)+cos(RADIANS(@center_latitude))*sin(@Distance_to_corners)*cos(RADIANS(@new_rotation+180-@angle_to_corner)));
set @Long_dir_baliza1 = 180/PI()*(RADIANS(@center_longitude) + atan2(sin(RADIANS(@new_rotation+180-@angle_to_corner))*sin(@Distance_to_corners)*cos(RADIANS(@center_latitude)),cos(@Distance_to_corners)-sin(RADIANS(@center_latitude))*sin(RADIANS(@Lat_dir_baliza1))));
SET @Lat_esq_baliza2 = 180/PI()*asin(sin(RADIANS(@center_latitude))*cos(@Distance_to_corners)+cos(RADIANS(@center_latitude))*sin(@Distance_to_corners)*cos(RADIANS(@new_rotation+@angle_to_corner)));
set @Long_esq_baliza2 = 180/PI()*(RADIANS(@center_longitude) + atan2(sin(RADIANS(@new_rotation+@angle_to_corner))*sin(@Distance_to_corners)*cos(RADIANS(@center_latitude)),cos(@Distance_to_corners)-sin(RADIANS(@center_latitude))*sin(RADIANS(@Lat_esq_baliza2))));

SELECT @Lat_esq_baliza1,@Long_esq_baliza1,@Lat_dir_baliza1,@Long_dir_baliza1,@Lat_esq_baliza2,@Long_esq_baliza2, @Distance_to_corners,  @new_height, @new_width, @new_rotation, @angle_to_corner;

-- INSERT INTO `21_field_coordinates` (Lat_esq_baliza1, Long_esq_baliza1, Lat_dir_baliza1, Long_dir_baliza1, Lat_esq_baliza2,  Long_esq_baliza2, typical_team_size, Field_name, Lat_avg, Long_avg, date_created)
--   VALUES (@Lat_esq_baliza1, @Long_esq_baliza1, @Lat_dir_baliza1, @Long_dir_baliza1, @Lat_esq_baliza2, @Long_esq_baliza2, 7, "auto calibrated", @center_latitude, @center_longitude, NOW());

END $$
DELIMITER ;
