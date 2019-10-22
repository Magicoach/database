DELIMITER $$
CREATE PROCEDURE `user_participations`(IN minimum_seconds int, IN days_range int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

    SELECT
      `u`.`username`,
      `u`.`email`,
      MIN(`p`.`time_start`) AS `first_game`,
      MAX(`p`.`time_start`) AS `last_game`,
      COUNT(`p`.`ID_Participation`) AS `total_participations`,
      p.device AS device
    FROM `21_participations` `p`
      LEFT JOIN `3_users` `u`
        ON `u`.ID = `p`.`ID_player`
    WHERE (TIMESTAMPDIFF(SECOND, `p`.`time_start`, `p`.`time_end`) >= minimum_seconds)
    AND (TO_DAYS(NOW()) - TO_DAYS(`p`.`time_start`)) <= days_range
    GROUP BY `p`.`ID_player`
    ORDER BY COUNT(`p`.`ID_Participation`) DESC;

END $$
DELIMITER ;
