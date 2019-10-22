DELIMITER $$
CREATE PROCEDURE `mc_ranking_distance`(IN id_user int, IN date_start datetime, IN date_end datetime, IN order_by varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  -- CALL mc_ranking_distance(10043, '2014.01.01 10:00:00', '2017.01.01 10:00:00', 'max');

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    GET DIAGNOSTICS CONDITION 1 
    @errno = MYSQL_ERRNO, 
    @text = MESSAGE_TEXT; 
    ROLLBACK;
    DROP TEMPORARY TABLE IF EXISTS ranks;
    DROP TEMPORARY TABLE IF EXISTS ranking;
    DROP TEMPORARY TABLE IF EXISTS friends;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

 IF (id_user=-100) THEN set @activestatus = 2; ELSE set @activestatus = 1; END IF;


    CREATE TEMPORARY TABLE IF NOT EXISTS friends AS (SELECT
        u2.ID AS id_friend
      FROM `3_users_invitations` i
        JOIN `3_users` u1
          ON (u1.ID = i.id_sender
          OR u1.ID = i.id_receiver)
        JOIN `3_users` u2
          ON (u2.ID = i.id_receiver
          OR u2.ID = i.id_sender)
          AND u1.ID <> u2.ID
      WHERE u1.ID = id_user
      AND u2.active = @activestatus
      AND i.accepted_date IS NOT NULL
      GROUP by u2.ID);

    CREATE TEMPORARY TABLE IF NOT EXISTS ranking AS (SELECT
        u.ID,
        u.username,
        u.image,
        ROUND(SUM(ps.`distance`), 1) AS `sum`,
        ROUND(AVG(ps.distance), 1) AS `avg`,
        ROUND(MAX(ps.`distance`), 1) AS `max`,
        IFNULL((SELECT IF(friends.id_friend IS NULL, 0, 1) FROM friends WHERE friends.id_friend = u.ID), 0) AS is_friend
      FROM `21_participations` p
        JOIN `12_physical_stats` ps
          ON p.ID_Participation = ps.ID_Participation
        JOIN `12_magicpoints` m
          ON ps.ID_Participation = m.ID_Participation
        JOIN `3_users` u
          ON u.ID = p.ID_player
      JOIN `21_field_coordinates` fc ON fc.ID_Field = p.ID_Field
      AND fc.ID_Field > 0
      AND u.active = @activestatus AND IF (id_user=-100, u.ID<-99, u.ID > 0) 
      AND m.magicpoints > 0
      AND p.time_start >= date_start
      AND p.time_end <= date_end
      GROUP BY u.ID
      ORDER BY CASE WHEN order_by = 'sum' THEN SUM(ps.distance) WHEN order_by = 'avg' THEN AVG(ps.distance) WHEN order_by = 'max' THEN MAX(ps.distance) END DESC, u.ID ASC);

    SET @rank := 0;
    SET @user_rank := 0;

    CREATE TEMPORARY TABLE IF NOT EXISTS ranks AS (SELECT
        CASE WHEN id_user = r.ID THEN (@user_rank := (@rank := @rank + 1)) ELSE (@rank := @rank + 1) END AS rank
    FROM ranking r);

    SET @rank := 0;

    -- first row
    (SELECT
        @user_rank AS rank,
        u.ID AS id,
        u.username,
        u.image,
        ROUND(SUM(ps.`distance`), 1) AS `sum`,
        ROUND(AVG(ps.distance), 1) AS `avg`,
        ROUND(MAX(ps.`distance`), 1) AS `max`,
        0 AS is_friend
      FROM `21_participations` p
        JOIN `12_physical_stats` ps
          ON p.ID_Participation = ps.ID_Participation
        JOIN `12_magicpoints` m
          ON ps.ID_Participation = m.ID_Participation
        JOIN `3_users` u
          ON u.ID = p.ID_player
      WHERE u.ID = id_user
      AND u.active = @activestatus AND IF (id_user=-100, u.ID<-99, u.ID > 0)
      AND m.magicpoints > 0
      AND p.time_start >= date_start
      AND p.time_end <= date_end
      GROUP BY u.ID)
    UNION ALL
    (SELECT
        (@rank := @rank + 1) AS rank,
        r.ID AS id,
        r.username,
        r.image,
        r.sum,
        r.avg,
        r.max,
        r.is_friend
      FROM ranking r
      LIMIT 5000);

    DROP TEMPORARY TABLE IF EXISTS ranks;
    DROP TEMPORARY TABLE IF EXISTS ranking;
    DROP TEMPORARY TABLE IF EXISTS friends;

  COMMIT;
END $$
DELIMITER ;
