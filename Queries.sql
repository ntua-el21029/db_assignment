//Q2
SELECT 
    d.doctor_id                                     AS `Κωδικός Ιατρού`,
    e.empl_first_name                               AS `Όνομα`,
    e.empl_last_name                                AS `Επώνυμο`,
    dsp.specialty_name                              AS `Ειδικότητα`,
    dg.grade_description                            AS `Βαθμίδα`,
    e.empl_hiring_date                              AS `Ημ. Πρόσληψης`,

    -- Ένδειξη εφημερίας για το 2024
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM duty_schedule_team dst
            JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
            WHERE dst.employee_id = e.employee_id 
              AND YEAR(ds.duty_date) = 2024
        ) THEN 'Ναι' 
        ELSE 'Όχι' 
    END                                             AS `Είχε Εφημερία (2024)`,

    -- Αριθμός εφημεριών για το 2024
    (
        SELECT COUNT(*) 
        FROM duty_schedule_team dst
        JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
        WHERE dst.employee_id = e.employee_id 
          AND YEAR(ds.duty_date) = 2024
    )                                               AS `Σύνολο Εφημεριών (2024)`,

    -- Επεμβάσεις ως κύριος χειρουργός (όλα τα χρόνια)
    COUNT(ma.act_id)                                AS `Σύνολο Επεμβάσεων`,

    -- Επεμβάσεις ως κύριος χειρουργός (το 2023)
    SUM(CASE WHEN YEAR(ma.act_start) = 2023 THEN 1 ELSE 0 END) 
                                                    AS `Επεμβάσεις (2023)`

FROM doctor d
LEFT JOIN employee e           ON e.employee_id      = d.employee_id
LEFT JOIN doctor_specialty dsp ON dsp.specialty_id   = d.specialty_id
LEFT JOIN doctor_grade dg      ON dg.grade_id        = d.grade_id
LEFT JOIN medical_act ma       ON ma.main_surgeon_id = d.doctor_id

-- Αντί για γράμματα, χτυπάμε κατευθείαν το ID της Χειρουργικής (2)
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
