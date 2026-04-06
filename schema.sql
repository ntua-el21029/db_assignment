DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE ken_system (
    ken_id INT AUTO_INCREMENT PRIMARY KEY,
    ken_code VARCHAR(20) NOT NULL
);

CREATE TABLE ICD10_codes (
   icd_id VARCHAR(10) PRIMARY KEY,
   icd_description VARCHAR(50) NOT NULL,  
   icd_category VARCHAR(50) NULL
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    empl_first_name VARCHAR(30) NOT NULL,
    empl_last_name VARCHAR(30) NOT NULL,
    empl_email VARCHAR(50) NOT NULL,
    empl_phone VARCHAR(15) NOT NULL,
    empl_hiring_date DATE DEFAULT (CURRENT_DATE),
    empl_type ENUM('doctor', 'nurse', 'administrative_staff') NOT NULL
);


CREATE TABLE hospital_department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    dep_description TEXT,
    dep_building VARCHAR(50) NOT NULL,
    dep_floor INT NOT NULL,
    department_director INT NOT NULL
);

CREATE TABLE shift_type (
    shift_type_id INT AUTO_INCREMENT PRIMARY KEY,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    shift_description ENUM ('Morning', 'Afternoon', 'Night') NOT NULL
);

CREATE TABLE duty_schedule (             -- xreiazetai kai thn omada proswpikou ths vardias pou leipei
    duty_id INT AUTO_INCREMENT PRIMARY KEY,  --  ara prepei na ftiaxtei meta ton doctor
    date DATE NOT NULL,
    shift_type_id INT NOT NULL,
    hospital_department_id INT NOT NULL
);

CREATE TABLE duty_schedule_team (
    duty_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (duty_id, employee_id)
);

CREATE TABLE department_room (
    room_id INT NOT NULL,
    roo_type ENUM('Surgery Room', 'Patient Room') NOT NULL,
    room_status ENUM('Available', 'Occupied', 'Under Maintenance') NOT NULL,
    hospital_department_id INT NOT NULL,

    PRIMARY KEY (room_id, hospital_department_id)
);

CREATE TABLE nurse_grade (
    nurse_grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_description ENUM('Supervisor Nurse', 'Nurse', 'Assistant Nurse') NOT NULL
);

CREATE TABLE nurse (
    nurse_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    nurse_grade_id INT NOT NULL,
    hospital_department_id INT NOT NULL,
    supervisor_nurse_id INT NULL
);


CREATE TABLE staff_role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_description ENUM('Accountant', 'Secretary', 'Director')
);

CREATE TABLE administrative_staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_office VARCHAR(30) NOT NULL,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    role_id INT NOT NULL
);

CREATE TABLE triage (
    triage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    nurse_id INT NOT NULL,
    arrival_time DATETIME DEFAULT (CURRENT_TIMESTAMP),
    emergency_level TINYINT NOT NULL,
    symptoms TEXT NOT NULL,
    outcome ENUM('Hospitalization', 'Discharge') NOT NULL,

    CHECK (emergency_level BETWEEN 1 AND 5)
);

CREATE TABLE patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    amka INT NOT NULL UNIQUE,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    father_name VARCHAR(30) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    nationality VARCHAR(30) NOT NULL,
    height_cm INT NOT NULL,
    weight_kg INT NOT NULL,
    home_address VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    profession VARCHAR(50) NOT NULL,
    emergency_contact VARCHAR(100) NOT NULL,
    insurance_provider ENUM('Public', 'Private', 'None') NOT NULL
);


CREATE TABLE medication_treatment (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    med_prescription_id INT NOT NULL,
    doctor_id INT NOT NULL,
    medicine_id INT NOT NULL
);

CREATE TABLE medication_prescription (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
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
    ICD10_discharge_id VARCHAR(10) NULL,
    ken_id INT NOT NULL,
    extra_cost DECIMAL(10, 2) DEFAULT 0.00,
    total_cost DECIMAL(10, 2),
    review_id INT NULL
);

CREATE TABLE review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    medical_care TINYINT NOT NULL CHECK (medical_care BETWEEN 1 AND 5),
    nurse_care TINYINT NOT NULL CHECK (nurse_care BETWEEN 1 AND 5),
    cleanness TINYINT NOT NULL CHECK (cleanness BETWEEN 1 AND 5),
    overall_experience TINYINT NOT NULL CHECK (overall_experience BETWEEN 1 AND 5),
    food_quality TINYINT NOT NULL CHECK (food_quality BETWEEN 1 AND 5)
);

CREATE TABLE medical_act_categories (
    act_code VARCHAR(20) PRIMARY KEY, 
    category CHAR(1) NOT NULL,       
    act_description TEXT NOT NULL               
);

CREATE TABLE laboratory_exams(
    exam_id INT AUTO_INCREMENT PRIMARY KEY,
    exam_date DATE NOT NULL,
    exam_result TEXT NOT NULL,
    doctor_id INT NOT NULL, 
    hospitalization_id INT NOT NULL,
    act_code VARCHAR(20) NOT NULL
);

CREATE TABLE medical_act (
    act_id INT AUTO_INCREMENT PRIMARY KEY,
    act_start DATETIME NOT NULL,
    act_end DATETIME NOT NULL,
    act_duration INT AS (TIMESTAMPDIFF(MINUTE, act_start, act_end)) STORED,
    act_cost DECIMAL(10, 2) NOT NULL,
    main_surgeon_id INT NOT NULL,
    hospitalization_id INT NOT NULL,
    department_room_id INT NOT NULL,
    department_id INT NOT NULL,
    medical_act_code VARCHAR(20) NOT NULL
);

CREATE TABLE medicines (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    medication_name VARCHAR(100) NOT NULL,
    medication_route VARCHAR(45),
    medication_auth_country VARCHAR(45),
    medication_auth_holder VARCHAR(100),
    medication_file_location VARCHAR(255),
    medication_email VARCHAR(100),
    medication_number VARCHAR(50)
);

CREATE TABLE medical_act_has_employee (
    act_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (act_id, employee_id)
);

CREATE TABLE medicine_has_active_substance (
    medication_id INT NOT NULL,
    active_substance_id INT NOT NULL,
    PRIMARY KEY (medication_id, active_substance_id)
);

CREATE TABLE active_substances (
    active_substance_id INT AUTO_INCREMENT PRIMARY KEY,
    substance_name VARCHAR(100) NOT NULL,
    substance_description TEXT
);

CREATE TABLE patient_has_allergy (
    patient_id INT NOT NULL,
    active_substance_id INT NOT NULL,
    PRIMARY KEY (patient_id, active_substance_id)
);

CREATE TABLE doctor_grade (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_description ENUM('Attending', 'Currator B', 'Currrator A', 'Chief') NOT NULL
);

CREATE TABLE doctor_specialty (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(50) NOT NULL
);

CREATE TABLE doctor_department (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (doctor_id, department_id)
);

CREATE TABLE doctor (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    grade_id INT NOT NULL,
    specialty_id INT NOT NULL,
    supervisor_doctor_id INT NULL 
);
