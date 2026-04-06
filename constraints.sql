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

ALTER TABLE duty_schedule_team
    ADD CONSTRAINT fk_duty_team_duty FOREIGN KEY (duty_id) REFERENCES duty_schedule(duty_id),
    ADD CONSTRAINT fk_duty_team_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id);


ALTER TABLE triage
    ADD CONSTRAINT fk_triage_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_triage_nurse FOREIGN KEY (nurse_id) REFERENCES nurse(nurse_id);


ALTER TABLE medication_treatment
    ADD CONSTRAINT fk_med_treatment_prescription FOREIGN KEY (med_prescription_id) REFERENCES medication_prescription(prescription_id),
    ADD CONSTRAINT fk_med_treatment_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_med_treatment_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    ADD CONSTRAINT fk_med_treatment_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(medication_id);


ALTER TABLE hospitalization 
    ADD CONSTRAINT fk_hosp_patient FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_hosp_triage FOREIGN KEY (triage_id) REFERENCES triage(triage_id),
    ADD CONSTRAINT fk_hospitalization_room FOREIGN KEY (room_id, department_id) REFERENCES department_room(room_id, hospital_department_id),

    ADD CONSTRAINT fk_hosp_icd_adm FOREIGN KEY (ICD10_admission_id) REFERENCES ICD10_codes(icd_id),
    ADD CONSTRAINT fk_hosp_icd_dis FOREIGN KEY (ICD10_discharge_id) REFERENCES ICD10_codes(icd_id),

    ADD CONSTRAINT fk_hosp_ken FOREIGN KEY (ken_id) REFERENCES ken_system(ken_id),
    ADD CONSTRAINT fk_hosp_review FOREIGN KEY (review_id) REFERENCES review(review_id);


ALTER TABLE laboratory_exams
    ADD CONSTRAINT fk_lab_exam_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id),
    ADD CONSTRAINT fk_lab_exam_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    ADD CONSTRAINT fk_lab_exam_act FOREIGN KEY (act_code) REFERENCES medical_act_categories(act_code);

ALTER TABLE medical_act
    ADD CONSTRAINT fk_medical_act_surgeon FOREIGN KEY (main_surgeon_id) REFERENCES doctor(doctor_id),
    ADD CONSTRAINT fk_medical_act_hospitalization FOREIGN KEY (hospitalization_id) REFERENCES hospitalization(hospitalization_id),
    ADD CONSTRAINT fk_medical_act_room FOREIGN KEY (department_room_id, department_id) REFERENCES department_room(room_id, hospital_department_id),
    ADD CONSTRAINT fk_medical_act_act_category FOREIGN KEY (medical_act_code) REFERENCES medical_act_categories(act_code);

ALTER TABLE medical_act_has_employee
    ADD CONSTRAINT fk_act_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    ADD CONSTRAINT fk_act_medical_act FOREIGN KEY (act_id) REFERENCES medical_act(act_id);

ALTER TABLE medicine_has_active_substance
    ADD CONSTRAINT fk_medicine_active_substance FOREIGN KEY (medication_id) REFERENCES medicines(medication_id),
    ADD CONSTRAINT fk_active_substance_medicine FOREIGN KEY (active_substance_id) REFERENCES active_substances(active_substance_id);

ALTER TABLE patient_has_allergy
    ADD CONSTRAINT fk_patient_allergy FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    ADD CONSTRAINT fk_allergy_patient FOREIGN KEY (active_substance_id) REFERENCES active_substances(active_substance_id);

ALTER TABLE doctor 
    ADD CONSTRAINT fk_doctor_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    ADD CONSTRAINT fk_doctor_specialty FOREIGN KEY (specialty_id) REFERENCES doctor_specialty(specialty_id),
    ADD CONSTRAINT fk_doctor_supervisor FOREIGN KEY (supervisor_doctor_id) REFERENCES doctor(doctor_id);

SET FOREIGN_KEY_CHECKS = 1;
