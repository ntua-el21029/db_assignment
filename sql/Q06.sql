-- Q06: Για συγκεκριμένο ασθενή, ιστορικό νοσηλειών του, αντίστοιχες
-- διαγνώσεις ICD-10, συνολικό κόστος ανά νοσηλεία και μέσος όρος αξιολόγησής του.
-- Παράμετρος: p.patient_id = 1   (άλλαξέ το)
--
-- ΠΡΟΣΟΧΗ: Το ερώτημα αυτό ζητείται με EXPLAIN/ANALYZE + εναλλακτική FORCE INDEX.

SELECT
    h.hospitalization_id,
    p.patient_id,
    p.first_name,
    p.last_name,
    h.admission_date,
    h.discharge_date,
    DATEDIFF(COALESCE(h.discharge_date, CURRENT_DATE),
             h.admission_date)                      AS hospitalization_days,
    icd.icd_id                                      AS icd10_admission,
    icd.icd_description                             AS icd10_admission_desc,
    icd.icd_category                                AS icd10_category,
    h.ICD10_discharge                               AS icd10_discharge,
    h.total_cost                                    AS total_cost,
    ROUND(
        (hr.medical_care + hr.nurse_care + hr.cleanness
         + hr.overall_experience + hr.food_quality) / 5.0, 2
    )                                               AS avg_review_score
FROM hospitalization h
JOIN patient     p   ON h.patient_id          = p.patient_id
JOIN ICD10_codes icd ON h.ICD10_admission_id  = icd.icd_id
LEFT JOIN hospitalization_review hr
       ON hr.hospitalization_id = h.hospitalization_id
WHERE p.patient_id = 1            -- <-- παράμετρος ασθενή
ORDER BY h.admission_date DESC;


-- ============================================================
-- Εναλλακτική έκδοση με FORCE INDEX (για σύγκριση EXPLAIN ANALYZE)
-- Προϋποθέτει την ύπαρξη indexes, π.χ.:
--   CREATE INDEX idx_hosp_patient ON hospitalization(patient_id);
--   CREATE INDEX idx_hr_hosp      ON hospitalization_review(hospitalization_id);
-- ============================================================

-- SELECT
--     h.hospitalization_id, p.patient_id, p.first_name, p.last_name,
--     h.admission_date, h.discharge_date,
--     DATEDIFF(COALESCE(h.discharge_date, CURRENT_DATE), h.admission_date) AS hospitalization_days,
--     icd.icd_id, icd.icd_description, icd.icd_category,
--     h.ICD10_discharge, h.total_cost,
--     ROUND((hr.medical_care + hr.nurse_care + hr.cleanness
--            + hr.overall_experience + hr.food_quality) / 5.0, 2) AS avg_review_score
-- FROM hospitalization h FORCE INDEX (idx_hosp_patient)
-- JOIN patient     p   ON h.patient_id         = p.patient_id
-- JOIN ICD10_codes icd ON h.ICD10_admission_id = icd.icd_id
-- LEFT JOIN hospitalization_review hr FORCE INDEX (idx_hr_hosp)
--        ON hr.hospitalization_id = h.hospitalization_id
-- WHERE p.patient_id = 1
-- ORDER BY h.admission_date DESC;
