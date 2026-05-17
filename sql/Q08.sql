-- Q08: Προσωπικό (ιατροί, νοσηλευτές, διοικητικό) του τμήματος @dept_id
-- που ΔΕΝ έχει προγραμματισμένη εφημερία τη συγκεκριμένη ημερομηνία.
-- Παράμετροι:
--   target_date = '2026-04-15'
--   dept_id     = 1

SELECT
    e.employee_id,
    e.empl_amka,
    e.empl_first_name,
    e.empl_last_name,
    e.empl_type,
    CASE
        WHEN e.empl_type = 'doctor'               THEN sp.specialty_name
        WHEN e.empl_type = 'nurse'                THEN ng.grade_description
        WHEN e.empl_type = 'administrative_staff' THEN sr.role_description
    END                                              AS role_or_specialty
FROM employee e
LEFT JOIN doctor              d   ON d.employee_id = e.employee_id
LEFT JOIN doctor_specialty    sp  ON d.specialty_id = sp.specialty_id
LEFT JOIN doctor_department   dd  ON dd.doctor_id   = d.doctor_id
LEFT JOIN nurse               n   ON n.employee_id = e.employee_id
LEFT JOIN nurse_grade         ng  ON n.nurse_grade_id = ng.nurse_grade_id
LEFT JOIN administrative_staff a  ON a.employee_id = e.employee_id
LEFT JOIN staff_role          sr  ON a.role_id     = sr.role_id
WHERE
    (
        (e.empl_type = 'doctor'               AND dd.department_id        = 1)  -- <-- dept_id
     OR (e.empl_type = 'nurse'                AND n.hospital_department_id = 1)
     OR (e.empl_type = 'administrative_staff' AND a.department_id          = 1)
    )
    AND NOT EXISTS (
        SELECT 1
        FROM duty_schedule_team dst
        JOIN duty_schedule      ds ON dst.duty_id = ds.duty_id
        WHERE dst.employee_id = e.employee_id
          AND ds.duty_date              = '2026-04-15'   -- <-- target_date
          AND ds.hospital_department_id = 1               -- <-- dept_id
    )
ORDER BY e.empl_type, e.empl_last_name, e.empl_first_name;
