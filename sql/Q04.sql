-- Q04: Για συγκεκριμένο ιατρό, μέσος όρος αξιολογήσεων των ασθενών του
-- (Ποιότητα ιατρικής φροντίδας) και Συνολική εντύπωση νοσηλείας.
-- Παράμετρος: d.doctor_id = 1   
--
-- ΠΡΟΣΟΧΗ: Το ερώτημα αυτό ζητείται με EXPLAIN/ANALYZE + εναλλακτική FORCE INDEX.
-- Δες στο αρχείο docs/report.pdf τη σύγκριση query plans.

SELECT
    d.doctor_id,
    e.empl_first_name,
    e.empl_last_name,
    COUNT(DISTINCT dr.doctor_review_id)         AS num_doctor_reviews,
    ROUND(AVG(dr.medical_care), 2)              AS avg_doctor_medical_care,
    COUNT(DISTINCT hr.review_id)                AS num_hospitalization_reviews,
    ROUND(AVG(hr.overall_experience), 2)        AS avg_overall_experience
FROM doctor d
JOIN employee e ON d.employee_id = e.employee_id
LEFT JOIN doctor_review dr
       ON dr.doctor_id = d.doctor_id
LEFT JOIN hospitalization_review hr
       ON hr.hospitalization_id = dr.hospitalization_id
WHERE d.doctor_id = 1     -- <-- παράμετρος ιατρού
GROUP BY d.doctor_id, e.empl_first_name, e.empl_last_name;


-- ============================================================
-- Εναλλακτική έκδοση με FORCE INDEX (για σύγκριση EXPLAIN ANALYZE)
-- Προϋποθέτει ότι έχει δημιουργηθεί index, π.χ.:
--   CREATE INDEX idx_doctor_review_doctor ON doctor_review(doctor_id);
--   CREATE INDEX idx_hosp_review_hosp     ON hospitalization_review(hospitalization_id);
-- ============================================================

-- SELECT
--     d.doctor_id,
--     e.empl_first_name,
--     e.empl_last_name,
--     COUNT(DISTINCT dr.doctor_review_id)  AS num_doctor_reviews,
--     ROUND(AVG(dr.medical_care), 2)       AS avg_doctor_medical_care,
--     COUNT(DISTINCT hr.review_id)         AS num_hospitalization_reviews,
--     ROUND(AVG(hr.overall_experience), 2) AS avg_overall_experience
-- FROM doctor d
-- JOIN employee e ON d.employee_id = e.employee_id
-- LEFT JOIN doctor_review dr FORCE INDEX (idx_doctor_review_doctor)
--        ON dr.doctor_id = d.doctor_id
-- LEFT JOIN hospitalization_review hr FORCE INDEX (idx_hosp_review_hosp)
--        ON hr.hospitalization_id = dr.hospitalization_id
-- WHERE d.doctor_id = 1
-- GROUP BY d.doctor_id, e.empl_first_name, e.empl_last_name;
