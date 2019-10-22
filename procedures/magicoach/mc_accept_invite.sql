DELIMITER $$
CREATE PROCEDURE `mc_accept_invite`(IN id_user int, IN id_user_invitation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  IF has_invite(id_user, id_user_invitation) THEN
    UPDATE `3_users_invitations` set accepted_date = NOW() WHERE id_receiver = id_user AND id_sender = id_user_invitation;
    SELECT '0' AS 'return';
  ELSE
    CALL __force_an_error();
  END IF;

  COMMIT;
END $$
DELIMITER ;
