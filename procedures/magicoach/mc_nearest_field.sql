DELIMITER $$
CREATE PROCEDURE `mc_nearest_field`(IN latitude double PRECISION, IN longitude double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  -- Find the closest field 300 meters
  SET @search_radius = 300;
   
  -- CONSTANTS
  SET @EARTH_MILES_DEGREE = 69; -- miles per degree (avr)
  SET @EARTH_RADIUS_MILES = 3959;
  SET @MILES_TO_M = 1609.344;
  SET @M_TO_MILES = 0.00062137;

  -- Rectangle to reduce the search area. 
  -- '69' is an average value for lat/lon.
  SET @dist = @search_radius * @M_TO_MILES;
  SET @lon1 = longitude - (@dist / (COS(RADIANS(latitude)) * @EARTH_MILES_DEGREE));
  SET @lon2 = longitude + (@dist / (COS(RADIANS(latitude)) * @EARTH_MILES_DEGREE));
  SET @lat1 = latitude - (@dist / 69);
  SET @lat2 = latitude + (@dist / 69);

  -- distance: Haversine Formula
DROP TABLE IF EXISTS tmp_field;
CREATE TEMPORARY TABLE tmp_field (SELECT
    fc.ID_Field AS field_id,
    fc.Field_name AS `field_name`,
    fc.typical_team_size AS `field_size`,
    ROUND(@EARTH_RADIUS_MILES * 2 * ASIN(SQRT(POWER(SIN((latitude - fc.Lat_avg) * PI() / 180 / 2), 2) +
    COS(latitude * PI() / 180) * COS(fc.Lat_avg * PI() / 180) *
    POWER(SIN((longitude - fc.Long_avg) * PI() / 180 / 2), 2))) * @MILES_TO_M, 1) AS `distance`
  FROM `21_field_coordinates` fc
  WHERE fc.ID_Field > 0 AND  -- fc.Field_name NOT LIKE "%Tiny%" AND fc.Field_name NOT LIKE "%Small%" AND fc.Field_name NOT LIKE "%auto%" AND fc.Field_name NOT LIKE "%test%" AND
    fc.Long_avg BETWEEN @lon1 AND @lon2 AND
    fc.Lat_avg BETWEEN @lat1 AND @lat2
  HAVING `distance` < @dist * @MILES_TO_M
  ORDER BY `distance` ,  fc.ID_Field
  LIMIT 1) ;
 
 SELECT IFNULL((SELECT field_id FROM tmp_field), 121) AS `field_id`, 
     "yet to be validated" AS `field_name`,
    "0" AS `field_size`,
  0 AS distance;

 COMMIT;
END $$
DELIMITER ;
