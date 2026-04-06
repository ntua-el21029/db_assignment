USE hospital_db;

DELIMITER //
CREATE TRIGGER supervisor_nurse_check
BEFORE INSERT ON nurse
FOR EACH ROW

BEGIN 
    DECLARE supervisor_grade INT;

    IF NEW.supervisor_nurse_id IS NOT NULL THEN             -- NEW is the new row inserted into the nurse table.
        SELECT nurse_grade_id INTO supervisor_grade FROM nurse WHERE nurse_id = NEW.supervisor_nurse_id;

        IF supervisor_grade <> 1 OR supervisor_grade IS NULL THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supervisor nurse must have grade 1';
        END IF;
    END IF;
END;

CREATE TRIGGER check_medical_act_overlap
BEFORE INSERT ON medical_act
FOR EACH ROW
BEGIN
    -- elegxos gia idio dvmatio
    IF EXISTS (
        SELECT 1 FROM medical_act
        WHERE department_room_id = NEW.department_room_id
          AND department_id = NEW.department_id
          AND act_start < NEW.act_end 
          AND act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Η αίθουσα χρησιμοποιείται ήδη σε άλλη επέμβαση αυτή την στιγμή';
    END IF;

    -- idios kyrios xeiroyrgos
    IF EXISTS (
        SELECT 1 FROM medical_act
        WHERE main_surgeon_id = NEW.main_surgeon_id
          AND act_start < NEW.act_end 
          AND act_end > NEW.act_start
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο ιατρός συμμετέχει ήδη ως κύριος χειρουργός σε άλλη επέμβαση αυτή την στιγμή';
    END IF;
END;


--ana kathgoria  15 iatroi , 20 noshleytes ,25 dioikhtikoi
CREATE TRIGGER check_monthly_shift_limits
BEFORE INSERT ON duty_schedule_team
FOR EACH ROW
BEGIN
    DECLARE shift_month INT;
    DECLARE shift_year INT;
    DECLARE current_shifts INT;
    DECLARE emp_type VARCHAR(30);

    -- briksv ton mhna kai etos ths neas bardias
    SELECT MONTH(date), YEAR(date) INTO shift_month, shift_year
    FROM duty_schedule WHERE duty_id = NEW.duty_id;

    -- briskv to epaggelma toy ypallhloy poy thelv na balv 
    SELECT empl_type INTO emp_type
    FROM employee WHERE employee_id = NEW.employee_id;

    --poses bardies exei o ypallhlos aytos mesa ston mhna 
    SELECT COUNT(*) INTO current_shifts
    FROM duty_schedule_team dst
    JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
    WHERE dst.employee_id = NEW.employee_id
      AND MONTH(ds.date) = shift_month
      AND YEAR(ds.date) = shift_year;

    -- elegxos me bash to eidos toy employee
    IF emp_type = 'doctor' AND current_shifts >= 15 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο ιατρός έχει ήδη συμπληρώσει το όριο των 15 βαρδιών για αυτόν τον μήνα.';
    ELSEIF emp_type = 'nurse' AND current_shifts >= 20 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο νοσηλευτής έχει ήδη συμπληρώσει το όριο των 20 βαρδιών για αυτόν τον μήνα.';
    ELSEIF emp_type = 'administrative_staff' AND current_shifts >= 25 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο διοικητικός υπάλληλος έχει ήδη συμπληρώσει το όριο των 25 βαρδιών για αυτόν τον μήνα.';
    END IF;
END;

USE hospital_db;

DELIMITER //

--ierarxeia iatrvn kai epopteia
CREATE TRIGGER check_doctor_hierarchy
BEFORE INSERT ON doctor
FOR EACH ROW
BEGIN
    -- eidikeyomenos , grade=1 exei epopth
    IF NEW.grade_id = 1 AND NEW.supervisor_doctor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο Ειδικευόμενος ιατρός πρέπει υποχρεωτικά να έχει επόπτη.';
    END IF;

    -- dieuthunths: grade_id = 4 den exei epopth
    IF NEW.grade_id = 4 AND NEW.supervisor_doctor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Ο Διευθυντής δεν επιτρέπεται να έχει επόπτη.';
    END IF;

    -- apotroph kyklikhs epopteias 
    IF NEW.supervisor_doctor_id IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM doctor 
            WHERE doctor_id = NEW.supervisor_doctor_id 
              AND supervisor_doctor_id = NEW.doctor_id
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ΣΦΑΛΜΑ: Απαγορεύεται η κυκλική εποπτεία μεταξύ δύο ιατρών.';
        END IF;
    END IF;
END;
//

-- gia tis allergies 
CREATE TRIGGER prevent_allergic_prescription
BEFORE INSERT ON medication_treatment
FOR EACH ROW
BEGIN
    --  psaxnoyme taytish systatikvn farmakoy kai allergivn asthenh
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


CREATE TRIGGER check_8_hour_rest
BEFORE INSERT ON duty_schedule_team
FOR EACH ROW
BEGIN
    DECLARE n_start DATETIME;
    DECLARE n_end DATETIME;

    -- briskv thn hmeromhnia , vra enarkshs kai lhjhs ths neas bardias  
    SELECT 
        ADDTIME(CONVERT(ds.date, DATETIME), st.start_time),
        -- an einai nyxterinh prepei na prosthesv mia mera
        IF(st.end_time < st.start_time, 
           ADDTIME(CONVERT(DATE_ADD(ds.date, INTERVAL 1 DAY), DATETIME), st.end_time), 
           ADDTIME(CONVERT(ds.date, DATETIME), st.end_time)
        )
    INTO n_start, n_end
    FROM duty_schedule ds
    JOIN shift_type st ON ds.shift_type_id = st.shift_type_id
    WHERE ds.duty_id = NEW.duty_id;

    --  psaxnv an o ypallhlos exei hdh mia bardia poy sympiptei sto 8vro toy
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

DELIMITER ;
