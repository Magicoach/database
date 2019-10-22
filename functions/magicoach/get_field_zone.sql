DELIMITER $$
CREATE FUNCTION `get_field_zone`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN

	SET @result = (SELECT CASE
		WHEN `a`.`defense` = (SELECT GREATEST(`a`.`defense`, `a`.`middle`, `a`.`attack`)) THEN 'Defender'
		WHEN `a`.`middle` = (SELECT GREATEST(`a`.`defense`, `a`.`middle`, `a`.`attack`)) THEN 'Midfielder'
        WHEN `a`.`attack` = (SELECT GREATEST(`a`.`defense`, `a`.`middle`, `a`.`attack`)) THEN 'Attacker'
        END
        FROM `12_areas` `a`
        WHERE a.ID_Participation = id_participation);

	RETURN @result;
END $$
DELIMITER ;
