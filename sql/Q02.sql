-- Q02: Για συγκεκριμένη ειδικότητα ιατρού, όλοι οι ιατροί που ανήκουν σε αυτήν,
-- με ένδειξη αν είχαν εφημερία το τρέχον έτος και πόσες χειρουργικές επεμβάσεις
-- εκτέλεσαν ως κύριοι χειρουργοί.
-- Παράμετρος: όνομα ειδικότητας (εδώ: 'Cardiology' – άλλαξέ το αν χρειάζεται)

SELECT
    d.doctor_id,
    e.empl_first_name,
    e.empl_last_name,
    sp.specialty_name,
    dg.grade_description,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM duty_schedule_team dst
            JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
            WHERE dst.employee_id = d.employee_id
              AND YEAR(ds.duty_date) = YEAR(CURRENT_DATE)
        ) THEN 'YES' ELSE 'NO'
    END                                                     AS had_duty_current_year,
    COUNT(DISTINCT ma.act_id)                               AS surgeries_as_main_surgeon
FROM doctor d
JOIN employee         e  ON d.employee_id = e.employee_id
JOIN doctor_specialty sp ON d.specialty_id = sp.specialty_id
JOIN doctor_grade     dg ON d.grade_id     = dg.grade_id
LEFT JOIN medical_act ma
       ON ma.main_surgeon_id = d.doctor_id
      AND (LEFT(ma.medical_act_code, 1) = 'X'
           OR LEFT(ma.medical_act_code, 1) = 'Χ')
WHERE sp.specialty_name = 'Cardiology'  -- <-- παράμετρος ειδικότητας
GROUP BY
    d.doctor_id,
    e.empl_first_name,
    e.empl_last_name,
    sp.specialty_name,
    dg.grade_description
ORDER BY surgeries_as_main_surgeon DESC, e.empl_last_name;

