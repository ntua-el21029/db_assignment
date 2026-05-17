-- Q11: Ιατροί που έχουν εκτελέσει τουλάχιστον 5 λιγότερες χειρουργικές
-- επεμβάσεις από τον ιατρό με τις περισσότερες στο τρέχον έτος.
-- (Δηλαδή: max_count - my_count >= 5)

WITH doctor_surgeries AS (
    SELECT
        d.doctor_id,
        e.empl_first_name,
        e.empl_last_name,
        COUNT(ma.act_id) AS num_surgeries
    FROM doctor d
    JOIN employee e ON d.employee_id = e.employee_id
    LEFT JOIN medical_act ma
           ON ma.main_surgeon_id = d.doctor_id
          AND (LEFT(ma.medical_act_code, 1) = 'X'
               OR LEFT(ma.medical_act_code, 1) = 'Χ')
          AND YEAR(ma.act_start) = YEAR(CURRENT_DATE)
    GROUP BY d.doctor_id, e.empl_first_name, e.empl_last_name
),
max_s AS (
    SELECT MAX(num_surgeries) AS max_count FROM doctor_surgeries
)
SELECT
    ds.doctor_id,
    ds.empl_first_name,
    ds.empl_last_name,
    ds.num_surgeries,
    m.max_count,
    (m.max_count - ds.num_surgeries) AS difference_from_top
FROM doctor_surgeries ds
CROSS JOIN max_s m
WHERE (m.max_count - ds.num_surgeries) >= 5
ORDER BY ds.num_surgeries DESC, ds.empl_last_name;
