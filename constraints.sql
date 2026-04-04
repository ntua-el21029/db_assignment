USE hospital_db;

SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE nurse 
    ADD CONSTRAINT fk_nurse_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    ADD CONSTRAINT fk_nurse_grade FOREIGN KEY (nurse_grade_id) REFERENCES nurse_grade(nurse_grade_id),
    ADD CONSTRAINT fk_nurse_department FOREIGN KEY (hospital_department_id) REFERENCES hospital_department(department_id),
    ADD CONSTRAINT fk_nurse_supervisor FOREIGN KEY (supervisor_nurse_id) REFERENCES nurse(nurse_id),

    ADD CONSTRAINT check_supervisor_logic CHECK (
        (nurse_grade_id = 1 AND supervisor_nurse_id IS NULL) OR
        (nurse_grade_id <> 1 AND supervisor_nurse_id IS NOT NULL)
    );


ALTER TABLE administrative_staff
    ADD CONSTRAINT fk_staff_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    ADD CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES hospital_department(department_id),
    ADD CONSTRAINT fk_staff_role FOREIGN KEY (role_id) REFERENCES staff_role(role_id);


ALTER TABLE hospital_department
    ADD CONSTRAINT fk_department_director FOREIGN KEY (department_director) REFERENCES doctor(doctor_id);


ALTER TABLE department_room
    ADD CONSTRAINT fk_room_department FOREIGN KEY (hospital_department_id) REFERENCES hospital_department(department_id);


ALTER TABLE duty_schedule
    ADD CONSTRAINT fk_duty_shift FOREIGN KEY (shift_type_id) REFERENCES shift_type(shift_type_id),
    ADD CONSTRAINT fk_duty_department FOREIGN KEY (hospital_department_id) REFERENCES hospital_department(department_id);


ALTER TABLE triage
    ADD CONSTRAINT fk_triage_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_triage_nurse FOREIGN KEY (nurse_id) REFERENCES nurse(nurse_id);


ALTER TABLE medication_treatment
    ADD CONSTRAINT fk_med_treatment_prescription FOREIGN KEY (med_prescription_id) REFERENCES medication_prescription(prescription_id),
    ADD CONSTRAINT fk_med_treatment_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_med_treatment_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    ADD CONSTRAINT fk_med_treatment_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id);


ALTER TABLE hospitalization 
    ADD CONSTRAINT fk_hosp_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_hosp_triage FOREIGN KEY (triage_id) REFERENCES triage(triage_id),
    ADD CONSTRAINT fk_hospitalization_room FOREIGN KEY (room_id, department_id) REFERENCES department_room(room_id, hospital_department_id),

    ADD CONSTRAINT fk_hosp_icd_adm FOREIGN KEY (icd10_admission_id) REFERENCES icd10_codes(id),
    ADD CONSTRAINT fk_hosp_icd_dis FOREIGN KEY (icd10_discharge_id) REFERENCES icd10_codes(id),

    ADD CONSTRAINT fk_hosp_ken FOREIGN KEY (ken_id) REFERENCES ken_system(ken_id),
    ADD CONSTRAINT fk_hosp_review FOREIGN KEY (review_id) REFERENCES review(review_id);


ALTER TABLE laboratory_exams
    ADD CONSTRAINT fk_lab_exam_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    ADD CONSTRAINT fk_lab_exam_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    ADD CONSTRAINT fk_lab_exam_act FOREIGN KEY (act_code) REFERENCES medical_act_categories(act_code);

ALTER TABLE medical_act
    ADD CONSTRAINT fk_medical_act_surgeon FOREIGN KEY (main_surgeon_id) REFERENCES doctor(doctor_id),
    ADD CONSTRAINT fk_medical_act_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    ADD CONSTRAINT fk_medical_act_department_room FOREIGN KEY (department_room_id) REFERENCES department_room(room_id),
    ADD CONSTRAINT fk_medical_act_nurse FOREIGN KEY (nurse_id) REFERENCES nurse(nurse_id),
    ADD CONSTRAINT fk_medical_docto_support FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id)
    ADD CONSTRAINT fk_medical_act_act_category FOREIGN KEY (act_code) REFERENCES medical_act_categories(act_code);




SET FOREIGN_KEY_CHECKS = 1;
