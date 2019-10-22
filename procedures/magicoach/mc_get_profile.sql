DELIMITER $$
CREATE PROCEDURE `mc_get_profile`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SELECT
    `u`.ID AS id,
    `u`.`username`,
    `up`.`password`,
    `u`.`email`,
    `u`.`image`,
    u.country,
    u.city,
    u.weight,
    u.club,
    IFNULL((SELECT
        SUM(m.magicpoints)
      FROM `21_participations` p
        JOIN `3_users` u1
          ON u1.ID = p.ID_player
        JOIN `12_magicpoints` m
          ON m.ID_Participation = p.ID_Participation
      JOIN `21_field_coordinates` fc ON fc.ID_Field = p.ID_Field
      WHERE fc.ID_Field > 0 AND u1.ID = id_user
      AND YEAR(p.time_start) >= '2016'), 0) AS magicpoints
  FROM `3_users` u
    LEFT JOIN `3_users_password` up
      ON `up`.`ID` = `u`.ID
  WHERE u.ID = id_user AND u.active = 1
  GROUP BY u.ID;

END $$
DELIMITER ;
