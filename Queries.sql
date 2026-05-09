//Q2
-- Q2: Για συγκεκριμένη ειδικότητα ιατρού (Χειρουργική), βρείτε όλους 
--     τους ιατρούς που ανήκουν σε αυτήν, με ένδειξη αν είχαν εφημερία (τρέχον έτος)
--     και πόσες επεμβάσεις εκτέλεσαν ως κύριοι χειρουργοί (συνολικά & τρέχον έτος).

SELECT 
    d.doctor_id                                     AS `Κωδικός Ιατρού`,
    e.empl_first_name                               AS `Όνομα`,
    e.empl_last_name                                AS `Επώνυμο`,
    dsp.specialty_name                              AS `Ειδικότητα`,
    dg.grade_description                            AS `Βαθμίδα`,
    e.empl_hiring_date                              AS `Ημ. Πρόσληψης`,

    -- Ένδειξη εφημερίας για το δυναμικό τρέχον έτος
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM duty_schedule_team dst
            JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
            WHERE dst.employee_id = e.employee_id 
              AND YEAR(ds.duty_date) = YEAR(CURDATE())
        ) THEN 'Ναι' 
        ELSE 'Όχι' 
    END                                             AS `Είχε Εφημερία (Τρέχον Έτος)`,

    -- Αριθμός εφημεριών για το δυναμικό τρέχον έτος
    (
        SELECT COUNT(*) 
        FROM duty_schedule_team dst
        JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
        WHERE dst.employee_id = e.employee_id 
          AND YEAR(ds.duty_date) = YEAR(CURDATE())
    )                                               AS `Σύνολο Εφημεριών (Τρέχον Έτος)`,

    -- Επεμβάσεις ως κύριος χειρουργός (όλα τα χρόνια ανεξαιρέτως)
    COUNT(ma.act_id)                                AS `Σύνολο Επεμβάσεων`,

    -- Επεμβάσεις ως κύριος χειρουργός (μόνο για το δυναμικό τρέχον έτος)
    SUM(CASE WHEN YEAR(ma.act_start) = YEAR(CURDATE()) THEN 1 ELSE 0 END) 
                                                    AS `Επεμβάσεις (Τρέχον Έτος)`

FROM doctor d
LEFT JOIN employee e           ON e.employee_id      = d.employee_id
LEFT JOIN doctor_specialty dsp ON dsp.specialty_id   = d.specialty_id
LEFT JOIN doctor_grade dg      ON dg.grade_id        = d.grade_id
LEFT JOIN medical_act ma       ON ma.main_surgeon_id = d.doctor_id

-- Φιλτράρισμα μόνο για τους Χειρουργούς (Ειδικότητα = 2)
WHERE d.specialty_id = 2 

GROUP BY 
    d.doctor_id, 
    e.empl_first_name, 
    e.empl_last_name, 
    dsp.specialty_name, 
    dg.grade_description, 
    e.empl_hiring_date,
    e.employee_id
ORDER BY 
    `Σύνολο Επεμβάσεων` DESC;
