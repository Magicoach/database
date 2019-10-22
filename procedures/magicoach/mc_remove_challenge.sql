DELIMITER $$
CREATE PROCEDURE `mc_remove_challenge`(IN id_challenge int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;
  
  UPDATE `2_challenges` c SET c.visible = 0 WHERE c.ID_Challenge = id_challenge;

  SELECT '0' AS 'return';
  COMMIT;
END $$
DELIMITER ;
