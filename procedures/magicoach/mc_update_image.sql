DELIMITER $$
CREATE PROCEDURE `mc_update_image`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SET @email = (SELECT u.email FROM `3_users` u WHERE u.ID = id_user);
  SET @image_name = CONCAT(REPLACE(@email, '@' ,''), '.png');
  
  IF is_active_user(id_user) THEN
    UPDATE `3_users` u SET u.image = @image_name WHERE u.ID = id_user;
    SELECT '0' AS 'return';
  ELSE
    CALL __force_an_error();
  END IF;

  COMMIT;
END $$
DELIMITER ;
