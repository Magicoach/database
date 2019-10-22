DELIMITER $$
CREATE PROCEDURE `0_recalculate_unknown_fields`() 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN


SET @ID_part = (SELECT
  `21_participations`.ID_Participation
FROM `21_participations`
  WHERE ID_Field = 122
ORDER BY `21_participations`.time_start DESC
  LIMIT 1);

SET @check_existing_field = magicoach.get_nearest_field(@ID_part);
  SELECT @check_existing_field;

  IF (@check_existing_field IS NOT NULL)
    THEN
      UPDATE `21_participations` SET ID_Field = @check_existing_field  WHERE ID_Participation = @ID_part;
      CALL magicoach.mc_calculate_participation_noemail(@ID_part);
      ELSEIF (SELECT COUNT(*) FROM `0_positions` WHERE ID_Participation=@ID_part) <120  THEN
        UPDATE `21_participations` SET ID_Field = -2  WHERE ID_Participation = @ID_part;
      ELSE
      CALL magicoach.calculate_automatic_field(@ID_part,@id_new_field);
     -- SET @id_new_field = magicoach.get_nearest_field(@ID_part,"");
            IF @id_new_field IS NOT NULL
            THEN
            UPDATE `21_participations` SET ID_Field = @id_new_field  WHERE ID_Participation = @ID_part;
            CALL magicoach.mc_calculate_participation_noemail(@ID_part);
            END IF;
   END IF;




END $$
DELIMITER ;
