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

CREATE TRIGGER calculate_hospitalization_cost
BEFORE UPDATE ON hospitalization
FOR EACH ROW
BEGIN
    DECLARE base DECIMAL(10,2);
    DECLARE mdn INT;
    DECLARE actual_days INT;
    DECLARE extra_days INT;
    DECLARE daily_rate DECIMAL(10,2);
    DECLARE extra_charge DECIMAL(10,2) DEFAULT 0;
    DECLARE exams_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE acts_cost DECIMAL(10,2) DEFAULT 0;

    -- Όταν ορίζεται discharge_date για πρώτη φορά
    IF NEW.discharge_date IS NOT NULL AND OLD.discharge_date IS NULL THEN

        -- 1. Κόστος ΚΕΝ + υπέρβαση ΜΔΝ
        SELECT base_cost, mdn_days INTO base, mdn
        FROM ken_system WHERE ken_id = NEW.ken_id;

        SET actual_days = DATEDIFF(NEW.discharge_date, NEW.admission_date);
        IF actual_days = 0 THEN
            SET actual_days = 1;
        END IF;

        SET extra_days = GREATEST(actual_days - mdn, 0);
        SET daily_rate = base / mdn;
        SET extra_charge = daily_rate * extra_days;

        -- 2. Κόστος εργαστηριακών εξετάσεων
        SELECT COALESCE(SUM(exam_cost), 0) INTO exams_cost
        FROM laboratory_exams
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 3. Κόστος ιατρικών πράξεων / επεμβάσεων
        SELECT COALESCE(SUM(act_cost), 0) INTO acts_cost
        FROM medical_act
        WHERE hospitalization_id = NEW.hospitalization_id;

        -- 4. Ενημέρωση πεδίων
        SET NEW.extra_cost = extra_charge;
        SET NEW.total_cost = base + extra_charge + exams_cost + acts_cost;
    END IF;
END;
//

DELIMITER ;