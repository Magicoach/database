DELIMITER $$
CREATE PROCEDURE `mc_get_active_challenges`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT
      '1' AS 'return';
  END;
  START TRANSACTION;

    IF is_active_user(id_user) THEN
      SELECT
        c.ID_Challenge AS id_challenge,
        c.id_challenger,
        c.id_challenged,
        c.id_participation_challenger,
        c.id_participation_challenged,
        c.`type`,
        c.`date`,
        (SELECT
            u.username
          FROM `3_users` u
          WHERE u.ID = c.id_challenger) AS username_challenger,
        (SELECT
            u.image
          FROM `3_users` u
          WHERE u.ID = c.id_challenger) AS image_challenger,
        (SELECT
            p.time_start
          FROM `21_participations` p
          WHERE p.ID_Participation = id_participation_challenger) AS time_challenger,
        (SELECT
            u.username
          FROM `3_users` u
          WHERE u.ID = c.id_challenged) AS username_challenged,
        (SELECT
            u.image
          FROM `3_users` u
          WHERE u.ID = c.id_challenged) AS image_challenged,
        (SELECT
            p.time_start
          FROM `21_participations` p
          WHERE p.ID_Participation = id_participation_challenged) AS time_challenged
      FROM `2_challenges` c
        JOIN `3_users` u
          ON u.ID = id_user
      WHERE c.visible = 1 AND ((c.id_challenger = id_user AND c.id_participation_challenger IS NULL)
        OR (c.id_challenged = id_user AND c.id_participation_challenged IS NULL))
      ORDER BY c.ID_Challenge DESC;
    ELSE
      CALL __force_an_error();
    END IF;

  COMMIT;
END $$
DELIMITER ;
