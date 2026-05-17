SET @target_patient_id = 2;

SELECT 
    p.patient_id                                          AS `Κωδικός Ασθενή`,
    CONCAT(p.first_name, ' ', p.last_name)                AS `Ονοματεπώνυμο`,
    h.hospitalization_id                                  AS `Κωδικός Νοσηλείας`,
    h.admission_date                                      AS `Ημ. Εισαγωγής`,
    h.discharge_date                                      AS `Ημ. Εξιτηρίου`,
    h.ICD10_admission_id                                  AS `Κωδικός ICD-10`,
    icd.icd_description                                   AS `Περιγραφή Διάγνωσης`,
    h.total_cost_with_exams_acts                          AS `Συνολικό Κόστος (€)`,
    
    -- Προσθέτουμε τα 5 πεδία αξιολόγησης και διαιρούμε με το 5.0 για τον μέσο όρο
    ROUND((hr.medical_care + hr.nurse_care + hr.cleanness + hr.overall_experience + hr.food_quality) / 5.0, 2) 
                                                          AS `Μέσος Όρος Αξιολόγησης (Άριστα το 5)`

FROM patient p
JOIN hospitalization h        ON p.patient_id = h.patient_id
LEFT JOIN ICD10_codes icd     ON h.ICD10_admission_id = icd.icd_id
LEFT JOIN hospitalization_review hr ON h.hosp_review_id = hr.review_id

WHERE p.patient_id = @target_patient_id

ORDER BY h.admission_date DESC;
