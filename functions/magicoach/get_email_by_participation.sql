DELIMITER $$
CREATE FUNCTION `get_email_by_participation`(id_participation int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  SET @user = (SELECT p.ID_player FROM `21_participations` p WHERE p.ID_Participation = id_participation);
  RETURN (SELECT u.email FROM `3_users` u WHERE u.ID = @user);
END $$
DELIMITER ;
