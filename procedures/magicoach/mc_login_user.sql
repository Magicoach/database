DELIMITER $$
CREATE PROCEDURE `mc_login_user`(IN `email` varchar(255), IN `password` varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SET @email = REPLACE(LOWER(email), ' ' ,'');

  IF is_valid_login(@email, `password`) THEN
    SET @id_user = (SELECT `u`.`ID` FROM `3_users` `u` WHERE `u`.`email` = @email LIMIT 1);
    CALL mc_get_basic_profile(@id_user);
  ELSE
    CALL __force_an_error();
  END IF;

  COMMIT;
END $$
DELIMITER ;
