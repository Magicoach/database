DELIMITER $$
CREATE FUNCTION `email_message_new_password`(email varchar(255), new_password varchar(255)) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
  RETURN CONCAT('Hello Magic Player,',
    '<br>You have requested a new password.',
    '<br>Your password is now: <b>', `new_password`,'</b>',
   -- '<br>Please login with ', `email`,
    '<br>You can change the password to one of your choice in Magicoach Menu, <b>My Profile</b>',
    '<br><br>Enjoy your games!',
    '<br><b>The Magicoach Team</b>',
    '<br>support@magicoach.com',
    '<br>www.magicoach.com');
END $$
DELIMITER ;
