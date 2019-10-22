DELIMITER $$
CREATE FUNCTION `get_medal`(`value` DOUBLE PRECISION, category TEXT) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN

	SET @result = (SELECT CASE
		WHEN IFNULL(`value`, 0) >= pl.bronze AND IFNULL(`value`, 0) < pl.silver THEN 'bronze'
		WHEN IFNULL(`value`, 0) >= pl.silver AND IFNULL(`value`, 0) < pl.gold THEN 'silver' 
        WHEN IFNULL(`value`, 0) >= pl.gold THEN 'gold' ELSE 'none' END
	FROM `2_performance_levels` pl
	WHERE pl.category = category);
    
    RETURN @result;
END $$
DELIMITER ;
