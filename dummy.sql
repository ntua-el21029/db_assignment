USE hospital_db;
SET FOREIGN_KEY_CHECKS=0;

-- ============================================
-- 1. ΑΠΟΛΥΤΟΣ ΚΑΘΑΡΙΣΜΟΣ ΣΧΕΤΙΚΩΝ ΠΙΝΑΚΩΝ
-- ============================================
TRUNCATE TABLE `duty_schedule_team`;
TRUNCATE TABLE `duty_schedule`;
TRUNCATE TABLE `laboratory_exams`;
TRUNCATE TABLE `medical_act_has_employee`;
TRUNCATE TABLE `medical_act`;
TRUNCATE TABLE `medication_treatment`;
TRUNCATE TABLE `medication_prescription`;
TRUNCATE TABLE `patient_has_allergy`;
TRUNCATE TABLE `doctor_review`;
TRUNCATE TABLE `hospitalization_review`;
TRUNCATE TABLE `hospitalization`;
TRUNCATE TABLE `triage`;
TRUNCATE TABLE `patient`;
TRUNCATE TABLE `department_room`;
TRUNCATE TABLE `administrative_staff`;
TRUNCATE TABLE `nurse`;
TRUNCATE TABLE `doctor_department`;
TRUNCATE TABLE `hospital_department`;
TRUNCATE TABLE `doctor`;
TRUNCATE TABLE `employee`;

-- ============================================
-- 2. ΥΠΑΛΛΗΛΟΙ (15 Γιατροί, 10 Νοσηλευτές, 10 Διοικητικοί)
-- Με νέα μοναδικά AMKA για να μην υπάρξει καμία διένεξη!
-- ============================================
INSERT IGNORE INTO `employee` (`employee_id`,`empl_first_name`,`empl_last_name`,`empl_email`,`empl_phone`,`empl_hiring_date`,`empl_type`, `empl_amka`, `empl_birth_date`) VALUES
-- Γιατροί
(1,'Γιώργης','Βασιλείου','doc1@h.gr','6911111111','2010-12-26','doctor', '10000000001', '1980-01-01'),
(2,'Κώστας','Βασιλείου','doc2@h.gr','6911111112','2003-11-25','doctor', '10000000002', '1985-01-01'),
(3,'Μαρία','Παπαδόπουλος','doc3@h.gr','6911111113','2009-10-22','doctor', '10000000003', '1975-01-01'),
(4,'Θανάσης','Μακρής','doc4@h.gr','6911111114','2008-12-01','doctor', '10000000004', '1990-01-01'),
(5,'Σοφία','Οικονόμου','doc5@h.gr','6911111115','2012-06-23','doctor', '10000000005', '1988-01-01'),
(6,'Στέφανος','Χριστοδούλου','doc6@h.gr','6911111116','2018-12-16','doctor', '10000000006', '1982-01-01'),
(7,'Κατερίνα','Νικολάου','doc7@h.gr','6911111117','2015-02-05','doctor', '10000000007', '1992-01-01'),
(8,'Νίκος','Παπαδάκης','doc8@h.gr','6911111118','2016-02-07','doctor', '10000000008', '1979-01-01'),
(9,'Παναγιώτα','Δημητρίου','doc9@h.gr','6911111119','2020-08-10','doctor', '10000000009', '1995-01-01'),
(10,'Τάσος','Παπαδάκης','doc10@h.gr','6911111120','2013-02-24','doctor', '10000000010', '1986-01-01'),
(11,'Παναγιώτης','Γεωργίου','doc11@h.gr','6911111121','2015-05-20','doctor', '10000000011', '1975-01-01'),
(12,'Ηλίας','Ιωάννου','doc12@h.gr','6911111122','2016-06-21','doctor', '10000000012', '1980-02-02'),
(13,'Βασιλική','Ρήγα','doc13@h.gr','6911111123','2017-07-22','doctor', '10000000013', '1982-03-03'),
(14,'Γιώργος','Μιχαηλίδης','doc14@h.gr','6911111124','2018-08-23','doctor', '10000000014', '1979-04-04'),
(15,'Δήμητρα','Κώστα','doc15@h.gr','6911111125','2019-09-24','doctor', '10000000015', '1985-05-05'),
-- Νοσηλευτές
(16,'Νίκος','Γεωργίου','nur1@h.gr','6922222221','2017-03-28','nurse', '20000000001', '1990-01-01'),
(17,'Λευτέρης','Κωνσταντίνου','nur2@h.gr','6922222222','2017-05-24','nurse', '20000000002', '1992-01-01'),
(18,'Μιχάλης','Νικολάου','nur3@h.gr','6922222223','2011-12-01','nurse', '20000000003', '1985-01-01'),
(19,'Θεοδώρα','Ζαχαρίου','nur4@h.gr','6922222224','2013-01-10','nurse', '20000000004', '1988-01-01'),
(20,'Ηλίας','Αθανασίου','nur5@h.gr','6922222225','2007-04-23','nurse', '20000000005', '1978-01-01'),
(21,'Αλεξάνδρα','Αλεξίου','nur6@h.gr','6922222226','2018-12-03','nurse', '20000000006', '1995-01-01'),
(22,'Τάσος','Ζαχαρίου','nur7@h.gr','6922222227','2008-08-24','nurse', '20000000007', '1980-01-01'),
(23,'Τάσος','Παπαδάκης','nur8@h.gr','6922222228','2009-01-09','nurse', '20000000008', '1982-01-01'),
(24,'Αλεξάνδρα','Ζαχαρίου','nur9@h.gr','6922222229','2022-12-29','nurse', '20000000009', '1998-01-01'),
(25,'Παναγιώτης','Νικολάου','nur10@h.gr','6922222230','2013-07-31','nurse', '20000000010', '1986-01-01'),
-- Διοικητικοί
(26,'Γιώργης','Δημητρίου','adm1@h.gr','6933333331','2007-07-24','administrative_staff', '30000000001', '1975-01-01'),
(27,'Μιχάλης','Οικονόμου','adm2@h.gr','6933333332','2017-12-10','administrative_staff', '30000000002', '1988-01-01'),
(28,'Κώστας','Νικολάου','adm3@h.gr','6933333333','2011-10-26','administrative_staff', '30000000003', '1982-01-01'),
(29,'Δημήτρης','Γεωργίου','adm4@h.gr','6933333334','2022-02-23','administrative_staff', '30000000004', '1995-01-01'),
(30,'Παναγιώτα','Μακρής','adm5@h.gr','6933333335','2010-01-23','administrative_staff', '30000000005', '1980-01-01'),
(31,'Νίκη','Ζαχαρίου','adm6@h.gr','6933333336','2011-09-02','administrative_staff', '30000000006', '1985-01-01'),
(32,'Κατερίνα','Μακρής','adm7@h.gr','6933333337','2006-05-09','administrative_staff', '30000000007', '1978-01-01'),
(33,'Στέφανος','Αθανασίου','adm8@h.gr','6933333338','2009-09-25','administrative_staff', '30000000008', '1981-01-01'),
(34,'Ειρήνη','Γεωργίου','adm9@h.gr','6933333339','2010-05-19','administrative_staff', '30000000009', '1983-01-01'),
(35,'Θανάσης','Γεωργίου','adm10@h.gr','6933333340','2005-01-22','administrative_staff', '30000000010', '1976-01-01');

-- ============================================
-- 3. ΙΑΤΡΟΙ, ΤΜΗΜΑΤΑ, ΝΟΣΗΛΕΥΤΕΣ, ΔΙΟΙΚΗΤΙΚΟΙ
-- ============================================
INSERT IGNORE INTO `doctor` (`doctor_id`,`employee_id`,`grade_id`,`specialty_id`,`supervisor_doctor_id`, `license_number`) VALUES
(1,1,4,1,NULL, 'LIC001'), (2,2,4,2,NULL, 'LIC002'), (3,3,4,3,NULL, 'LIC003'),
(4,4,4,4,NULL, 'LIC004'), (5,5,4,5,NULL, 'LIC005'), (6,6,4,6,NULL, 'LIC006'),
(7,7,4,7,NULL, 'LIC007'), (8,8,4,8,NULL, 'LIC008'), (9,9,4,9,NULL, 'LIC009'),
(10,10,4,10,NULL, 'LIC010'), (11,11,4,1,NULL, 'LIC011'), (12,12,4,2,NULL, 'LIC012'),
(13,13,4,3,NULL, 'LIC013'), (14,14,4,4,NULL, 'LIC014'), (15,15,4,5,NULL, 'LIC015');

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

INSERT IGNORE INTO `nurse` (`nurse_id`,`employee_id`,`nurse_grade_id`,`hospital_department_id`,`supervisor_nurse_id`) VALUES
(1,16,1,1,NULL), (2,17,1,2,NULL), (3,18,1,3,NULL), (4,19,1,4,NULL), (5,20,1,5,NULL),
(6,21,1,6,NULL), (7,22,1,7,NULL), (8,23,1,8,NULL), (9,24,1,9,NULL), (10,25,1,10,NULL);

INSERT IGNORE INTO `administrative_staff` (`staff_id`,`staff_office`,`employee_id`,`department_id`,`role_id`) VALUES
(1,'G101',26,1,3), (2,'G102',27,2,3), (3,'G103',28,3,2), (4,'G104',29,4,1), (5,'G105',30,5,3),
(6,'G106',31,6,1), (7,'G107',32,7,2), (8,'G108',33,8,1), (9,'G109',34,9,3), (10,'G110',35,10,3);

INSERT IGNORE INTO `doctor_department` (`doctor_id`,`department_id`) VALUES
(1,1), (2,2), (3,3), (4,4), (5,5), (6,6), (7,7), (8,8), (9,9), (10,10), (11,11), (12,12), (13,13), (14,14), (15,15);

INSERT IGNORE INTO `department_room` (`room_id`,`room_type`,`room_status`,`hospital_department_id`) VALUES
(1,'Single Bed Patient Room','Available',1), (2,'Surgery Room','Available',2), (3,'Intensive Care Unit','Available',3),
(4,'Single Bed Patient Room','Available',4), (5,'Multi Bed Patient Room','Available',5), (6,'Surgery Room','Available',6),
(7,'Single Bed Patient Room','Available',7), (8,'Single Bed Patient Room','Available',8), (9,'Multi Bed Patient Room','Available',9),
(10,'Surgery Room','Available',10), (11,'Single Bed Patient Room','Available',11), (12,'Surgery Room','Available',12),
(13,'Single Bed Patient Room','Available',13), (14,'Multi Bed Patient Room','Available',14), (15,'Single Bed Patient Room','Available',15);

-- ============================================
-- 4. ΑΣΘΕΝΕΙΣ ΚΑΙ ΛΟΙΠΑ ΔΕΔΟΜΕΝΑ
-- ============================================
INSERT IGNORE INTO `patient` (`patient_id`,`amka`,`first_name`,`last_name`,`father_name`,`birth_date`,`gender`,`nationality`,`height_cm`,`weight_kg`,`home_address`,`phone_number`,`email`,`profession`,`emergency_contact`,`insurance_provider`) VALUES
(1,'40000000001','Eleni','Papadaki','Lefteris','1950-10-18','Female','Greek',165,70,'Athens 1','6912345678','eleni@email.gr','Retired','Vasilis: 6912345678','Public'),
(2,'40000000002','Katerina','Georgiou','Michalis','1945-11-14','Female','Greek',160,65,'Athens 2','6933068427','kat@email.gr','Engineer','Stefanos: 6933068427','Private'),
(3,'40000000003','Michalis','Makris','Michalis','1955-01-03','Male','Greek',175,82,'Athens 3','6963118906','michalis@email.gr','Doctor','Lefteris: 6963118906','None'),
(4,'40000000004','Thanasis','Stavrou','Nikos','1960-08-08','Male','Greek',180,90,'Athens 4','6936025314','thanasis@email.gr','Lawyer','Tasos: 6936025314','Private'),
(5,'40000000005','Kostas','Dimitriou','Dimitris','1955-07-26','Male','Greek',178,85,'Athens 5','6930517835','kostas@email.gr','Retired','Stefanos: 6930517835','None'),
(6,'40000000006','Eirini','Zachariou','Tasos','1962-08-23','Female','Greek',162,60,'Athens 6','6995268296','eirini@email.gr','Engineer','Spyros: 6995268296','None'),
(7,'40000000007','Niki','Stavrou','Panagiotis','1964-08-22','Female','Greek',168,68,'Athens 7','6917539294','niki@email.gr','Teacher','Alexis: 6917539294','Public'),
(8,'40000000008','Alexis','Karagiannis','Panagiotis','1946-11-19','Male','Greek',170,75,'Athens 8','6922119391','alexis@email.gr','Teacher','Spyros: 6922119391','None'),
(9,'40000000009','Theodora','Christodoulou','Spyros','1970-06-24','Female','Greek',165,65,'Athens 9','6953154591','theodora@email.gr','Engineer','Spyros: 6953154591','None'),
(10,'40000000010','Georgia','Georgiou','Thanasis','1968-12-19','Female','Greek',160,62,'Athens 10','6915253567','georgia@email.gr','Doctor','Dimitris: 6915253567','Private');

INSERT IGNORE INTO `hospitalization_review` (`review_id`,`medical_care`,`nurse_care`,`cleanness`,`overall_experience`,`food_quality`) VALUES
(1,5,5,4,5,4), (2,4,4,5,4,3), (3,3,4,3,3,4), (4,5,5,5,5,5), (5,4,4,4,3,3),
(6,5,4,5,4,4), (7,4,5,5,5,4), (8,3,3,4,3,3), (9,4,4,4,4,4), (10,5,5,5,5,5);

INSERT IGNORE INTO `triage` (`triage_id`,`patient_id`,`nurse_id`,`arrival_time`,`emergency_level`,`symptoms`,`outcome`) VALUES
(1,1,1,'2023-01-01 08:00:00',1,'Chest pain','Hospitalization'),
(2,2,2,'2023-02-10 09:30:00',2,'Fever','Hospitalization'),
(3,3,3,'2023-03-15 10:15:00',3,'Dizziness','Hospitalization'),
(4,4,4,'2023-04-20 11:45:00',1,'Severe injury','Hospitalization'),
(5,5,5,'2023-05-25 14:00:00',2,'Abdominal pain','Hospitalization'),
(6,6,6,'2023-06-10 16:30:00',3,'Headache','Hospitalization'),
(7,7,7,'2023-07-05 18:20:00',1,'Shortness of breath','Hospitalization'),
(8,8,8,'2023-08-12 20:10:00',2,'High blood pressure','Hospitalization'),
(9,9,9,'2023-09-18 22:05:00',3,'Nausea','Hospitalization'),
(10,10,10,'2023-10-22 23:50:00',1,'Chest pain','Hospitalization');

-- Μεταβλητές (τραβάνε από CSV)
SET @ken1 = (SELECT ken_id FROM ken_system LIMIT 1);
SET @icd1 = (SELECT icd_id FROM ICD10_codes LIMIT 1);
SET @lab1 = (SELECT exam_code FROM laboratory_exam_categories LIMIT 1);
SET @act1 = (SELECT act_code FROM medical_act_categories LIMIT 1);
SET @med1 = (SELECT medication_id FROM medicines LIMIT 1);
SET @sub1 = (SELECT active_substance_id FROM active_substances LIMIT 1);

INSERT IGNORE INTO `hospitalization` (`hospitalization_id`,`patient_id`,`triage_id`,`room_id`,`department_id`,`admission_date`,`discharge_date`,`ICD10_admission_id`,`ICD10_discharge_id`,`ken_id`,`extra_cost`,`total_cost`,`hosp_review_id`) VALUES
(1,1,1,1,1,'2023-01-01 09:00:00','2023-01-10 10:00:00',@icd1,@icd1,@ken1,0.0,0.0,1),
(2,2,2,2,2,'2023-02-10 10:30:00','2023-02-15 12:00:00',@icd1,@icd1,@ken1,0.0,0.0,2),
(3,3,3,3,3,'2023-03-15 11:15:00','2023-03-25 14:00:00',@icd1,@icd1,@ken1,0.0,0.0,3),
(4,4,4,4,4,'2023-04-20 12:45:00','2023-05-01 09:30:00',@icd1,@icd1,@ken1,0.0,0.0,4),
(5,5,5,5,5,'2023-05-25 15:00:00','2023-06-05 11:15:00',@icd1,@icd1,@ken1,0.0,0.0,5),
(6,6,6,6,6,'2023-06-10 17:30:00','2023-06-18 13:45:00',@icd1,@icd1,@ken1,0.0,0.0,6),
(7,7,7,7,7,'2023-07-05 19:20:00','2023-07-15 15:20:00',@icd1,@icd1,@ken1,0.0,0.0,7),
(8,8,8,8,8,'2023-08-12 21:10:00','2023-08-20 10:10:00',@icd1,@icd1,@ken1,0.0,0.0,8),
(9,9,9,9,9,'2023-09-18 23:05:00','2023-09-25 11:00:00',@icd1,@icd1,@ken1,0.0,0.0,9),
(10,10,10,10,10,'2023-10-23 00:50:00','2023-11-02 12:30:00',@icd1,@icd1,@ken1,0.0,0.0,10);

UPDATE hospitalization SET discharge_date = discharge_date WHERE total_cost = 0;

INSERT IGNORE INTO `doctor_review` (`doctor_review_id`,`hospitalization_id`,`doctor_id`,`medical_care`) VALUES
(1,1,1,5), (2,2,2,4), (3,3,3,5), (4,4,4,4), (5,5,5,5),
(6,6,6,4), (7,7,7,5), (8,8,8,3), (9,9,9,4), (10,10,10,5);

INSERT IGNORE INTO `duty_schedule` (`duty_id`,`duty_date`,`shift_type_id`,`hospital_department_id`, `is_finalized`) VALUES
(1,'2024-01-07',1,1, 1), (2,'2024-02-17',2,2, 1), (3,'2024-03-05',3,3, 1),
(4,'2024-04-18',1,4, 1), (5,'2024-05-24',2,5, 1), (6,'2024-06-16',3,6, 1),
(7,'2024-07-05',1,7, 1), (8,'2024-08-08',2,8, 1), (9,'2024-09-22',3,9, 1),
(10,'2024-10-21',1,10, 1);

INSERT IGNORE INTO `duty_schedule_team` (`duty_id`,`employee_id`) VALUES
(1,1), (1,16), (1,26), (2,2), (2,17), (2,27), 
(3,3), (3,18), (3,28), (4,4), (4,19), (4,29), 
(5,5), (5,20), (5,30), (6,6), (6,21), (6,31), 
(7,7), (7,22), (7,32), (8,8), (8,23), (8,33), 
(9,9), (9,24), (9,34), (10,10), (10,25), (10,35);

INSERT IGNORE INTO `laboratory_exams` (`exam_id`,`exam_date`,`exam_result`,`doctor_id`,`hospitalization_id`,`exam_code`) VALUES
(1,'2023-01-02','Normal',1,1,@lab1), (2,'2023-02-11','Pathological',2,2,@lab1),
(3,'2023-03-16','Normal',3,3,@lab1), (4,'2023-04-21','Normal',4,4,@lab1),
(5,'2023-05-26','Borderline',5,5,@lab1), (6,'2023-06-11','Normal',6,6,@lab1),
(7,'2023-07-06','Pathological',7,7,@lab1), (8,'2023-08-13','Normal',8,8,@lab1),
(9,'2023-09-19','Borderline',9,9,@lab1), (10,'2023-10-24','Normal',10,10,@lab1);

INSERT IGNORE INTO `medical_act` (`act_id`,`act_start`,`act_end`,`act_cost`,`main_surgeon_id`,`hospitalization_id`,`department_room_id`,`medical_act_code`,`department_id`) VALUES
(1,'2023-01-03 10:00:00','2023-01-03 12:00:00',1000.00,1,1,1,@act1,1),
(2,'2023-02-12 11:00:00','2023-02-12 13:00:00',1500.00,2,2,2,@act1,2),
(3,'2023-03-17 09:00:00','2023-03-17 11:30:00',800.00,3,3,3,@act1,3),
(4,'2023-04-22 14:00:00','2023-04-22 15:00:00',500.00,4,4,4,@act1,4),
(5,'2023-05-27 10:00:00','2023-05-27 12:45:00',2000.00,5,5,5,@act1,5),
(6,'2023-06-12 08:30:00','2023-06-12 10:30:00',1200.00,6,6,6,@act1,6),
(7,'2023-07-07 11:15:00','2023-07-07 13:15:00',1800.00,7,7,7,@act1,7),
(8,'2023-08-14 09:45:00','2023-08-14 11:00:00',600.00,8,8,8,@act1,8),
(9,'2023-09-20 15:30:00','2023-09-20 17:00:00',900.00,9,9,9,@act1,9),
(10,'2023-10-25 13:00:00','2023-10-25 15:30:00',2200.00,10,10,10,@act1,10);

INSERT IGNORE INTO `medical_act_has_employee` (`act_id`,`employee_id`) VALUES
(1,16), (2,17), (3,18), (4,19), (5,20),
(6,21), (7,22), (8,23), (9,24), (10,25);

INSERT IGNORE INTO `medication_prescription` (`prescription_id`,`dosage`,`frequency`,`start_date`,`end_date`) VALUES
(1,'1g','2x ημερησίως','2023-01-01','2023-01-10'),
(2,'500mg','3x ημερησίως','2023-02-10','2023-02-15'),
(3,'10ml','1x ημερησίως','2023-03-15','2023-03-25'),
(4,'1 tablet','2x ημερησίως','2023-04-20','2023-05-01'),
(5,'250mg','Κάθε 8 ώρες','2023-05-25','2023-06-05'),
(6,'1g','1x ημερησίως','2023-06-10','2023-06-18'),
(7,'500mg','2x ημερησίως','2023-07-05','2023-07-15'),
(8,'10ml','Κάθε 12 ώρες','2023-08-12','2023-08-20'),
(9,'1 tablet','1x ημερησίως','2023-09-18','2023-09-25'),
(10,'250mg','3x ημερησίως','2023-10-23','2023-11-02');

INSERT IGNORE INTO `medication_treatment` (`treatment_id`,`patient_id`,`med_prescription_id`,`doctor_id`,`medicine_id`) VALUES
(1,1,1,1,@med1), (2,2,2,2,@med1), (3,3,3,3,@med1), (4,4,4,4,@med1), (5,5,5,5,@med1),
(6,6,6,6,@med1), (7,7,7,7,@med1), (8,8,8,8,@med1), (9,9,9,9,@med1), (10,10,10,10,@med1);

INSERT IGNORE INTO `patient_has_allergy` (`patient_id`,`active_substance_id`) VALUES
(1,@sub1), (2,@sub1), (3,@sub1), (4,@sub1), (5,@sub1),
(6,@sub1), (7,@sub1), (8,@sub1), (9,@sub1), (10,@sub1);

SET FOREIGN_KEY_CHECKS=1;
