DELIMITER $$
CREATE PROCEDURE `mc_who_played_with_me`(IN id_participation int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT
      '1' AS 'return';
  END;
  START TRANSACTION;

    SET @id_user = (SELECT
        p.ID_player
      FROM `21_participations` p
      WHERE p.ID_Participation = id_participation);
    SET @id_field = (SELECT
        p.ID_Field
      FROM `21_participations` p
      WHERE p.ID_Participation = id_participation);
    SET @time_start = (SELECT
        p.time_start
      FROM `21_participations` p
      WHERE p.ID_Participation = id_participation);
    SET @time_end = (SELECT
        p.time_end
      FROM `21_participations` p
      WHERE p.ID_Participation = id_participation);

    IF is_active_user(@id_user) THEN
      SELECT
        u.username,
        u.image,
        get_game_style_sprints(p.ID_Participation) AS game_style_sprints_x,
        get_game_style_distance(p.ID_Participation) AS game_style_distance_y
      FROM `21_participations` p
        JOIN `3_users` u
          ON u.ID = p.ID_player
        JOIN `12_physical_stats` ps
          ON ps.ID_Participation = p.ID_Participation
      WHERE u.ID <> @id_user
      AND p.ID_Field = @id_field
      AND u.active = 1
      AND @time_start <= p.time_end
      AND @time_end >= p.time_start
      ORDER BY p.ID_Participation DESC;
    ELSE
      CALL __force_an_error();
    END IF;

  COMMIT;
END $$
DELIMITER ;
