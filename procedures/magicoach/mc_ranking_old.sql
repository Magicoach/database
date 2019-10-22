DELIMITER $$
CREATE PROCEDURE `mc_ranking_old`(IN id_user int, IN id_friend int, IN date_start datetime, IN date_end datetime, IN order_by varchar(255), IN filter varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  -- CALL mc_ranking_sprints(10350, 10004, '2014.01.01 10:00:00', '2017.01.01 10:00:00', 'max', 'friends');
  -- CALL mc_ranking_sprints(10350, 10009, '2014.01.01 10:00:00', '2017.01.01 10:00:00', 'sum', '');

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    DROP TEMPORARY TABLE IF EXISTS ranks;
    DROP TEMPORARY TABLE IF EXISTS ranking;
    DROP TEMPORARY TABLE IF EXISTS friends;
    SELECT
      '1' AS 'return';
  END;
  START TRANSACTION;

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
      AND u2.active = 1
      AND i.accepted_date IS NOT NULL);

    -- HACK: add user to friends list, so you can
    -- see user stats when filter 'friends' is on.
    INSERT INTO friends (id_friend)
      VALUES (id_user);

    CREATE TEMPORARY TABLE IF NOT EXISTS ranking AS (SELECT
        0 AS rank,
        u.ID,
        u.username,
        u.image,
        SUM(ps.sprints) AS `sum`,
        ROUND(AVG(ps.sprints), 1) AS `avg`,
        MAX(ps.sprints) AS `max`
      FROM `21_participations` p
        JOIN `12_physical_stats` ps
          ON p.ID_Participation = ps.ID_Participation
        JOIN `12_magicpoints` m
          ON ps.ID_Participation = m.ID_Participation
        JOIN `3_users` u
          ON u.ID = p.ID_player
        LEFT JOIN friends f
          ON (f.id_friend = u.ID
          AND filter = 'friends')
      WHERE IF(filter = 'friends', f.id_friend IS NOT NULL, f.id_friend IS NULL)
      AND u.active = 1 AND u.ID > 0
      AND m.magicpoints > 0
      AND p.time_start >= date_start
      AND p.time_end <= date_end
      GROUP BY u.ID
      ORDER BY CASE WHEN order_by = 'sum' THEN SUM(ps.sprints) WHEN order_by = 'avg' THEN AVG(ps.sprints) WHEN order_by = 'max' THEN MAX(ps.sprints) END DESC, u.ID ASC);
    -- filter 'friends': all friends ranking
    -- no filter: all rankings

    SET @rank := 0;
    SET @user_rank := 0;
    SET @friend_rank := 0;

    CREATE TEMPORARY TABLE IF NOT EXISTS ranks AS (SELECT
        CASE WHEN id_user = r.ID THEN (@user_rank := (@rank := @rank + 1)) WHEN id_friend = r.ID THEN (@friend_rank := (@rank := @rank + 1)) ELSE (@rank := @rank + 1) END AS rank
    FROM ranking r);

    SET @rank := 0;

    -- first row
    (SELECT
        IF(@user_rank < @friend_rank, @user_rank, @friend_rank) AS rank,
        u.ID AS id,
        u.username,
        u.image,
        SUM(ps.sprints) AS `sum`,
        ROUND(AVG(ps.sprints), 1) AS `avg`,
        MAX(ps.sprints) AS `max`
      FROM `21_participations` p
        JOIN `12_physical_stats` ps
          ON p.ID_Participation = ps.ID_Participation
        JOIN `12_magicpoints` m
          ON ps.ID_Participation = m.ID_Participation
        JOIN `3_users` u
          ON u.ID = p.ID_player
      WHERE u.ID = IF(@user_rank < @friend_rank, id_user, id_friend)
      AND u.active = 1 AND u.ID > 0
      AND m.magicpoints > 0
      AND p.time_start >= date_start
      AND p.time_end <= date_end
      GROUP BY u.ID)

    -- second row
    UNION ALL
    (SELECT
        IF(@user_rank > @friend_rank, @user_rank, @friend_rank) AS rank,
        u.ID AS id,
        u.username,
        u.image,
        SUM(ps.sprints) AS `sum`,
        ROUND(AVG(ps.sprints), 1) AS `avg`,
        MAX(ps.sprints) AS `max`
      FROM `21_participations` p
        JOIN `12_physical_stats` ps
          ON p.ID_Participation = ps.ID_Participation
        JOIN `12_magicpoints` m
          ON ps.ID_Participation = m.ID_Participation
        JOIN `3_users` u
          ON u.ID = p.ID_player
      WHERE u.ID = IF(@user_rank > @friend_rank, id_user, id_friend)
      AND u.active = 1 AND u.ID > 0
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
        r.max
      FROM ranking r
      LIMIT 20);

    DROP TEMPORARY TABLE IF EXISTS ranks;
    DROP TEMPORARY TABLE IF EXISTS ranking;
    DROP TEMPORARY TABLE IF EXISTS friends;

  COMMIT;
END $$
DELIMITER ;
