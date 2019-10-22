DELIMITER $$
CREATE PROCEDURE `mc_calculate_participation_noemail`(IN id_participation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    CALL mc_send_email('support@magicoach.com', email_subject_invalid_calculate(), email_message_invalid_calculate(id_participation));
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

    SET @id_user = (SELECT
        p.ID_player
      FROM `21_participations` p
      WHERE p.ID_Participation = id_participation);
    SET @username = (SELECT
        u.username
      FROM `3_users` u
      WHERE u.ID = @id_user);
    SET @email = (SELECT
        u.email
      FROM `3_users` u
      WHERE u.ID = @id_user);
    SET @field_name = (SELECT
        fc.Field_name
      FROM `21_participations` p
        JOIN `21_field_coordinates` fc
          ON fc.ID_Field = p.ID_Field
      WHERE p.ID_Participation = id_participation);

    IF has_positions(id_participation) THEN
      IF is_unknown_field(id_participation) THEN
        CALL mc_send_email('support@magicoach.com', email_subject_new_field(), email_message_new_field(@email, id_participation));
      ELSE
        CALL calculate_part_all4(id_participation);
        CALL mc_ratings_participation(id_participation);
        CALL mc_send_email('support@magicoach.com', email_subject_calculate(@username, @field_name), email_message_calculate(id_participation));
       -- CALL mc_send_email(@email, email_subject_calculate_for_users(), email_message_calculate_for_users(id_participation));
      END IF;

      SELECT '0' AS 'return';
    ELSE
      CALL __force_an_error();
    END IF;

  COMMIT;
END $$
DELIMITER ;
