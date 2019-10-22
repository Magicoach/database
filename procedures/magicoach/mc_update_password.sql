DELIMITER $$
CREATE PROCEDURE `mc_update_password`(IN email varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SET @email = REPLACE(LOWER(email), ' ' ,'');
  SET @new_password = (SELECT LEFT(MD5(UUID()), 8));

  IF is_active_user_by_email(@email) THEN
    SET @id_user = get_user_by_email(@email);
    UPDATE `3_users_password` up SET up.`password` = @new_password WHERE up.ID = @id_user;
    CALL mc_send_email(@email, email_subject_new_password(), email_message_new_password(@email, @new_password));
    SELECT '0' AS 'return';
  ELSE
    CALL __force_an_error();
  END IF;

  COMMIT;
END $$
DELIMITER ;
