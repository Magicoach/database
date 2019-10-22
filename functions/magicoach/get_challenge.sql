DELIMITER $$
CREATE FUNCTION `get_challenge`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT c.type from `2_challenges` c WHERE (c.id_participation_challenged = id_participation AND id_participation_challenger IS NOT NULL) OR
                                                            (c.id_participation_challenger = id_participation AND id_participation_challenged IS NOT NULL));
	RETURN IFNULL(@result, 'No');
END $$
DELIMITER ;
