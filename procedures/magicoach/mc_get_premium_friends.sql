DELIMITER $$
CREATE PROCEDURE `mc_get_premium_friends`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SET @full_access = (SELECT up.full_access FROM `3_users_permissions` up WHERE up.user_id = id_user);

IF (id_user<>-100) THEN 

SELECT 
  u2.ID AS id,
  u2.username AS username,
  u2.image AS image,
  friends.magicpoints AS magicpoints
  FROM `3_users` u2  
  JOIN (SELECT
      u.ID AS id,
      u.username AS username,
      u.image AS image,
      IFNULL(SUM(m.magicpoints), 0) AS magicpoints
    FROM `21_participations` p
    JOIN `12_magicpoints` m ON m.ID_Participation = p.ID_Participation
    JOIN `21_field_coordinates` fc ON fc.ID_Field = p.ID_Field
    JOIN `3_users` u ON u.ID = p.ID_player
    WHERE fc.ID_Field > 0 AND u.active = 1 AND  YEAR(p.time_start) >= '2016' AND m.magicpoints > 0
    GROUP BY u.ID) AS friends ON friends.id = u2.ID
  WHERE friends.ID <> id_user AND 
    (CASE WHEN @full_access = TRUE THEN friends.ID < -1 OR friends.ID > 10000
            ELSE friends.ID < -1 END)
  ORDER BY friends.username ASC;
END IF;

  COMMIT;
END $$
DELIMITER ;
