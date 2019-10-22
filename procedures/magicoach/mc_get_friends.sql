DELIMITER $$
CREATE PROCEDURE `mc_get_friends`(id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    DROP TEMPORARY TABLE IF EXISTS friends;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  IF (id_user=-100) THEN set @activestatus = 2; ELSE set @activestatus = 1; END IF;

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
      AND u1.active =  @activestatus
      AND u2.active =  @activestatus
      AND i.accepted_date IS NOT NULL);

    SELECT
      f.id_friend AS id,
      f.friend_username AS username,
      f.friend_image AS image,
      IFNULL(SUM(m.magicpoints), 0) AS magicpoints
    FROM `21_participations` p
      JOIN `12_magicpoints` m
        ON m.ID_Participation = p.ID_Participation
      JOIN friends f
        ON f.id_friend = p.ID_player
      JOIN `21_field_coordinates` fc ON fc.ID_Field = p.ID_Field
    WHERE fc.ID_Field > 0 AND YEAR(p.time_start) >= '2016' AND m.magicpoints > 0
    GROUP BY f.id_friend
    ORDER BY f.friend_username ASC;


    -- Temporary table is automatically dropped ONLY when the session is closed.
    DROP TEMPORARY TABLE IF EXISTS friends;

  COMMIT;
END $$
DELIMITER ;
