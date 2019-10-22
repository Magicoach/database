DELIMITER $$
CREATE PROCEDURE `mc_edit_profile`(IN id_user int, IN username varchar(255), IN password varchar(255), IN country varchar(255), IN city varchar(255), IN club varchar(255), IN weight double PRECISION) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT
      '1' AS 'return';
  END;
  START TRANSACTION;

    IF is_active_user(id_user) THEN

      UPDATE `3_users`
      SET `username` = `username`,
          `country` = country,
          city = city,
          club = club,
          weight = weight
      WHERE ID = id_user;

      UPDATE `3_users_password`
      SET `password` = `password`,
          `date` = NOW()

      WHERE ID = id_user;

      SELECT
        '0' AS 'return';
    ELSE
      CALL __force_an_error();
    END IF;

  COMMIT;
END $$
DELIMITER ;
