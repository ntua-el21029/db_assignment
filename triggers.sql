USE hospital_db;

DROP TRIGGER IF EXISTS supervisor_nurse_check;
DROP TRIGGER IF EXISTS check_medical_act_overlap;
DROP TRIGGER IF EXISTS check_monthly_shift_limits;
DROP TRIGGER IF EXISTS check_doctor_hierarchy;
DROP TRIGGER IF EXISTS prevent_allergic_prescription;
DROP TRIGGER IF EXISTS check_8_hour_rest;
DROP TRIGGER IF EXISTS check_max_3_night_shifts;

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

   --
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



CREATE TRIGGER check_medical_act_overlap
BEFORE INSERT ON medical_act
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM medical_act
        WHERE department_room_id = NEW.department_room_id
          AND department_id = NEW.department_id
          AND act_start < NEW.act_end 
          AND act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Η αίθουσα χρησιμοποιείται ήδη σε άλλη επέμβαση αυτή την στιγμή';
    END IF;

    IF EXISTS (
        SELECT 1 FROM medical_act
        WHERE main_surgeon_id = NEW.main_surgeon_id
          AND act_start < NEW.act_end 
          AND act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο ιατρός συμμετέχει ήδη ως κύριος χειρουργός σε άλλη επέμβαση αυτή την στιγμή';
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
    DECLARE emp_type VARCHAR(30);

    SELECT MONTH(date), YEAR(date) INTO shift_month, shift_year
    FROM duty_schedule WHERE duty_id = NEW.duty_id;

    SELECT empl_type INTO emp_type
    FROM employee WHERE employee_id = NEW.employee_id;

    SELECT COUNT(*) INTO current_shifts
    FROM duty_schedule_team dst
    JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
    WHERE dst.employee_id = NEW.employee_id
      AND MONTH(ds.date) = shift_month
      AND YEAR(ds.date) = shift_year;

    IF emp_type = 'doctor' AND current_shifts >= 15 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο ιατρός έχει ήδη συμπληρώσει το όριο των 15 βαρδιών για αυτόν τον μήνα.';
    ELSEIF emp_type = 'nurse' AND current_shifts >= 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο νοσηλευτής έχει ήδη συμπληρώσει το όριο των 20 βαρδιών για αυτόν τον μήνα.';
    ELSEIF emp_type = 'administrative_staff' AND current_shifts >= 25 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο διοικητικός υπάλληλος έχει ήδη συμπληρώσει το όριο των 25 βαρδιών για αυτόν τον μήνα.';
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

CREATE TRIGGER check_8_hour_rest
BEFORE INSERT ON duty_schedule_team
FOR EACH ROW
BEGIN
    DECLARE n_start DATETIME;
    DECLARE n_end DATETIME;

    SELECT 
        ADDTIME(CONVERT(ds.date, DATETIME), st.start_time),
        IF(st.end_time < st.start_time, 
           ADDTIME(CONVERT(DATE_ADD(ds.date, INTERVAL 1 DAY), DATETIME), st.end_time), 
           ADDTIME(CONVERT(ds.date, DATETIME), st.end_time)
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
            ADDTIME(CONVERT(ds.date, DATETIME), st.start_time) < DATE_ADD(n_end, INTERVAL 8 HOUR)
            AND 
            IF(st.end_time < st.start_time, 
               ADDTIME(CONVERT(DATE_ADD(ds.date, INTERVAL 1 DAY), DATETIME), st.end_time), 
               ADDTIME(CONVERT(ds.date, DATETIME), st.end_time)
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

    SELECT st.shift_description, ds.date INTO new_shift_desc, new_date
    FROM duty_schedule ds
    JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
    WHERE ds.duty_id = NEW.duty_id;

    IF new_shift_desc = 'Night' THEN
        SELECT 
            MAX(CASE WHEN ds.date = DATE_SUB(new_date, INTERVAL 1 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.date = DATE_SUB(new_date, INTERVAL 2 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.date = DATE_SUB(new_date, INTERVAL 3 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.date = DATE_ADD(new_date, INTERVAL 1 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.date = DATE_ADD(new_date, INTERVAL 2 DAY) THEN 1 ELSE 0 END),
            MAX(CASE WHEN ds.date = DATE_ADD(new_date, INTERVAL 3 DAY) THEN 1 ELSE 0 END)
        INTO d_m1, d_m2, d_m3, d_p1, d_p2, d_p3
        FROM duty_schedule_team dst
        JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
        JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
        WHERE dst.employee_id = NEW.employee_id 
          AND st.shift_description = 'Night'
          AND ds.date BETWEEN DATE_SUB(new_date, INTERVAL 3 DAY) AND DATE_ADD(new_date, INTERVAL 3 DAY);

        IF (d_m3 = 1 AND d_m2 = 1 AND d_m1 = 1) OR
           (d_m2 = 1 AND d_m1 = 1 AND d_p1 = 1) OR
           (d_m1 = 1 AND d_p1 = 1 AND d_p2 = 1) OR
           (d_p1 = 1 AND d_p2 = 1 AND d_p3 = 1) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Απαγορεύεται η συμμετοχή σε περισσότερες από 3 συνεχόμενες νυχτερινές βάρδιες!';
        END IF;
    END IF;
END;
//

DELIMITER ;