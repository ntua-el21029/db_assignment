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
    
SET FOREIGN_KEY_CHECKS = 1;
