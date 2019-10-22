DELIMITER $$
CREATE PROCEDURE `calculate_automatic`() 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SET @id_participation = 2727;

  SET @center_latitude = 38.72589;
  SET @center_longitude = -9.209841;
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

  -- calculate field dimensions for 200x200.
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

-- ADAPT ALL BASIC FIELDS TO CURRENT FIELDS (MULTIPLE FIELD CONSTRUCTION)
 DELETE FROM `dev_analyzed_fields` WHERE id = @id_participation;
 INSERT INTO `dev_analyzed_fields` (id, width, height, rotation, x_rotation, y_rotation, inside) 
  SELECT
    a.ID_Participation AS id,
    c.width AS width,
    c.height AS height,
    c.rotation AS rotation,
    @x := (a.X_percent-0.5)*COS(RADIANS(c.rotation)) - (a.Y_percent-0.5)*SIN(RADIANS(c.rotation))+0.5 AS x_rotation,
    @y := (a.Y_percent-0.5)*COS(RADIANS(c.rotation)) + (a.X_percent-0.5)*SIN(RADIANS(c.rotation))+0.5 AS y_rotation,
    IF(@x BETWEEN (0.5 - (c.width/@base_field_size)/2) AND (0.5 + (c.width/@base_field_size)/2) AND 
      @y BETWEEN (0.5 - (c.height/@base_field_size)/2) AND (0.5 + (c.height/@base_field_size)/2), 1 ,0) AS inside
    FROM `dev_analyzed_data_backup` a
    JOIN dev_field_sizes4 c
    WHERE a.ID_Participation = @id_participation 
   -- AND    a.speed <= (SELECT Max_allowed_speed FROM `1_algorithm_constants`)
    GROUP BY c.width,
             c.height,
             c.rotation, 
             (a.X_percent-0.5)*COS(RADIANS(c.rotation)) - (a.Y_percent-0.5)*SIN(RADIANS(c.rotation))+0.5,
             (a.Y_percent-0.5)*COS(RADIANS(c.rotation)) + (a.X_percent-0.5)*SIN(RADIANS(c.rotation))+0.5;

  -- FIELD CLASSIFICATION
  SELECT
    daf.width,
    daf.height,
    daf.rotation,
    (daf.width * daf.height) / SUM(daf.inside) AS density
    FROM dev_analyzed_fields daf
    WHERE daf.id = @id_participation
    GROUP BY daf.width, daf.height, daf.rotation
    ORDER BY (daf.width * daf.height) / SUM(daf.inside) DESC;

END $$
DELIMITER ;
