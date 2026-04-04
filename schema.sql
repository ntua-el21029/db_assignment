DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE ken_system (
    ken_id INT AUTO_INCREMENT PRIMARY KEY,
    ken_code VARCHAR(20) NOT NULL,

);

CREATE TABLE ICD10_codes (
   icd_id VARCHAR(10) PRIMARY KEY,
   icd_description VARCHAR(50) NOT NULL   
   icd_category VARCHAR(50) NULL
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY AYTO_INCREMENT,
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
    dep_floor INT NOT NULL
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

CREATE TABLE department_room (
    room_id INT NOT NULL,
    roo_type VARCHAR(45) NOT NULL,
    room_status ENUM('Available', 'Occupied', 'Under Maintenance') NOT NULL,
    hospital_department_id INT NOT NULL,

    PRIMARY KEY (room_id, hospital_department_id)
);

CREATE TABLE nurse_grade (
    nurse_grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_description ENUM('Assistant Nurse', 'Nurse', 'Supervisor Nurse') NOT NULL
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
    insurance_provider VARCHAR(50) NOT NULL
);


CREATE TABLE medication_treatment (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT AUTO_INCREMENT PRIMARY KEY
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
    ICD10_admission_id INT NOT NULL,
    ICD10_discharge_id INT NULL,
    ken_id INT NOT NULL,
    extra_cost DECIMAL(10, 2) DEFAULT 0.00
    total_cost DECIMAL(10, 2),
    review_id INT NULL
);

CREATE TABLE medicines (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    medication_name VARCHAR(100) NOT NULL,
    medication_route VARCHAR(45),
    medication_auth_country VARCHAR(45),
    medication_auth_holder VARCHAR(100),
    medication_file_location VARCHAR(255),
    medication_email VARCHAR(100),
    medication_number VARCHAR(50),
    med_treatment_treatment_id INT,
);

