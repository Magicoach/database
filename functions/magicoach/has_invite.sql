DELIMITER $$
CREATE FUNCTION `has_invite`(id_user int, id_user_target int) RETURNS tinyint(1) 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @result = (SELECT COUNT(*) FROM `3_users_invitations` 
                  WHERE (id_sender = id_user AND id_receiver = id_user_target)
                     OR (id_sender = id_user_target AND id_receiver = id_user));
	RETURN IF(@result = 0, false, true);
END $$
DELIMITER ;
