DELIMITER $$
CREATE PROCEDURE `mc_search_user`(IN id_user int, IN pattern varchar(255)) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

    SELECT
      u.ID AS id,
      u.username,
      u.image,
      u.city,
      CASE WHEN (i1.`accepted_date` IS NOT NULL OR
          i2.`accepted_date` IS NOT NULL) THEN 'friend' WHEN (i1.`date` IS NOT NULL AND
          i1.`accepted_date` IS NULL) THEN 'confirm_friendship' WHEN (i2.`date` IS NOT NULL AND
          i2.`accepted_date` IS NULL) THEN 'invite_sent' ELSE 'stranger' END AS state
    FROM `3_users` u
      LEFT JOIN `3_users_invitations` i1
        ON i1.id_sender = u.ID
        AND i1.id_receiver = id_user
      LEFT JOIN `3_users_invitations` i2
        ON i2.id_receiver = u.ID
        AND i2.id_sender = id_user
    WHERE u.ID <> id_user
    AND u.active = 1 AND u.ID > 0
    AND u.username LIKE CONCAT(pattern, '%')
    AND CHAR_LENGTH(pattern) >= 0
    ORDER BY u.username;

  COMMIT;
END $$
DELIMITER ;
