DELIMITER $$
CREATE PROCEDURE `mc_create_participation`(IN id_field int, IN goals int, IN time_start datetime, IN time_end datetime, IN result int, IN id_user int, IN device mediumtext, IN `version` varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
	  CALL mc_send_email('support@magicoach.com', email_subject_invalid_participation(), email_message_invalid_participation(id_user, id_field, goals, result, time_start, time_end, device, `version`));
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  IF is_active_user(id_user) THEN
    INSERT INTO `21_participations` (ID_Field, ID_player, my_goals, time_start, time_end, result, `status`, device, `version`)
      VALUES (id_field, id_user, goals, time_start, time_end, result, 0, device, `version`);  
    SELECT MAX(p.ID_Participation) AS id_participation FROM `21_participations` p;
  ELSE
    CALL __force_an_error();
  END IF;

  COMMIT;
END $$
DELIMITER ;
