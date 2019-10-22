DELIMITER $$
CREATE PROCEDURE `mc_update_challenge`(IN id_user int, IN id_challenge int, IN id_participation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SET @id_challenger = (SELECT c.id_challenger FROM `2_challenges` c WHERE c.ID_Challenge = id_challenge);
  SET @id_challenged = (SELECT c.id_challenged FROM `2_challenges` c WHERE c.ID_Challenge = id_challenge);
  SET @id_part_challenger = (SELECT c.id_participation_challenger FROM `2_challenges` c WHERE c.ID_Challenge = id_challenge);
  SET @id_part_challenged = (SELECT c.id_participation_challenged FROM `2_challenges` c WHERE c.ID_Challenge = id_challenge);

  IF is_active_user(id_user) AND @id_challenger = id_user AND @id_part_challenger IS NULL THEN
    UPDATE `2_challenges` c SET c.id_participation_challenger = id_participation WHERE c.id_challenge = id_challenge; 
  ELSEIF is_active_user(id_user) AND @id_challenged = id_user AND @id_part_challenged IS NULL THEN
    UPDATE `2_challenges` c SET c.id_participation_challenged = id_participation WHERE c.id_challenge = id_challenge;
  ELSE
    CALL __force_an_error();
  END IF;

  SELECT '0' AS 'return';
  COMMIT;
END $$
DELIMITER ;
