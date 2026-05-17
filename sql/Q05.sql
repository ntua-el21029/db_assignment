-- Q05: Νέοι ιατροί (ηλικία < 35) που έχουν εκτελέσει τις περισσότερες
-- χειρουργικές επεμβάσεις ως κύριοι χειρουργοί.
-- Χειρουργικές επεμβάσεις: medical_act_code που ξεκινά από 'X' ή 'Χ'
-- (βλ. constraint chk_surgeon_by_code στον πίνακα medical_act).

SELECT
    d.doctor_id,
    e.empl_first_name,
    e.empl_last_name,
    TIMESTAMPDIFF(YEAR, e.empl_birth_date, CURRENT_DATE) AS age,
    sp.specialty_name,
    COUNT(ma.act_id)                                     AS num_surgeries
FROM doctor d
JOIN employee         e  ON d.employee_id  = e.employee_id
JOIN doctor_specialty sp ON d.specialty_id = sp.specialty_id
JOIN medical_act      ma ON ma.main_surgeon_id = d.doctor_id
WHERE TIMESTAMPDIFF(YEAR, e.empl_birth_date, CURRENT_DATE) < 35
  AND (LEFT(ma.medical_act_code, 1) = 'X'
       OR LEFT(ma.medical_act_code, 1) = 'Χ')
GROUP BY d.doctor_id, e.empl_first_name, e.empl_last_name,
         age, sp.specialty_name
ORDER BY num_surgeries DESC, age ASC
LIMIT 10;
