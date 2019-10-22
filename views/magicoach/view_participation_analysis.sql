USE magicoach;
 CREATE VIEW view_participation_analysis AS select `p`.`ID_Participation` AS `id_participation`,`u`.`username` AS `username`,`u`.`ID` AS `ID`,`u`.`email` AS `email`,`p`.`time_start` AS `date_start`,`p`.`time_end` AS `date_end`,subtime(cast(`p`.`time_end` as time),cast(`p`.`time_start` as time)) AS `duration`,`fc`.`Field_name` AS `field`,`fc`.`Lat_avg` AS `Latitude`,`fc`.`Long_avg` AS `Longitude`,round(`ps`.`max_speed`,1) AS `max_speed`,round(`ps`.`avg_speed`,1) AS `avg_speed`,round(`ps`.`distance`,1) AS `distance`,round((`ps`.`percent_running` * 100),1) AS `perc_running`,`ps`.`sprints` AS `sprints`,`m`.`magicpoints` AS `magicpoints`,round((`m`.`field_ocupation` / 6),1) AS `perc_field_occupation`,round(`a`.`defense`,2) AS `km_defense`,round(`a`.`middle`,2) AS `km_middle`,round(`a`.`attack`,2) AS `km_attack`,(select `GET_FIELD_ZONE`(`p`.`ID_Participation`) AS `expr1`) AS `field_zone`,(select `GET_GAME_STYLE`(`p`.`ID_Participation`) AS `expr1`) AS `game_style` from (((((`magicoach`.`21_participations` `p` left join `magicoach`.`12_areas` `a` on((`p`.`ID_Participation` = `a`.`id_participation`))) left join `magicoach`.`12_physical_stats` `ps` on((`a`.`id_participation` = `ps`.`ID_Participation`))) left join `magicoach`.`12_magicpoints` `m` on((`ps`.`ID_Participation` = `m`.`ID_Participation`))) left join `magicoach`.`21_field_coordinates` `fc` on((`fc`.`ID_Field` = `p`.`ID_Field`))) left join `magicoach`.`3_users` `u` on((`u`.`ID` = `p`.`ID_player`))) order by `p`.`ID_Participation` desc