SELECT
    d.doctor_id AS DoctorID,
    e.empl_first_name AS First_Name,
    e.empl_last_name AS Last_Name,
    ds.specialty_name AS Specialty,
    TIMESTAMPDIFF(YEAR, e.empl_birth_date, CURRENT_DATE) AS Doctor_age, 
    COUNT(md.act_id) AS Number_of_surgeries
    
FROM doctor d
JOIN employee e ON d.employee_id = e.employee_id
JOIN doctor_specialty ds ON ds.specialty_id = d.specialty_id
JOIN medical_act md ON d.doctor_id = md.main_surgeon_id

WHERE 
    TIMESTAMPDIFF(YEAR, e.empl_birth_date, CURRENT_DATE) < 35 
  
GROUP BY
    d.doctor_id
    
ORDER BY
    Number_of_surgeries DESC;
