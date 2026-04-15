LOAD DATA INFILE 'ken.csv' 
INTO TABLE ken_system 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(ken_code, ken_description, base_cost, mdn_days);

LOAD DATA INFILE 'icd10_3digit.csv' 
INTO TABLE ICD10_codes 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(icd_description, icd_category);

LOAD DATA INFILE 'active_substances.csv' 
INTO TABLE active_substances
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(substance_name, substance_description);

LOAD DATA INFILE 'medicine_has_active_substance.csv' 
INTO TABLE medicine_has_active_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(medication_id, active_substance_id);

LOAD DATA INFILE 'medicines_table_import.csv' 
INTO TABLE medicines 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(medication_name, medication_route, medication_auth_country, medication_auth_holder, medication_file_location, medication_email, medication_number);

