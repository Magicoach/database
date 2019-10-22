DELIMITER $$
CREATE PROCEDURE `mc_register_user`(IN email varchar(255), IN `username` varchar(255), IN `password` varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SET @email = REPLACE(LOWER(email), ' ' ,'');
  
  IF NOT is_user_by_email(@email) THEN
    -- New user.
    INSERT INTO `3_users` (email, username, date_created, active) VALUES (@email, `username`, NOW(), 1);
    SET @id_user = get_user_by_email(@email);
    INSERT INTO `3_users_password` (ID, `password`, `date`) VALUES (@id_user, `password`, NOW());
    INSERT INTO `3_users_permissions` (user_id, full_access) VALUES (@id_user, 0);

    -- Default Friends: Br87 and James Nathan.
    INSERT INTO `3_users_invitations`(id_sender, id_receiver, `date`, `accepted_date`) VALUES (10350, @id_user, NOW(), NOW());
    INSERT INTO `3_users_invitations`(id_sender, id_receiver, `date`, `accepted_date`) VALUES (10043, @id_user, NOW(), NOW());
    
    CALL mc_send_email(@email, email_subject_welcome(), email_message_welcome(`username`));
    CALL mc_send_email(@email, 'You can now play with any GPS - Magicoach joins Strava', email_message_strava_intro(@id_user));
    CALL mc_send_email('support@magicoach.com', email_subject_new_user(), email_message_new_user(@email));
        
    CALL mc_get_basic_profile(@id_user);
  ELSE
    CALL __force_an_error(); -- Email already exists.
  END IF;

  COMMIT;
END $$
DELIMITER ;
