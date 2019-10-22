DELIMITER $$
CREATE PROCEDURE `calculate_field`(IN new_ID_Field int) 
 SQL SECURITY DEFINER  CONTAINS SQL BEGIN

  DELETE FROM `12_field_dimensions` WHERE ID_Field = new_ID_Field;

  INSERT INTO `12_field_dimensions` (ID_Field, Rotation, X_esq_baliza1, Y_esq_baliza1, X_dir_baliza1, Y_dir_baliza1, X_esq_baliza2, Y_esq_baliza2)
    SELECT
      ID_Field AS ID_Field,
      IF(Lat_dir_baliza1 > Lat_esq_baliza2, 1, - 1) * ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180))) AS Rotation,
      0 AS X_esq_baliza1,
      0 AS Y_esq_baliza1,
      ABS(6371000 * PI() / 180 * ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180) * COS(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))) - (Lat_dir_baliza1 - Lat_esq_baliza1) * SIN(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))))) AS X_dir_baliza1,
      ABS(6371000 * PI() / 180 * ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180) * SIN(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))) + (Lat_dir_baliza1 - Lat_esq_baliza1) * COS(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))))) AS Y_dir_baliza1,
      ABS(6371000 * PI() / 180 * ((Long_esq_baliza2 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180) * COS(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))) - (Lat_esq_baliza2 - Lat_esq_baliza1) * SIN(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))))) AS X_esq_baliza2,
      ABS(6371000 * PI() / 180 * ((Long_esq_baliza2 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180) * SIN(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))) + (Lat_esq_baliza2 - Lat_esq_baliza1) * COS(- ATAN((Lat_dir_baliza1 - Lat_esq_baliza1) / ((Long_dir_baliza1 - Long_esq_baliza1) * COS(Lat_esq_baliza1 * PI() / 180)))))) AS Y_esq_baliza2
    FROM `21_field_coordinates`
    WHERE ID_Field = new_ID_Field;

END $$
DELIMITER ;
