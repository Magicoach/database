DELIMITER $$
CREATE PROCEDURE `mc_create_invite`(IN id_user int, IN id_user_target int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION; 
  
  IF NOT has_invite(id_user, id_user_target) THEN
    INSERT INTO `3_users_invitations`(id_sender, id_receiver, `date`) VALUES (id_user, id_user_target, NOW());
    SELECT '0' AS 'return';
  ELSE
    CALL __force_an_error();
  END IF;

  COMMIT;
END $$
DELIMITER ;
