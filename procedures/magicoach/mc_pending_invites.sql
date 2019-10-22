DELIMITER $$
CREATE PROCEDURE `mc_pending_invites`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT
      '1' AS 'return';
  END;
  START TRANSACTION;

    SELECT
      u.ID AS id,
      u.username,
      u.image,
      'confirm_friendship' AS state
    FROM `3_users` u
      LEFT JOIN `3_users_invitations` i1
        ON i1.id_sender = u.ID
        AND i1.id_receiver = id_user
      LEFT JOIN `3_users_invitations` i2
        ON i2.id_receiver = u.ID
        AND i2.id_sender = id_user
    WHERE u.ID <> id_user
    AND u.active = 1
    AND i1.`date` IS NOT NULL
    AND i1.`accepted_date` IS NULL
    ORDER BY u.username;

  COMMIT;
END $$
DELIMITER ;
