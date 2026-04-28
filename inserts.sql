LOAD DATA INFILE 'C:/users/spiros/downloads/ken.csv' 
INTO TABLE ken_system 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(ken_code, ken_description, base_cost, mdn_days);

LOAD DATA INFILE 'C:/users/spiros/downloads/icd10.csv'
IGNORE INTO TABLE icd10_codes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(icd_id,icd_description, icd_category);

LOAD DATA INFILE 'C:/users/spiros/downloads/active_substances.csv'
IGNORE INTO TABLE active_substances
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(substance_name, substance_description);

LOAD DATA INFILE 'C:/users/spiros/downloads/medicine_substances_junction.csv'
IGNORE INTO TABLE medicine_has_active_substance
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(medication_id, active_substance_id);

LOAD DATA INFILE 'C:/users/spiros/downloads/medicines.csv'
IGNORE INTO TABLE medicines 
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(medication_name, medication_route, medication_auth_country, medication_auth_holder, medication_file_location, medication_email, medication_number);


LOAD DATA INFILE 'C:/users/spiros/downloads/medical_act_categories.csv'
IGNORE INTO TABLE medical_act_categories
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(act_code, category, act_description);

LOAD DATA INFILE 'C:/users/spiros/downloads/laboratory_exam_categories.csv'
IGNORE INTO TABLE laboratory_exam_categories
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(exam_code, category, exam_description);