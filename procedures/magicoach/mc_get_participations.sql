DELIMITER $$
CREATE PROCEDURE `mc_get_participations`(IN id_user int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT '1' AS 'return';
  END;
  START TRANSACTION;

  SELECT
    p.ID_Participation AS id_participation,
    p.time_start,
    mp.magicpoints,
    fc.typical_team_size,
    fc.Field_name AS field_name
    FROM `21_participations` p
    JOIN `12_magicpoints` mp ON p.ID_Participation = mp.ID_Participation
    JOIN `21_field_coordinates` fc ON fc.ID_Field = p.ID_Field
    WHERE fc.ID_Field > 0 AND 
      p.ID_player = (CASE 
        WHEN ((SELECT count(*) 
                FROM `21_participations` pp 
                JOIN `12_magicpoints` mm ON mm.ID_Participation = pp.ID_Participation
                WHERE pp.ID_player = id_user AND mm.magicpoints > 0) = 0) THEN -1 
        ELSE id_user END) AND 
 --   YEAR(p.time_start) >= '2014' AND 
    mp.magicpoints > 0
    ORDER BY p.time_start DESC, p.time_end DESC
    LIMIT 20;

  COMMIT;
END $$
DELIMITER ;
