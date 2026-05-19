SELECT
    p.patient_id AS PatientID,
    p.first_name AS First_Name,
    p.last_name AS Last_Name,
    hd.department_name AS Department,
    COUNT(h.hospitalization_id) AS Number_of_hospitalizations,
    SUM(h.total_cost) AS Total_cost
    
FROM hospitalization h
JOIN patient p ON p.patient_id = h.patient_id
JOIN hospital_department hd ON h.department_id = hd.department_id

GROUP BY p.patient_id, hd.department_id
HAVING COUNT(h.hospitalization_id) > 3 
ORDER BY Total_cost DESC;
