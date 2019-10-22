DELIMITER $$
CREATE PROCEDURE `0_send_mass_emails`() 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE done BOOLEAN DEFAULT FALSE;
  DECLARE _id BIGINT UNSIGNED;
  DECLARE cur CURSOR FOR SELECT id FROM `3_users` ORDER by date_created DESC Limit 42;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;

  OPEN cur;

  testLoop: LOOP
    FETCH cur INTO _id;
    IF done THEN
      LEAVE testLoop;
    END IF;
    DO sleep(10); 
    set @email = (select email from `3_users` where `id` = _id);
    CALL mc_send_email(@email, 'You can now play with any GPS - Magicoach joins Strava', email_message_strava_intro(_id));
  END LOOP testLoop;

  CLOSE cur;


END $$
DELIMITER ;
