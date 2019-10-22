DELIMITER $$
CREATE PROCEDURE `mc_notifications`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    DROP TEMPORARY TABLE IF EXISTS friends;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

    CREATE TEMPORARY TABLE IF NOT EXISTS friends AS (SELECT
        u1.ID AS id_user,
        u2.ID AS id_friend,
        u2.username AS friend_username,
        u2.image AS friend_image
      FROM `3_users_invitations` i
        JOIN `3_users` u1
          ON (u1.ID = i.id_sender
          OR u1.ID = i.id_receiver)
        JOIN `3_users` u2
          ON (u2.ID = i.id_receiver
          OR u2.ID = i.id_sender)
          AND u1.ID <> u2.ID
      WHERE u1.ID = id_user
      AND u1.active = 1
      AND u2.active = 1
      AND i.accepted_date IS NOT NULL);

    SELECT
      p.ID_Participation AS id_participation,
      f.id_friend,
      f.friend_username,
      f.friend_image,
      p.time_start,
      fc.typical_team_size,
      fc.Field_name AS field_name,
      p.my_goals,
      m.magicpoints
    FROM `21_participations` p
      JOIN `21_field_coordinates` fc
        ON fc.ID_Field = p.ID_Field
      JOIN `12_magicpoints` m
        ON m.ID_Participation = p.ID_Participation
      JOIN friends f
        ON f.id_friend = p.ID_player
    WHERE fc.ID_Field > 0 AND m.magicpoints > 0
    ORDER BY p.time_start DESC
    LIMIT 13;

    -- Temporary table is automatically dropped ONLY when the session is closed.
    DROP TEMPORARY TABLE IF EXISTS friends;

  COMMIT;
END $$
DELIMITER ;
