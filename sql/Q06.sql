SELECT
   p.patient_id AS PatientID,
   p.first_name AS First_Name,
   p.last_name AS Last_Name,
   h.hospitalization_id AS hospitalization_id,       
   CAST(ROUND(h.total_cost + COALESCE(le.exam_cost, 0), 3) AS CHAR) AS Total_cost,                
   ROUND((hr.overall_experience + dr.medical_care) / 2, 3) AS rating
FROM patient p
JOIN hospitalization h ON p.patient_id = h.patient_id 
JOIN icd10_codes ic ON h.ICD10_admission_id = ic.icd_id
LEFT JOIN laboratory_exams le ON le.hospitalization_id = h.hospitalization_id
LEFT JOIN hospitalization_review hr ON hr.hospitalization_id = h.hospitalization_id
LEFT JOIN doctor_review dr ON dr.hospitalization_id = h.hospitalization_id
WHERE p.patient_id = 5 
GROUP BY h.hospitalization_id

UNION ALL

SELECT
   NULL, NULL, NULL, 
   NULL, 
   'Average Rating', 
   ROUND(AVG((hr.overall_experience + dr.medical_care) / 2), 3)
FROM patient p
JOIN hospitalization h ON p.patient_id = h.patient_id 
JOIN icd10_codes ic ON h.ICD10_admission_id = ic.icd_id
LEFT JOIN laboratory_exams le ON le.hospitalization_id = h.hospitalization_id
LEFT JOIN hospitalization_review hr ON hr.hospitalization_id = h.hospitalization_id
LEFT JOIN doctor_review dr ON dr.hospitalization_id = h.hospitalization_id
WHERE p.patient_id = 5;
