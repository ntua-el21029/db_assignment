SET @doc_id = 1;

SELECT
    d.doctor_id,
    e.empl_first_name,
    e.empl_last_name,
    sp.specialty_name,
    -- (α) Μέσος όρος Ποιότητας Ιατρικής Φροντίδας
    ROUND(AVG(dr.medical_care), 2)         AS avg_medical_care,
    COUNT(dr.doctor_review_id)             AS num_doctor_reviews,
    -- (β) Μέσος όρος Συνολικής Εντύπωσης Νοσηλείας στις ίδιες νοσηλείες
    ROUND(AVG(hr.overall_experience), 2)   AS avg_overall_experience,
    COUNT(hr.review_id)                    AS num_hosp_reviews
FROM doctor d
JOIN employee         e  ON e.employee_id  = d.employee_id
JOIN doctor_specialty sp ON sp.specialty_id = d.specialty_id
LEFT JOIN doctor_review        dr ON dr.doctor_id          = d.doctor_id
LEFT JOIN hospitalization      h  ON h.hospitalization_id  = dr.hospitalization_id
LEFT JOIN hospitalization_review hr ON hr.review_id        = h.hosp_review_id
WHERE d.doctor_id = @doc_id
GROUP BY d.doctor_id, e.empl_first_name, e.empl_last_name, sp.specialty_name;
    
