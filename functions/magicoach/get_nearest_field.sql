DELIMITER $$
CREATE FUNCTION `get_nearest_field`(ID_part int) RETURNS int(11) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN

   DECLARE result_field int;
   DECLARE avglat float;
   DECLARE avglon float;

  SET @sum = 0;
  SET @total_positions = (SELECT COUNT(*) FROM `0_positions` p WHERE p.ID_Participation = ID_part);

  -- TODO: remove outliers. hint: limit speed change.
  -- Don't use speed column from 0_positions. it's not accurate
  SELECT
    AVG(p2.latitude),    AVG(p2.longitude)   INTO avglat, avglon
  FROM `0_positions` p2
    JOIN (SELECT
          p.time AS time,
          p.latitude AS latitude,
          p.longitude AS longitude,
          @sum := @sum + 100 / @total_positions AS percentage -- filter initial and final positions
        FROM `0_positions` p
        WHERE p.ID_Participation = ID_part
        GROUP BY percentage
        HAVING percentage > 20
        AND percentage < 60) AS filter
        ON filter.time = p2.time
  WHERE p2.ID_Participation = ID_part
  GROUP BY p2.ID_Participation;

-- SET @avglat = (select AVG(latitude) FROM magicoach.`0_positions` WHERE ID_Participation = ID_part) ; 
-- SET @avglon = (select AVG(longitude) FROM magicoach.`0_positions` WHERE ID_Participation = ID_part) ; 

  -- Find the closest field 300 meters
  SET @search_radius = 20;
   
  -- CONSTANTS
  SET @EARTH_MILES_DEGREE = 69; -- miles per degree (avr)
  SET @EARTH_RADIUS_MILES = 3959;
  SET @MILES_TO_M = 1609.344;
  SET @M_TO_MILES = 0.00062137;

  -- Rectangle to reduce the search area. 
  -- '69' is an average value for lat/lon.
  SET @dist = @search_radius * @M_TO_MILES;
  SET @lon1 = avglon - (@dist / (COS(RADIANS(avglat)) * @EARTH_MILES_DEGREE));
  SET @lon2 = avglon + (@dist / (COS(RADIANS(avglat)) * @EARTH_MILES_DEGREE));
  SET @lat1 = avglat - (@dist / 69);
  SET @lat2 = avglat + (@dist / 69);

   -- distance: Haversine Formula
  SELECT
    fc.ID_Field INTO result_field
  FROM `21_field_coordinates` fc
  WHERE fc.ID_Field > 0 AND fc.Field_name NOT LIKE "%Tiny%" AND fc.Field_name NOT LIKE "%Small%" AND fc.Field_name NOT LIKE "%auto%" AND
    fc.Long_avg BETWEEN @lon1 AND @lon2 AND
    fc.Lat_avg BETWEEN @lat1 AND @lat2
   AND ROUND(@EARTH_RADIUS_MILES * 2 * ASIN(SQRT(POWER(SIN((avglat - fc.Lat_avg) * PI() / 180 / 2), 2) +
    COS(avglat * PI() / 180) * COS(fc.Lat_avg * PI() / 180) *
    POWER(SIN((avglon - fc.Long_avg) * PI() / 180 / 2), 2))) * @MILES_TO_M, 1) < @dist * @MILES_TO_M
  ORDER BY ROUND(@EARTH_RADIUS_MILES * 2 * ASIN(SQRT(POWER(SIN((avglat - fc.Lat_avg) * PI() / 180 / 2), 2) +
    COS(avglat * PI() / 180) * COS(fc.Lat_avg * PI() / 180) *
    POWER(SIN((avglon - fc.Long_avg) * PI() / 180 / 2), 2))) * @MILES_TO_M, 1), fc.ID_Field
    LIMIT 1;

  RETURN result_field;

END $$
DELIMITER ;
