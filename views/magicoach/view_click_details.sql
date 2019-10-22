USE magicoach;
 CREATE VIEW view_click_details AS select `magicoach`.`3_users`.`email` AS `email`,`magicoach`.`3_users`.`ID` AS `ID`,`magicoach`.`3_users`.`username` AS `username`,`magicoach`.`3_users`.`date_created` AS `date_created`,`magicoach`.`5_logs`.`date` AS `date`,`magicoach`.`5_logs`.`device` AS `device`,`magicoach`.`5_logs`.`version` AS `version`,`magicoach`.`5_logs_description`.`description` AS `description`,month(`magicoach`.`5_logs`.`date`) AS `Month` from ((`magicoach`.`5_logs` join `magicoach`.`3_users` on((`magicoach`.`5_logs`.`id_user` = `magicoach`.`3_users`.`ID`))) join `magicoach`.`5_logs_description` on((`magicoach`.`5_logs`.`id_event` = `magicoach`.`5_logs_description`.`id_event`)))