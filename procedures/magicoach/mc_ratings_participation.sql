DELIMITER $$
CREATE PROCEDURE `mc_ratings_participation`(IN id_part int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DELETE FROM `1_analyzed_data_details` WHERE id_participation = id_part;

  INSERT INTO `1_analyzed_data_details` (id_participation, date, email, field, device, `%movement`, hit_rate, hit_rate_1_sec, hit_rate_2_sec, hit_rate_above_3_sec, `%time_inside_field`, seconds, num_coordinates, longest_no_data, `%time_above_max_speed`, `%time_above_max_speed_outside_field`, version)
    SELECT
      `a`.`ID_Participation` AS `id_participation`,
      `a`.`time` AS `date`,
      (SELECT `get_email_by_participation`(`a`.`ID_Participation`)) AS `email`,
      (SELECT `fc`.`Field_name` FROM `21_field_coordinates` `fc` WHERE (`fc`.`ID_Field` = (SELECT `21_participations`.`ID_Field` FROM `21_participations` WHERE (`21_participations`.`ID_Participation` = `a`.`ID_Participation`)))) AS `field`,
      (SELECT get_parsed_device_info(`a`.`ID_Participation`)) AS `device`,
      ROUND((((SUM(IF((`a`.`speed` <> 0), 1, 0)) + 1) / COUNT(`a`.`delta_t`)) * 100), 1) AS `%movement`,
      ROUND(((COUNT(`a`.`time`) / (TIMESTAMPDIFF(SECOND, MIN(`a`.`time`), MAX(`a`.`time`)) + 1)) * 100), 1) AS `hit_rate`,
      ROUND((((SUM(IF((`a`.`delta_t` = 1), 1, 0)) + 1) / COUNT(`a`.`delta_t`)) * 100), 1) AS `hit_rate_1_sec`,
      ROUND(((SUM(IF((`a`.`delta_t` = 2), 1, 0)) / COUNT(`a`.`delta_t`)) * 100), 1) AS `hit_rate_2_sec`,
      ROUND(((SUM(IF((`a`.`delta_t` >= 3), 1, 0)) / COUNT(`a`.`delta_t`)) * 100), 1) AS `hit_rate_above_3_sec`,
      ROUND((100 / ((SELECT COUNT(`pp`.`time`) FROM `0_positions` `pp` WHERE (`pp`.`ID_Participation` = `a`.`ID_Participation`)) / (SELECT COUNT(`aa`.`time`) FROM `1_analyzed_data_backup` `aa` WHERE ((`aa`.`ID_Participation` = `a`.`ID_Participation`) AND (`aa`.`X_percent` BETWEEN 0 AND 1) AND (`aa`.`Y_percent` BETWEEN 0 AND 1))))), 1) AS `%time_inside_field`,
      (SELECT (TIMESTAMPDIFF(SECOND, `pp`.`time_start`, `pp`.`time_end`) + 1) FROM `21_participations` `pp` WHERE (`pp`.`ID_Participation` = `a`.`ID_Participation`)) AS `seconds`,
      COUNT(`a`.`delta_t`) - 1 AS `num_coordinates`,
      MAX(`a`.`delta_t`) AS `longest_no_data`,
      ROUND(((SUM(IF((`a`.`speed` > (SELECT `ac`.`Max_allowed_speed` FROM `1_algorithm_constants` `ac`)), 1, 0)) / (COUNT(`a`.`delta_t`) - 1)) * 100), 1) AS `%time_above_max_speed`,
      ROUND(((SUM(IF(((`a`.`speed` > (SELECT `ac`.`Max_allowed_speed` FROM `1_algorithm_constants` `ac`)) AND ((`a`.`X_percent` NOT BETWEEN 0 AND 1) OR (`a`.`Y_percent` NOT BETWEEN 0 AND 1))), 1, 0)) / (COUNT(`a`.`delta_t`) - 1)) * 100), 1) AS `%time_above_max_speed_outside_field`,
      (SELECT `pp`.`version` FROM `21_participations` `pp` WHERE (`pp`.`ID_Participation` = `a`.`ID_Participation`)) AS `version`
    FROM `1_analyzed_data_backup` `a`
    WHERE a.ID_Participation = id_part
    GROUP BY `a`.`ID_Participation`;

END $$
DELIMITER ;
