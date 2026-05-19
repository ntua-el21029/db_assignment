SELECT
    doc.doctor_id AS DoctorID,
    e.empl_first_name AS First_Name,
    e.empl_last_name AS Last_Name,
    sp.specialty_name AS Specialty,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM duty_schedule_team dst
            JOIN duty_schedule ds ON dst.duty_id = ds.duty_id
            WHERE dst.employee_id = doc.employee_id
              AND YEAR(ds.duty_date) = YEAR(CURRENT_DATE)
        ) THEN 'YES' ELSE 'NO'
    END                                                     AS Duty_this_year,
    COUNT(DISTINCT ma.act_id)                               AS Surgeries_as_main
    
FROM doctor doc
JOIN employee         e  ON doc.employee_id = e.employee_id
JOIN doctor_specialty sp ON doc.specialty_id = sp.specialty_id
LEFT JOIN medical_act ma
       ON ma.main_surgeon_id = doc.doctor_id
      AND (LEFT(ma.medical_act_code, 1) = 'X'
           OR LEFT(ma.medical_act_code, 1) = 'Χ')
WHERE sp.specialty_name = 'Surgery'  -- specialty variable

GROUP BY
    doc.doctor_id
ORDER BY
    Surgeries_as_main DESC

