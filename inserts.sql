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


-- DUMMY DATA --

-- shift_type
INSERT IGNORE INTO `shift_type` (`shift_type_id`,`start_time`,`end_time`,`shift_type`) VALUES
(1,'07:00:00','15:00:00','Morning'),
(2,'15:00:00','23:00:00','Afternoon'),
(3,'23:00:00','07:00:00','Night');

-- staff_role
INSERT IGNORE INTO `staff_role` (`role_id`,`role_description`) VALUES
(1,'Secretary'),
(2,'Accountant'),
(3,'Director');

-- nurse_grade
INSERT IGNORE INTO `nurse_grade` (`nurse_grade_id`,`grade_description`) VALUES
(1,'Supervisor Nurse'),
(2,'Nurse'),
(3,'Assistant Nurse');

-- doctor_grade
INSERT IGNORE INTO `doctor_grade` (`grade_id`,`grade_description`) VALUES
(1,'Attending'),
(2,'Currator B'),
(3,'Currrator A'),
(4,'Chief');

-- doctor_specialty
INSERT IGNORE INTO `doctor_specialty` (`specialty_id`,`specialty_name`) VALUES
(1,'Cardiology'),
(2,'Surgery'),
(3,'Internal Medicine'),
(4,'Orthopedics'),
(5,'Neurology'),
(6,'Radiology'),
(7,'Anesthesiology'),
(8,'Pediatrics'),
(9,'Obstetrics'),
(10,'Psychiatry');


INSERT IGNORE INTO doctor (doctor_id,employee_id,grade_id,specialty_id,supervisor_doctor_id, license_number) VALUES
(1,1,4,1,NULL, 'LIC001'), (2,2,4,2,NULL, 'LIC002'), (3,3,4,3,NULL, 'LIC003'), (4,4,4,4,NULL, 'LIC004'), (5,5,4,5,NULL, 'LIC005'),
(6,6,4,6,NULL, 'LIC006'), (7,7,4,7,NULL, 'LIC007'), (8,8,4,8,NULL, 'LIC008'), (9,9,4,9,NULL, 'LIC009'), (10,10,4,10,NULL, 'LIC010'),
(11,11,4,1,NULL, 'LIC011'), (12,12,4,2,NULL, 'LIC012'), (13,13,4,3,NULL, 'LIC013'), (14,14,4,4,NULL, 'LIC014'), (15,15,4,5,NULL, 'LIC015');


INSERT IGNORE INTO hospital_department (department_id,department_name,dep_description,dep_building,dep_floor,department_director) VALUES
(1, 'Cardiology', 'Cardiology Department', 'A', 1, 1),
(2, 'Surgery', 'Surgery Department', 'B', 2, 2),
(3, 'ICU', 'Intensive Care Unit', 'C', 3, 3),
(4, 'Emergency', 'Emergency Department', 'A', 4, 4),
(5, 'Internal Medicine', 'Internal Medicine Department', 'B', 5, 5),
(6, 'Orthopedics', 'Orthopedics Department', 'C', 1, 6),
(7, 'Neurology', 'Neurology Department', 'A', 2, 7),
(8, 'Radiology', 'Radiology Department', 'B', 3, 8),
(9, 'Pediatrics', 'Pediatrics Department', 'C', 4, 9),
(10, 'Obstetrics', 'Obstetrics Department', 'A', 5, 10),
(11, 'Urology', 'Urology Department', 'B', 1, 11),
(12, 'Ophthalmology', 'Ophthalmology Department', 'C', 2, 12),
(13, 'Dermatology', 'Dermatology Department', 'A', 3, 13),
(14, 'Pulmonology', 'Pulmonology Department', 'B', 4, 14),
(15, 'Gastroenterology', 'Gastroenterology Department', 'C', 5, 15);

INSERT IGNORE INTO doctor_department (doctor_id,department_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15);



