USE hospital_db;

CREATE TRIGGER supervisor_nurse_check
BEFORE INSERT ON nurse
FOR EACH ROW

BEGIN 
    DECLARE supervisor_grade INT;

    IF NEW.supervisor_nurse_id IS NOT NULL THEN             -- NEW is the new row inserted into the nurse table.
        SELECT nurse_grade_id INTO supervisor_grade FROM nurse WHERE nurse_id = NEW.supervisor_nurse_id;

        IF supervisor_grade <> 1 OR supervisor_grade IS NULL THEN 
            SIGNAL_SQLSTATE '45000' SET MESSAGE_TEXT = 'Supervisor nurse must have grade 1';
        END IF;
    END IF;
END;

