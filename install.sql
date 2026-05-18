DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE ken_system (
    ken_id INT(11) AUTO_INCREMENT PRIMARY KEY,
    ken_code VARCHAR(20) NOT NULL,
    ken_description VARCHAR(255) NOT NULL,
    base_cost DECIMAL(10,2) NOT NULL,
    mdn_days INT(11) NOT NULL 
);

CREATE TABLE ICD10_codes (
   icd_id VARCHAR(10) PRIMARY KEY,
   icd_description VARCHAR(100) NOT NULL,  
   icd_category VARCHAR(50) NOT NULL
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    empl_amka VARCHAR(11) NOT NULL UNIQUE,
    empl_birth_date DATE NOT NULL,
    empl_first_name VARCHAR(30) NOT NULL,
    empl_last_name VARCHAR(30) NOT NULL,
    empl_email VARCHAR(50) NOT NULL,
    empl_phone VARCHAR(15) NOT NULL,
    empl_hiring_date DATE DEFAULT (CURRENT_DATE),
    empl_type VARCHAR(25) NOT NULL, 

    CONSTRAINT chk_empl_type CHECK (empl_type IN ('doctor', 'nurse', 'administrative_staff')),
    CONSTRAINT chk_empl_amka_length CHECK (LENGTH(empl_amka) = 11)
);

CREATE TABLE shift_type (
    shift_type_id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    shift_type VARCHAR(20) NOT NULL,

    CONSTRAINT chk_shift_type CHECK (shift_type IN ('Morning', 'Afternoon', 'Night'))
);

CREATE TABLE nurse_grade (
    nurse_grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_description VARCHAR(50) NOT NULL,

    CONSTRAINT chk_nurse_grade_desc CHECK (grade_description IN ('Supervisor Nurse', 'Nurse', 'Assistant Nurse'))
);

CREATE TABLE staff_role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_description VARCHAR(50) NOT NULL,

    CONSTRAINT chk_staff_role_desc CHECK (role_description IN ('Accountant', 'Secretary', 'Director'))
);

CREATE TABLE medical_act_categories (
    act_code VARCHAR(20) PRIMARY KEY, 
    category VARCHAR(100) NOT NULL,       
    act_description TEXT NOT NULL               
);

CREATE TABLE active_substances (
    active_substance_id INT AUTO_INCREMENT PRIMARY KEY,
    substance_name VARCHAR(100) NOT NULL,
    substance_description TEXT
);

CREATE TABLE medicines (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    medication_name VARCHAR(100) NOT NULL,
    medication_route VARCHAR(100),
    medication_auth_country VARCHAR(100),
    medication_auth_holder VARCHAR(100),
    medication_file_location VARCHAR(100),
    medication_email VARCHAR(100),
    medication_number VARCHAR(50)
);

CREATE TABLE medicine_has_active_substance (
    medication_id INT NOT NULL,
    active_substance_id INT NOT NULL,
    PRIMARY KEY (medication_id, active_substance_id),

    CONSTRAINT fk_medicine_active_substance FOREIGN KEY (medication_id) REFERENCES medicines(medication_id),
    CONSTRAINT fk_active_substance_medicine FOREIGN KEY (active_substance_id) REFERENCES active_substances(active_substance_id)
);

CREATE TABLE patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    amka VARCHAR(11) NOT NULL UNIQUE,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    father_name VARCHAR(30) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    nationality VARCHAR(30) NOT NULL,
    height_cm INT NOT NULL,
    weight_kg INT NOT NULL,
    home_address VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    profession VARCHAR(50) NOT NULL,
    emergency_contact VARCHAR(100) NOT NULL,
    insurance_provider VARCHAR(30) NOT NULL,

    CONSTRAINT chk_gender CHECK (gender IN ('Male', 'Female', 'Other')),
    CONSTRAINT chk_insurance_provider CHECK (insurance_provider IN ('Public', 'Private', 'None')),
    CONSTRAINT chk_amka_length CHECK (LENGTH(amka) = 11)
);

CREATE TABLE patient_has_allergy (
    patient_id INT NOT NULL,
    active_substance_id INT NOT NULL,
    PRIMARY KEY (patient_id, active_substance_id),

    CONSTRAINT fk_patient_allergy FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    CONSTRAINT fk_allergy_patient FOREIGN KEY (active_substance_id) REFERENCES active_substances(active_substance_id)
);

CREATE TABLE doctor_grade (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_description VARCHAR(50) NOT NULL,

    CONSTRAINT chk_doctors_grade CHECK (grade_description IN ('Attending', 'Currator B', 'Currrator A', 'Chief'))
);

CREATE TABLE doctor_specialty (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(50) NOT NULL
);

CREATE TABLE doctor (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL UNIQUE,
    license_number VARCHAR(20) NOT NULL UNIQUE,
    grade_id INT NOT NULL,
    specialty_id INT NOT NULL,
    supervisor_doctor_id INT NULL,

    CONSTRAINT doctors_supervisor_check CHECK (
        (grade_id = 1 AND supervisor_doctor_id IS NOT NULL) OR
        (grade_id = 4 AND supervisor_doctor_id IS NULL) OR
        (grade_id IN (2, 3))
    ),

    CONSTRAINT fk_doctor_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_doctor_specialty FOREIGN KEY (specialty_id) REFERENCES doctor_specialty(specialty_id),
    CONSTRAINT fk_doctor_supervisor FOREIGN KEY (supervisor_doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_doctor_grade FOREIGN KEY (grade_id) REFERENCES doctor_grade(grade_id)
);

CREATE TABLE hospital_department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    dep_description TEXT,
    dep_building VARCHAR(50) NOT NULL,
    dep_floor INT NOT NULL,
    dep_total_bed INT NOT NULL DEFAULT 0,
    department_director INT NOT NULL UNIQUE,

    CONSTRAINT fk_department_director FOREIGN KEY (department_director) REFERENCES doctor(doctor_id)
);

CREATE TABLE doctor_department (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (doctor_id, department_id)
);

CREATE TABLE department_room (
    room_id INT NOT NULL,
    room_type VARCHAR(30) NOT NULL,
    room_status VARCHAR(50) NOT NULL,
    hospital_department_id INT NOT NULL,
    PRIMARY KEY (room_id, hospital_department_id),

    CONSTRAINT chk_room_type CHECK (room_type IN ('Surgery Room', 'Single Bed Patient Room', 'Multi Bed Patient Room', 'Intensive Care Unit')),
    CONSTRAINT chk_room_status CHECK (room_status IN ('Available', 'Occupied', 'Under Maintenance')),

    CONSTRAINT fk_room_department FOREIGN KEY (hospital_department_id) REFERENCES hospital_department(department_id)
);

CREATE TABLE nurse (
    nurse_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL UNIQUE,
    nurse_grade_id INT NOT NULL,
    hospital_department_id INT NOT NULL,
    supervisor_nurse_id INT NULL,

    CONSTRAINT chk_nurse_supervisor CHECK (
        (nurse_grade_id = 1 AND supervisor_nurse_id IS NULL) OR
        (nurse_grade_id <> 1 AND supervisor_nurse_id IS NOT NULL)
    ),

    CONSTRAINT fk_nurse_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_nurse_grade FOREIGN KEY (nurse_grade_id) REFERENCES nurse_grade(nurse_grade_id),
    CONSTRAINT fk_nurse_department FOREIGN KEY (hospital_department_id) REFERENCES hospital_department(department_id),
    CONSTRAINT fk_nurse_supervisor FOREIGN KEY (supervisor_nurse_id) REFERENCES nurse(nurse_id)
);

CREATE TABLE triage (
    triage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    nurse_id INT NOT NULL,
    arrival_time DATETIME DEFAULT (CURRENT_TIMESTAMP),
    emergency_level TINYINT NOT NULL,
    symptoms TEXT NOT NULL,
    outcome VARCHAR(50) NOT NULL,

    CHECK (outcome IN ('Discharge', 'Hospitalization')),
    CHECK (emergency_level BETWEEN 1 AND 5),

    CONSTRAINT fk_triage_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    CONSTRAINT fk_triage_nurse FOREIGN KEY (nurse_id) REFERENCES nurse(nurse_id)
);

CREATE TABLE hospitalization (
    hospitalization_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    triage_id INT NOT NULL,
    room_id INT NOT NULL,
    department_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME NULL,
    ICD10_admission_id VARCHAR(10) NOT NULL,
    ICD10_discharge TEXT NULL,
    ken_id INT NOT NULL,
    extra_days_cost DECIMAL(10, 2) DEFAULT 0.00,
    total_cost DECIMAL(10, 2),

    CONSTRAINT fk_hosp_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    CONSTRAINT fk_hosp_triage FOREIGN KEY (triage_id) REFERENCES triage(triage_id),
    CONSTRAINT fk_hospitalization_room FOREIGN KEY (room_id, department_id) REFERENCES department_room(room_id, hospital_department_id),
    CONSTRAINT fk_hosp_icd_adm FOREIGN KEY (ICD10_admission_id) REFERENCES ICD10_codes(icd_id),   
    CONSTRAINT fk_hosp_ken FOREIGN KEY (ken_id) REFERENCES ken_system(ken_id)
);

CREATE TABLE hospitalization_review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    hospitalization_id INT NOT NULL UNIQUE,
    medical_care TINYINT NOT NULL CHECK (medical_care BETWEEN 1 AND 5),
    nurse_care TINYINT NOT NULL CHECK (nurse_care BETWEEN 1 AND 5),
    cleanness TINYINT NOT NULL CHECK (cleanness BETWEEN 1 AND 5),
    overall_experience TINYINT NOT NULL CHECK (overall_experience BETWEEN 1 AND 5),
    food_quality TINYINT NOT NULL CHECK (food_quality BETWEEN 1 AND 5),
    review_date DATETIME DEFAULT (CURRENT_TIMESTAMP),

    CONSTRAINT fk_hosp_review_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
);

CREATE TABLE doctor_review (
    doctor_review_id INT AUTO_INCREMENT PRIMARY KEY,
    hospitalization_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medical_care TINYINT NOT NULL,
    review_date DATETIME DEFAULT (CURRENT_TIMESTAMP),
    
    CONSTRAINT chk_medical_care CHECK (medical_care BETWEEN 1 AND 5),
    CONSTRAINT unique_doctor_review UNIQUE (hospitalization_id, doctor_id),

    CONSTRAINT fk_doctor_review_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_doctor_review_patient FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id)
);

CREATE TABLE medical_act (
    act_id INT AUTO_INCREMENT PRIMARY KEY,
    act_start DATETIME NOT NULL,
    act_end DATETIME NOT NULL,
    act_duration INT AS (TIMESTAMPDIFF(MINUTE, act_start, act_end)) STORED,
    act_cost DECIMAL(10, 2) NOT NULL,
    main_surgeon_id INT NULL,
    hospitalization_id INT NOT NULL,
    department_room_id INT NOT NULL,
    department_id INT NOT NULL,
    medical_act_code VARCHAR(20) NOT NULL,

    CONSTRAINT chk_surgeon_by_code CHECK (
        ( (LEFT(medical_act_code, 1) = 'X' OR LEFT(medical_act_code, 1) = 'Χ') AND main_surgeon_id IS NOT NULL ) OR 
        ( LEFT(medical_act_code, 1) NOT IN ('X', 'Χ') AND main_surgeon_id IS NULL )
    ),

    CONSTRAINT fk_medical_act_surgeon FOREIGN KEY (main_surgeon_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_medical_act_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    CONSTRAINT fk_medical_act_room FOREIGN KEY (department_room_id, department_id) REFERENCES department_room(room_id, hospital_department_id),
    CONSTRAINT fk_medical_act_act_category FOREIGN KEY (medical_act_code) REFERENCES medical_act_categories(act_code)
);

CREATE TABLE medical_act_has_employee (
    act_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (act_id, employee_id),

    CONSTRAINT fk_act_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_act_medical_act FOREIGN KEY (act_id) REFERENCES medical_act(act_id)
);

CREATE TABLE laboratory_exam_categories (
    exam_code VARCHAR(20) PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    exam_description TEXT NOT NULL
);

CREATE TABLE laboratory_exams (
    exam_id INT AUTO_INCREMENT PRIMARY KEY,
    exam_date DATE NOT NULL,
    exam_result TEXT NOT NULL,
    doctor_id INT NOT NULL, 
    hospitalization_id INT NOT NULL,
    exam_code VARCHAR(20) NOT NULL,
    exam_cost DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_lab_exam_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_lab_exam_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    CONSTRAINT fk_lab_exam_category FOREIGN KEY (exam_code) REFERENCES laboratory_exam_categories(exam_code)
);

CREATE TABLE administrative_staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_office VARCHAR(30) NOT NULL,
    employee_id INT NOT NULL UNIQUE,
    department_id INT NOT NULL,
    role_id INT NOT NULL,

    CONSTRAINT fk_staff_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES hospital_department(department_id),
    CONSTRAINT fk_staff_role FOREIGN KEY (role_id) REFERENCES staff_role(role_id)
);

CREATE TABLE duty_schedule (             
    duty_id INT AUTO_INCREMENT PRIMARY KEY,  
    duty_date DATE NOT NULL,
    shift_type_id INT NOT NULL,
    is_finalized TINYINT DEFAULT 0,
    hospital_department_id INT NOT NULL,

    CONSTRAINT fk_duty_shift FOREIGN KEY (shift_type_id) REFERENCES shift_type(shift_type_id),
    CONSTRAINT fk_duty_department FOREIGN KEY (hospital_department_id) REFERENCES hospital_department(department_id)
);

CREATE TABLE duty_schedule_team (
    duty_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (duty_id, employee_id),

    CONSTRAINT fk_duty_team_duty FOREIGN KEY (duty_id) REFERENCES duty_schedule(duty_id),
    CONSTRAINT fk_duty_team_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE medication_prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE medication_treatment (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    hospitalization_id INT NOT NULL,
    med_prescription_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medicine_id INT NOT NULL ,

    CONSTRAINT unique_prescription_combo UNIQUE (doctor_id, patient_id, medicine_id, med_prescription_id),

    CONSTRAINT fk_med_treatment_prescription FOREIGN KEY (med_prescription_id) REFERENCES medication_prescription(prescription_id),
    CONSTRAINT fk_med_treatment_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    CONSTRAINT fk_med_treatment_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    CONSTRAINT fk_med_treatment_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_med_treatment_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(medication_id)
);

CREATE TABLE hospital_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    detailed_description TEXT, 

    doctor_id INT NULL,
    department_id INT NULL,
    medical_act_code VARCHAR(20) NULL, 
    room_id INT NULL,
    room_dept_id INT NULL,

    CONSTRAINT fk_img_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    CONSTRAINT fk_img_dept FOREIGN KEY (department_id) REFERENCES hospital_department(department_id),
    CONSTRAINT fk_img_act FOREIGN KEY (medical_act_code) REFERENCES medical_act_categories(act_code),
    CONSTRAINT fk_img_room FOREIGN KEY (room_id, room_dept_id) REFERENCES department_room(room_id, hospital_department_id)
);

CREATE OR REPLACE VIEW check_shift_completeness AS
SELECT 
    ds.duty_id,
    ds.duty_date,
    hd.department_name,
    st.shift_type AS shift_name, -- Διορθώθηκε από shift_type_name
    COUNT(DISTINCT d.doctor_id) AS doctor_count,
    COUNT(DISTINCT n.nurse_id) AS nurse_count,
    COUNT(DISTINCT adm.staff_id) AS admin_count
FROM duty_schedule ds
JOIN hospital_department hd ON ds.hospital_department_id = hd.department_id
JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
LEFT JOIN duty_schedule_team dst ON ds.duty_id = dst.duty_id
-- Σύνδεση μέσω employee_id και όχι των PK των πινάκων ρόλων
LEFT JOIN doctor d ON dst.employee_id = d.employee_id 
LEFT JOIN nurse n ON dst.employee_id = n.employee_id
LEFT JOIN administrative_staff adm ON dst.employee_id = adm.employee_id
GROUP BY ds.duty_id, ds.duty_date, hd.department_name, st.shift_type;

DROP TRIGGER IF EXISTS supervisor_nurse_check;
DROP TRIGGER IF EXISTS check_doctor_hierarchy_insert;
DROP TRIGGER IF EXISTS check_doctor_hierarchy_update;
DROP TRIGGER IF EXISTS check_dept_director_insert;
DROP TRIGGER IF EXISTS check_dept_director_update;
DROP TRIGGER IF EXISTS check_monthly_shift_limits;
DROP TRIGGER IF EXISTS validate_complete_shift;
DROP TRIGGER IF EXISTS check_8_hour_rest;
DROP TRIGGER IF EXISTS check_max_3_night_shifts;
DROP TRIGGER IF EXISTS calculate_hospitalization_cost;
DROP TRIGGER IF EXISTS check_medical_act_overlap;
DROP TRIGGER IF EXISTS check_medical_act_assistant_overlap;
DROP TRIGGER IF EXISTS prevent_allergic_prescription;
DROP TRIGGER IF EXISTS trg_hosp_integrity_check;
DROP TRIGGER IF EXISTS trg_hosp_update_check;
DROP TRIGGER IF EXISTS trg_doctor_review_bi;
DROP TRIGGER IF EXISTS trg_doctor_review_bu;
DROP TRIGGER IF EXISTS calculate_hospitalization_cost_update;
DROP TRIGGER IF EXISTS calculate_hospitalization_cost_insert;
DELIMITER //

CREATE TRIGGER supervisor_nurse_check
BEFORE INSERT ON nurse
FOR EACH ROW
BEGIN 
    DECLARE supervisor_grade INT;

    IF NEW.supervisor_nurse_id IS NOT NULL THEN
        SELECT nurse_grade_id INTO supervisor_grade FROM nurse WHERE nurse_id = NEW.supervisor_nurse_id;

        IF supervisor_grade <> 1 OR supervisor_grade IS NULL THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supervisor nurse must have grade 1';
        END IF;
    END IF;
END;


//-- TRIGGER BEFORE INSERT TO CHECK DOCTOR HIERARCHY AND PREVENT CIRCULAR SUPERVISION
CREATE TRIGGER check_doctor_hierarchy_insert
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN

    IF NEW.grade_id = 1 AND NEW.supervisor_doctor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: An Attending doctor must have a supervisor.';
    END IF;

    IF NEW.grade_id = 4 AND NEW.supervisor_doctor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: A Chief doctor cannot have a supervisor.';
    END IF;

    IF NEW.supervisor_doctor_id IS NOT NULL AND NEW.doctor_id IS NOT NULL AND NEW.supervisor_doctor_id = NEW.doctor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: A doctor cannot supervise themselves.';
    END IF;
END;
//

-- TRIGGER BEFORE UPDATE TO CHECK DOCTOR HIERARCHY AND PREVENT CIRCULAR SUPERVISION
CREATE TRIGGER check_doctor_hierarchy_update
BEFORE UPDATE ON doctor
FOR EACH ROW
BEGIN
   
    IF NEW.grade_id = 1 AND NEW.supervisor_doctor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: An Attending doctor must have a supervisor.';
    END IF;

    IF NEW.grade_id = 4 AND NEW.supervisor_doctor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: A Chief doctor cannot have a supervisor.';
    END IF;

    IF NEW.supervisor_doctor_id = NEW.doctor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: A doctor cannot supervise themselves.';
    END IF;

    IF NEW.supervisor_doctor_id IS NOT NULL AND (OLD.supervisor_doctor_id IS NULL OR NEW.supervisor_doctor_id <> OLD.supervisor_doctor_id) THEN
        IF EXISTS (
            WITH RECURSIVE supervisor_chain AS (
                -- Start with the immediate supervisor of the new doctor
                SELECT supervisor_doctor_id
                FROM doctor
                WHERE doctor_id = NEW.supervisor_doctor_id
                
                UNION ALL
                
                -- Recursively find all supervisors up the chain
                SELECT d.supervisor_doctor_id
                FROM doctor d
                INNER JOIN supervisor_chain sc ON d.doctor_id = sc.supervisor_doctor_id
                WHERE d.supervisor_doctor_id IS NOT NULL
            )
            -- If the current doctor (NEW.doctor_id) is found within the supervisor chain of the new supervisor, we have a cycle
            SELECT 1 FROM supervisor_chain WHERE supervisor_doctor_id = NEW.doctor_id
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Circular supervision detected!';
        END IF;
    END IF;
END;
//


-- TRIGGER BEFORE INSERT TO CHECK DEPARTMENT DIRECTOR'S GRADE
CREATE TRIGGER check_dept_director_insert
BEFORE INSERT ON hospital_department
FOR EACH ROW
BEGIN
    DECLARE doctor_grade_val INT;

    SELECT grade_id INTO doctor_grade_val
    FROM doctor
    WHERE doctor_id = NEW.department_director;

    -- Director must be Chief (grade_id = 4) and cannot be null
    IF doctor_grade_val <> 4 OR doctor_grade_val IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = ' Error: The department director must have the grade "Chief".';
    END IF;
END;
//

-- TRIGGER BEFORE UPDATE TO CHECK DEPARTMENT DIRECTOR'S GRADE
CREATE TRIGGER check_dept_director_update
BEFORE UPDATE ON hospital_department
FOR EACH ROW
BEGIN
    DECLARE doctor_grade_val INT;

    -- The check runs only if the director is changed
    IF NEW.department_director <> OLD.department_director THEN
        SELECT grade_id INTO doctor_grade_val
        FROM doctor
        WHERE doctor_id = NEW.department_director;

        IF doctor_grade_val <> 4 OR doctor_grade_val IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = ' Error: The new department director must have the grade "Chief".';
        END IF;
    END IF;
END;
//

CREATE TRIGGER check_monthly_shift_limits
BEFORE INSERT ON duty_schedule_team
FOR EACH ROW
BEGIN
    DECLARE shift_month INT;
    DECLARE shift_year INT;
    DECLARE current_shifts INT;
    DECLARE emp_type VARCHAR(25);

    -- Find the month and year of the shift being assigned
    SELECT MONTH(duty_date), YEAR(duty_date) INTO shift_month, shift_year
    FROM duty_schedule 
    WHERE duty_id = NEW.duty_id;

    -- Find the employee type (doctor, nurse, administrative_staff)
    SELECT empl_type INTO emp_type
    FROM employee 
    WHERE employee_id = NEW.employee_id;

    -- Count the number of shifts the employee has already worked in the same month/year
    SELECT COUNT(*) INTO current_shifts
    FROM duty_schedule_team dst
    JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
    WHERE dst.employee_id = NEW.employee_id
      AND MONTH(ds.duty_date) = shift_month
      AND YEAR(ds.duty_date) = shift_year;

    -- Check against the limits based on employee type
    IF emp_type = 'doctor' AND current_shifts >= 15 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: The doctor has already reached the monthly limit of 15 shifts.';
        
    ELSEIF emp_type = 'nurse' AND current_shifts >= 20 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: The nurse has already reached the monthly limit of 20 shifts.';
        
    ELSEIF emp_type = 'administrative_staff' AND current_shifts >= 25 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: The administrative staff member has already reached the monthly limit of 25 shifts.';
    END IF;
END;
//

CREATE TRIGGER validate_complete_shift
BEFORE UPDATE ON duty_schedule
FOR EACH ROW
BEGIN
    DECLARE doc_count INT;
    DECLARE nurse_count INT;
    DECLARE admin_count INT;
    DECLARE intern_count INT;
    DECLARE senior_count INT;

    -- Ελέγχουμε μόνο αν η κατάσταση αλλάζει από 0 (Draft) σε 1 (Finalized)
    IF NEW.is_finalized = 1 AND OLD.is_finalized = 0 THEN
        
        -- 1. Μετράμε όλες τις κατηγορίες από τον πίνακα της ομάδας
        SELECT 
            COUNT(CASE WHEN e.empl_type = 'doctor' THEN 1 END),
            COUNT(CASE WHEN e.empl_type = 'nurse' THEN 1 END),
            COUNT(CASE WHEN e.empl_type = 'administrative_staff' THEN 1 END),
            COUNT(CASE WHEN d.grade_id = 1 THEN 1 END), -- Ειδικευόμενοι
            COUNT(CASE WHEN d.grade_id IN (3, 4) THEN 1 END) -- Επιμελητές/Διευθυντές
        INTO doc_count, nurse_count, admin_count, intern_count, senior_count
        FROM duty_schedule_team dst
        JOIN employee e ON dst.employee_id = e.employee_id
        LEFT JOIN doctor d ON e.employee_id = d.doctor_id
        WHERE dst.duty_id = NEW.duty_id;

        -- 2. Εφαρμογή Κανόνα: Ελάχιστο Προσωπικό (3-6-2)
        IF doc_count < 3 OR nurse_count < 6 OR admin_count < 2 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ελλιπές προσωπικό (Απαιτούνται: 3 Γιατροί, 6 Νοσηλευτές, 2 Διοικητικοί).';
        END IF;

        -- 3. Εφαρμογή Κανόνα: Επίβλεψη Ειδικευόμενου
        IF intern_count > 0 AND senior_count = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Υπάρχει Ειδικευόμενος χωρίς Επιμελητή ή Διευθυντή!';
        END IF;
        
    END IF;
END;
//

CREATE TRIGGER check_8_hour_rest
BEFORE INSERT ON duty_schedule_team
FOR EACH ROW
BEGIN
    DECLARE n_start DATETIME;
    DECLARE n_end DATETIME;

    SELECT 
        ADDTIME(CONVERT(ds.duty_date, DATETIME), st.start_time),
        IF(st.end_time < st.start_time, 
           ADDTIME(CONVERT(DATE_ADD(ds.duty_date, INTERVAL 1 DAY), DATETIME), st.end_time), 
           ADDTIME(CONVERT(ds.duty_date, DATETIME), st.end_time)
        )
    INTO n_start, n_end
    FROM duty_schedule ds
    JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
    WHERE ds.duty_id = NEW.duty_id;

    IF EXISTS (
        SELECT 1
        FROM duty_schedule_team dst
        JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
        JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
        WHERE dst.employee_id = NEW.employee_id
        AND (
            ADDTIME(CONVERT(ds.duty_date, DATETIME), st.start_time) < DATE_ADD(n_end, INTERVAL 8 HOUR)
            AND 
            IF(st.end_time < st.start_time, 
               ADDTIME(CONVERT(DATE_ADD(ds.duty_date, INTERVAL 1 DAY), DATETIME), st.end_time), 
               ADDTIME(CONVERT(ds.duty_date, DATETIME), st.end_time)
            ) > DATE_SUB(n_start, INTERVAL 8 HOUR)
        )
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Πρέπει να μεσολαβούν τουλάχιστον 8 ώρες ανάπαυσης μεταξύ των βαρδιών του υπαλλήλου!';
    END IF;
END;
//

CREATE TRIGGER check_max_3_night_shifts
BEFORE INSERT ON duty_schedule_team
FOR EACH ROW
BEGIN
    DECLARE new_shift_desc VARCHAR(20);
    DECLARE new_date DATE;
    DECLARE d_m1 INT DEFAULT 0;
    DECLARE d_m2 INT DEFAULT 0;
    DECLARE d_m3 INT DEFAULT 0;
    DECLARE d_p1 INT DEFAULT 0;
    DECLARE d_p2 INT DEFAULT 0;
    DECLARE d_p3 INT DEFAULT 0;

    SELECT st.shift_type, ds.duty_date INTO new_shift_desc, new_date
    FROM duty_schedule ds
    JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
    WHERE ds.duty_id = NEW.duty_id;

    IF new_shift_desc = 'Night' THEN
        SELECT 
            MAX(CASE WHEN ds.duty_date = DATE_SUB(new_date, INTERVAL 1 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.duty_date = DATE_SUB(new_date, INTERVAL 2 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.duty_date = DATE_SUB(new_date, INTERVAL 3 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.duty_date = DATE_ADD(new_date, INTERVAL 1 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.duty_date = DATE_ADD(new_date, INTERVAL 2 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.duty_date = DATE_ADD(new_date, INTERVAL 3 DAY) THEN 1 ELSE 0 END)
        INTO d_m1, d_m2, d_m3, d_p1, d_p2, d_p3
        FROM duty_schedule_team dst
        JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
        JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
        WHERE dst.employee_id = NEW.employee_id 
          AND st.shift_type = 'Night'
          AND ds.duty_date BETWEEN DATE_SUB(new_date, INTERVAL 3 DAY) AND DATE_ADD(new_date, INTERVAL 3 DAY);

        IF (d_m3 = 1 AND d_m2 = 1 AND d_m1 = 1) OR
           (d_m2 = 1 AND d_m1 = 1 AND d_p1 = 1) OR
           (d_m1 = 1 AND d_p1 = 1 AND d_p2 = 1) OR
           (d_p1 = 1 AND d_p2 = 1 AND d_p3 = 1) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Απαγορεύεται η συμμετοχή σε περισσότερες από 3 συνεχόμενες νυχτερινές βάρδιες!';
        END IF;
    END IF;
END;
//


CREATE TRIGGER calculate_hospitalization_cost_insert
BEFORE INSERT ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE base_cost_val DECIMAL(10,2);
    DECLARE mdn_val INT;
    DECLARE actual_days INT;
    DECLARE extra_days_count INT;
    DECLARE daily_rate DECIMAL(10,2);
    DECLARE extra_charge DECIMAL(10,2) DEFAULT 0;
    DECLARE exams_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE acts_cost DECIMAL(10,2) DEFAULT 0;

    -- Αν η νοσηλεία εισάγεται ήδη ολοκληρωμένη (π.χ. από Dummy Data)
    IF NEW.discharge_date IS NOT NULL THEN

        -- 1. Ανάκτηση στοιχείων ΚΕΝ
        SELECT base_cost, mdn_days INTO base_cost_val, mdn_val
        FROM ken_system WHERE ken_id = NEW.ken_id;

        -- 2. Υπολογισμός ημερών
        SET actual_days = DATEDIFF(NEW.discharge_date, NEW.admission_date);
        IF actual_days <= 0 THEN 
            SET actual_days = 1; 
        END IF;

        -- 3. Υπολογισμός υπέρβασης ΜΔΝ
        SET extra_days_count = GREATEST(actual_days - mdn_val, 0);
        
        IF mdn_val > 0 THEN
            SET daily_rate = base_cost_val / mdn_val;
        ELSE
            SET daily_rate = 0;
        END IF;
        
        SET extra_charge = daily_rate * extra_days_count;

        -- Σημείωση: Στο INSERT, αν τα δεδομένα μπαίνουν για πρώτη φορά, 
        -- οι παρακάτω SELECT θα φέρουν 0 γιατί δεν υπάρχουν ακόμα εγγραφές 
        -- που να συνδέονται με το (νέο) hospitalization_id.
        
        -- 4. Κόστος Εξετάσεων
        SELECT COALESCE(SUM(exam_cost), 0) INTO exams_cost
        FROM laboratory_exams
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 5. Κόστος Πράξεων
        SELECT COALESCE(SUM(act_cost), 0) INTO acts_cost
        FROM medical_act
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 6. Ενημέρωση των νέων στηλών
        SET NEW.extra_days_cost = extra_charge;
        SET NEW.total_cost = base_cost_val + extra_charge;
        
    END IF;
END;
//

CREATE TRIGGER calculate_hospitalization_cost_update
BEFORE UPDATE ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE base_cost_val DECIMAL(10,2);
    DECLARE mdn_val INT;
    DECLARE actual_days INT;
    DECLARE extra_days_count INT;
    DECLARE daily_rate DECIMAL(10,2);
    DECLARE extra_charge DECIMAL(10,2) DEFAULT 0;
    DECLARE exams_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE acts_cost DECIMAL(10,2) DEFAULT 0;

    -- Έλεγχος: Ενεργοποίηση μόνο όταν ο ασθενής παίρνει εξιτήριο (από NULL σε NOT NULL)
    IF NEW.discharge_date IS NOT NULL AND OLD.discharge_date IS NULL THEN

        -- 1. Ανάκτηση στοιχείων ΚΕΝ (Βασικό κόστος και Μέση Διάρκεια Νοσηλείας)
        SELECT base_cost, mdn_days INTO base_cost_val, mdn_val
        FROM ken_system WHERE ken_id = NEW.ken_id;

        -- 2. Υπολογισμός πραγματικών ημερών (DATEDIFF)
        SET actual_days = DATEDIFF(NEW.discharge_date, NEW.admission_date);
        IF actual_days <= 0 THEN
            SET actual_days = 1; -- Ελάχιστη χρέωση 1 ημέρα
        END IF;

        -- 3. Υπολογισμός αναλογικής χρέωσης υπέρβασης ΜΔΝ
        SET extra_days_count = GREATEST(actual_days - mdn_val, 0);
        
        -- Αποφυγή διαίρεσης με το μηδέν (Zero check)
        IF mdn_val > 0 THEN
            SET daily_rate = base_cost_val / mdn_val;
        ELSE
            SET daily_rate = 0;
        END IF;
        
        SET extra_charge = daily_rate * extra_days_count;

        -- 4. Συλλογή κόστους από Εργαστηριακές Εξετάσεις
        SELECT COALESCE(SUM(exam_cost), 0) INTO exams_cost
        FROM laboratory_exams
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 5. Συλλογή κόστους από Ιατρικές Πράξεις / Επεμβάσεις
        SELECT COALESCE(SUM(act_cost), 0) INTO acts_cost
        FROM medical_act
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 6. Ενημέρωση των νέων πεδίων του πίνακα
        -- α) Το έξτρα κόστος μόνο των ημερών
        SET NEW.extra_days_cost = extra_charge;
        
        -- β) Συνολικό κόστος νοσηλείας (ΚΕΝ + Έξτρα ημέρες)
        SET NEW.total_cost = base_cost_val + extra_charge;
        
    END IF;
END;
//

    
CREATE TRIGGER check_medical_act_overlap
BEFORE INSERT ON medical_act
FOR EACH ROW
BEGIN
    -- 1. Έλεγχος για ίδια αίθουσα ταυτόχρονα
    IF EXISTS (
        SELECT 1 FROM medical_act
        WHERE department_room_id = NEW.department_room_id
          AND department_id = NEW.department_id
          AND act_start < NEW.act_end 
          AND act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Η αίθουσα χρησιμοποιείται ήδη σε άλλη επέμβαση.';
    END IF;

    -- 2. Έλεγχος αν ο Κύριος Χειρουργός είναι ήδη Κύριος Χειρουργός αλλού
    IF EXISTS (
        SELECT 1 FROM medical_act
        WHERE main_surgeon_id = NEW.main_surgeon_id
          AND act_start < NEW.act_end 
          AND act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο ιατρός είναι ήδη κύριος χειρουργός σε άλλη επέμβαση.';
    END IF;

    -- 3. ΕΞΤΡΑ ΕΛΕΓΧΟΣ: Μήπως ο Κύριος Χειρουργός είναι βοηθός σε άλλη επέμβαση;
    IF EXISTS (
        SELECT 1 
        FROM medical_act_has_employee mae
        JOIN medical_act ma ON mae.act_id = ma.act_id
        JOIN doctor d ON mae.employee_id = d.employee_id
        WHERE d.doctor_id = NEW.main_surgeon_id
          AND ma.act_start < NEW.act_end 
          AND ma.act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο κύριος χειρουργός συμμετέχει ήδη ως βοηθός σε άλλη επέμβαση.';
    END IF;
END;
//

CREATE TRIGGER check_medical_act_assistant_overlap
BEFORE INSERT ON medical_act_has_employee
FOR EACH ROW
BEGIN
    DECLARE new_start DATETIME;
    DECLARE new_end DATETIME;

    SELECT act_start, act_end INTO new_start, new_end
    FROM medical_act WHERE act_id = NEW.act_id;

    -- Έλεγχος αν ο υπάλληλος είναι ήδη βοηθός αλλού
    IF EXISTS (
        SELECT 1 
        FROM medical_act_has_employee mae
        JOIN medical_act ma ON mae.act_id = ma.act_id
        WHERE mae.employee_id = NEW.employee_id
          AND ma.act_start < new_end 
          AND ma.act_end > new_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο υπάλληλος συμμετέχει ήδη ως βοηθός σε άλλη ταυτόχρονη επέμβαση.';
    END IF;

    -- Έλεγχος αν ο υπάλληλος είναι κύριος χειρουργός αλλού
    IF EXISTS (
        SELECT 1 
        FROM medical_act ma
        JOIN doctor d ON ma.main_surgeon_id = d.doctor_id
        WHERE d.employee_id = NEW.employee_id
          AND ma.act_start < new_end 
          AND ma.act_end > new_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο υπάλληλος είναι κύριος χειρουργός σε άλλη ταυτόχρονη επέμβαση.';
    END IF;
END;
//

CREATE TRIGGER prevent_allergic_prescription
BEFORE INSERT ON medication_treatment
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM medicine_has_active_substance mhas
        JOIN patient_has_allergy pha ON mhas.active_substance_id = pha.active_substance_id
        WHERE mhas.medication_id = NEW.medicine_id 
          AND pha.patient_id = NEW.patient_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΑΚΥΡΩΣΗ: Ο ασθενής είναι αλλεργικός σε δραστική ουσία αυτού του φαρμάκου';
    END IF;
END;
//

CREATE TRIGGER trg_check_discharge_before_review
BEFORE INSERT ON hospitalization_review
FOR EACH ROW
BEGIN
    DECLARE v_discharge_date DATETIME;

    -- Βρίσκουμε την ημερομηνία εξιτηρίου για τη συγκεκριμένη νοσηλεία
    SELECT discharge_date INTO v_discharge_date
    FROM hospitalization
    WHERE hospitalization_id = NEW.hospitalization_id;

    -- Αν η ημερομηνία είναι NULL, σημαίνει ότι ο ασθενής νοσηλεύεται ακόμα
    IF v_discharge_date IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Δεν μπορεί να προστεθεί αξιολόγηση. Η νοσηλεία δεν έχει ολοκληρωθεί (το discharge_date είναι NULL).';
    END IF;
END//


CREATE TRIGGER trg_doctor_review_bi
BEFORE INSERT ON doctor_review
FOR EACH ROW
BEGIN
    DECLARE v_discharge_date DATETIME;
    DECLARE v_admission_date DATETIME;
    DECLARE v_patient_id INT;
    DECLARE v_has_prescription INT;

    -- 1. Ανάκτηση ημερομηνιών και ID ασθενή από τη νοσηλεία (όλα μαζί για ταχύτητα)
    SELECT discharge_date, admission_date, patient_id 
    INTO v_discharge_date, v_admission_date, v_patient_id
    FROM hospitalization 
    WHERE hospitalization_id = NEW.hospitalization_id;

    -- 2. Έλεγχος αν η νοσηλεία έχει ολοκληρωθεί
    IF v_discharge_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Σφάλμα: Η αξιολόγηση ιατρού επιτρέπεται μόνο μετά το εξιτήριο.';
    END IF;

    -- 3. Έλεγχος αν ο γιατρός έχει συνταγογραφήσει στον συγκεκριμένο ασθενή 
    --    ΚΑΤΑ ΤΗ ΔΙΑΡΚΕΙΑ ΑΥΤΗΣ ΤΗΣ ΝΟΣΗΛΕΙΑΣ
    SELECT COUNT(*) INTO v_has_prescription
    FROM medication_treatment mt
    JOIN medication_prescription mp ON mt.med_prescription_id = mp.prescription_id
    WHERE mt.doctor_id = NEW.doctor_id 
      AND mt.patient_id = v_patient_id
      AND mp.start_date >= DATE(v_admission_date)
      AND mp.start_date <= DATE(v_discharge_date);

    IF v_has_prescription = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Σφάλμα: Ο ασθενής μπορεί να αξιολογήσει μόνο ιατρούς που του έχουν συνταγογραφήσει φάρμακα κατά τη νοσηλεία.';
    END IF;
END //

CREATE TRIGGER force_draft_on_insert
BEFORE INSERT ON duty_schedule
FOR EACH ROW
BEGIN
    -- Ακόμα και αν ο χρήστης γράψει 1, εμείς το γυρίζουμε σε 0
    SET NEW.is_finalized = 0;
END;
//

CREATE TRIGGER trg_doctor_review_bu
BEFORE UPDATE ON doctor_review
FOR EACH ROW
BEGIN
    DECLARE v_discharge_date DATETIME;
    DECLARE v_admission_date DATETIME;
    DECLARE v_patient_id INT;
    DECLARE v_has_prescription INT;

    -- Εκτελούμε τους "βαρείς" ελέγχους ΜΟΝΟ αν αλλάξει η νοσηλεία ή ο ιατρός
    IF NEW.hospitalization_id <> OLD.hospitalization_id 
       OR NEW.doctor_id <> OLD.doctor_id THEN
        
        -- 1. Ανάκτηση στοιχείων για τη (νέα) νοσηλεία
        SELECT discharge_date, admission_date, patient_id 
        INTO v_discharge_date, v_admission_date, v_patient_id
        FROM hospitalization 
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 2. Έλεγχος ολοκλήρωσης νοσηλείας
        IF v_discharge_date IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Σφάλμα: Δεν μπορείτε να συνδέσετε την αξιολόγηση με μια ανοιχτή νοσηλεία.';
        END IF;

        -- 3. Έλεγχος συνταγογράφησης ΚΑΤΑ ΤΗ ΔΙΑΡΚΕΙΑ ΑΥΤΗΣ ΤΗΣ ΝΟΣΗΛΕΙΑΣ
        SELECT COUNT(*) INTO v_has_prescription
        FROM medication_treatment mt
        JOIN medication_prescription mp ON mt.med_prescription_id = mp.prescription_id
        WHERE mt.doctor_id = NEW.doctor_id 
          AND mt.patient_id = v_patient_id
          AND mp.start_date >= v_admission_date
          AND mp.start_date <= v_discharge_date;

        IF v_has_prescription = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Σφάλμα: Ο επιλεγμένος ιατρός δεν έχει συνταγογραφήσει θεραπεία για αυτόν τον ασθενή κατά τη νοσηλεία.';
        END IF;
        
    END IF;
END //

DELIMITER ;