DELIMITER $$
CREATE PROCEDURE `mc_create_challenge`(IN id_challenger int, IN id_challenged int, IN `type` varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT
      '1' AS 'return';
  END;
  START TRANSACTION;

    IF is_active_user(id_challenger) AND is_active_user(id_challenged) THEN
      INSERT INTO `2_challenges` (id_challenger, id_challenged, id_participation_challenger, id_participation_challenged, `type`, `date`, `visible`)
        VALUES (id_challenger, id_challenged, NULL, NULL, `type`, NOW(), 1);

      SELECT MAX(c.ID_Challenge) AS id_challenge
      FROM `2_challenges` c;
    ELSE
      CALL __force_an_error();
    END IF;

  COMMIT;
END $$
DELIMITER ;
