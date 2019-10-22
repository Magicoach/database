DELIMITER $$
CREATE FUNCTION `email_message_strava_intro`(id_user int) RETURNS text CHARSET utf8 
 SQL SECURITY DEFINER 
 CONTAINS SQL 
BEGIN
 
  SET @username = (SELECT
      u.username
    FROM `3_users` u
        WHERE u.ID = id_user);

  SET @email = (SELECT
      u.email
    FROM `3_users` u
        WHERE u.ID = id_user);

  RETURN CONCAT(
    '<p>Dear ',@username,',</p>',
'<p>Magicoach now allows players to sync with their Strava Activities.</p>',
'<p>You can now analyse your football matches logged by almost any GPS device, not just your mobile phone.</p>',
'<p>To test this new feature just:<o:p></o:p></span></p>',
'<ol start=1 type=1><li class=MsoListParagraph>Click here:
     <a
     href="https://www.strava.com/oauth/authorize?client_id=16968&amp;response_type=code&amp;redirect_uri=http://dev.magicoach.pt:8082/api/v1/strava/oauth/users/',id_user,'&amp;scope=view_private&amp;approval_prompt=force">STRAVA-SYNC</a> to open Strava and accept Magicoach access to your activities.<o:p></o:p></span></li>',
 '<li class=MsoListParagraph>Add <i><u>Football</u></i> to the Name of the Strava Activities that correspond to your matches.</li>',
 '<li class=MsoListParagraph>Done! Each 5 minutes we will check and you get the results in the Magicoach App.</li></ol>',
'<ul><li>You do not need to do this process in the future. The link is stable.</li>
<li>Just keep adding <i><u>Football</span></u></i> in Strava Activity name each time you play.</li></ul>',
'<ul><li>To know more about connecting Strava to your GPS, go to <a href="https://www.strava.com/upload/device">https://www.strava.com/upload/device</a></li>
 <li>These connections are also stable. You only need to authorize the 1<sup>st</sup> time.</li></ul>',
'<p>Feedback and suggestions are super important at this stage. Email us.</p>',
'<p>Enjoy your games!</p>'
'The Magicoach Team<br>',
'<a href="http://www.magicoach.com">www.magicoach.com</a><br>',
'<a href="mailto:support@magicoach.com">support@magicoach.com</a>');
END $$
DELIMITER ;
