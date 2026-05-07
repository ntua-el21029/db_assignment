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


--- DUMMY DATA ---

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
(1, 'Cardiology'),
(2, 'Surgery'),
(3, 'Internal Medicine'),
(4, 'Orthopedics'),
(5, 'Neurology'),
(6, 'Radiology'),
(7, 'Anesthesiology'),
(8, 'Pediatrics'),
(9, 'Obstetrics'),
(10, 'Psychiatry');

INSERT IGNORE INTO `employee` (`employee_id`,`empl_first_name`,`empl_last_name`,`empl_email`,`empl_phone`,`empl_hiring_date`,`empl_type`, `empl_amka`, `empl_birth_date`) VALUES
(1,'Γιώργης','Βασιλείου','γιώργης1@hospital.gr','6946913810','2010-12-26','doctor', '11111111111', '1980-01-01'),
(2,'Κώστας','Βασιλείου','κώστας2@hospital.gr','6923756669','2003-11-25','doctor', '22222222222', '1985-01-01'),
(3,'Μαρία','Παπαδόπουλος','μαρία3@hospital.gr','6922575562','2009-10-22','doctor', '33333333333', '1975-01-01'),
(4,'Θανάσης','Μακρής','θανάσης4@hospital.gr','6913561597','2008-12-01','doctor', '44444444444', '1990-01-01'),
(5,'Σοφία','Οικονόμου','σοφία5@hospital.gr','6989089901','2012-06-23','doctor', '55555555555', '1988-01-01'),
(6,'Στέφανος','Χριστοδούλου','στέφανος6@hospital.gr','6931429110','2018-12-16','doctor', '66666666666', '1982-01-01'),
(7,'Κατερίνα','Νικολάου','κατερίνα7@hospital.gr','6938898923','2015-02-05','doctor', '77777777777', '1992-01-01'),
(8,'Νίκος','Παπαδάκης','νίκος8@hospital.gr','6922981052','2016-02-07','doctor', '88888888888', '1979-01-01'),
(9,'Παναγιώτα','Δημητρίου','παναγιώτα9@hospital.gr','6915831819','2020-08-10','doctor', '99999999999', '1995-01-01'),
(10,'Τάσος','Παπαδάκης','τάσος10@hospital.gr','6920576383','2013-02-24','doctor', '10101010101', '1986-01-01'),
(11,'Παναγιώτης','Γεωργίου','panagiotis11@hospital.gr','6911111111','2015-05-20','doctor', '11111111114', '1975-01-01'),
(12,'Ηλίας','Ιωάννου','ilias12@hospital.gr','6911111112','2016-06-21','doctor', '22222222225', '1980-02-02'),
(13,'Βασιλική','Ρήγα','vasiliki13@hospital.gr','6911111113','2017-07-22','doctor', '33333333336', '1982-03-03'),
(14,'Γιώργος','Μιχαηλίδης','giorgos14@hospital.gr','6911111114','2018-08-23','doctor', '44444444447', '1979-04-04'),
(15,'Δήμητρα','Κώστα','dimitra15@hospital.gr','6911111115','2019-09-24','doctor', '55555555558', '1985-05-05');

-- doctor (15 ιατροί, όλοι με βαθμό 4 - Chief)
INSERT IGNORE INTO `doctor` (`doctor_id`,`employee_id`,`grade_id`,`specialty_id`,`supervisor_doctor_id`, `license_number`) VALUES
(1,1,4,1,NULL, 'LIC001'),
(2,2,4,2,NULL, 'LIC002'),
(3,3,4,3,NULL, 'LIC003'),
(4,4,4,4,NULL, 'LIC004'),
(5,5,4,5,NULL, 'LIC005'),
(6,6,4,6,NULL, 'LIC006'),
(7,7,4,7,NULL, 'LIC007'),
(8,8,4,8,NULL, 'LIC008'),
(9,9,4,9,NULL, 'LIC009'),
(10,10,4,10,NULL, 'LIC010'),
(11,11,4,1,NULL, 'LIC011'),
(12,12,4,2,NULL, 'LIC012'),
(13,13,4,3,NULL, 'LIC013'),
(14,14,4,4,NULL, 'LIC014'),
(15,15,4,5,NULL, 'LIC015');

-- hospital_department 
INSERT IGNORE INTO `hospital_department` (`department_id`,`department_name`,`dep_description`,`dep_building`,`dep_floor`,`department_director`) VALUES
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
