DELIMITER $$
CREATE PROCEDURE `new_users`(IN days_range int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  SELECT
    u.ID AS id,
    u.username,
    u.email,
    u.date_created,
    (SELECT
        TO_DAYS(NOW()) - TO_DAYS(`u`.`date_created`)) AS days
  FROM `3_users` u
  WHERE (TO_DAYS(NOW()) - TO_DAYS(`u`.`date_created`)) <= days_range
  ORDER BY `u`.`date_created` DESC;

END $$
DELIMITER ;
