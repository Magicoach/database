DELIMITER $$
CREATE FUNCTION `email_message_welcome`(username VARCHAR(255)) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
RETURN CONCAT('Welcome ', `username`, '!',
  '<br><br>Track your Performance and compare your Heatmaps with other players.',
  '<br><br>Use your favorite GPS Device and get all the data in your Magicoach App.',
  '<br><br>Change your password and renew your photo on Magicoach Menu, <b>My profile</b>',
  '<br>Invite your friends and connect with them to play Magicoach together.',
  '<br><br>Enjoy your games!',
  '<br><b>The Magicoach Team</b>',
  '<br>support@magicoach.com',
  '<br>www.magicoach.com');
END $$
DELIMITER ;
