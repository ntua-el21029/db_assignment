-- Q13: Για κάθε ιατρό, όλη η ιεραρχία εποπτείας από τον άμεσο επόπτη
-- έως τον Διευθυντή, με ένδειξη του επιπέδου σε κάθε βαθμίδα.
-- Χρήση Recursive Common Table Expression.

WITH RECURSIVE supervision_chain AS (
    -- Βάση: ο άμεσος επόπτης κάθε ιατρού
    SELECT
        d.doctor_id                AS original_doctor_id,
        d.supervisor_doctor_id     AS supervisor_id,
        1                          AS level
    FROM doctor d
    WHERE d.supervisor_doctor_id IS NOT NULL

    UNION ALL

    -- Αναδρομικό βήμα: ο επόπτης του επόπτη
    SELECT
        sc.original_doctor_id,
        d.supervisor_doctor_id,
        sc.level + 1
    FROM supervision_chain sc
    JOIN doctor d ON d.doctor_id = sc.supervisor_id
    WHERE d.supervisor_doctor_id IS NOT NULL
)
SELECT
    sc.original_doctor_id,
    e_orig.empl_first_name           AS doctor_first_name,
    e_orig.empl_last_name            AS doctor_last_name,
    dg_orig.grade_description        AS doctor_grade,
    sc.level                         AS supervision_level,
    sc.supervisor_id,
    e_sup.empl_first_name            AS supervisor_first_name,
    e_sup.empl_last_name             AS supervisor_last_name,
    dg_sup.grade_description         AS supervisor_grade
FROM supervision_chain sc
JOIN doctor       d_orig  ON sc.original_doctor_id = d_orig.doctor_id
JOIN employee     e_orig  ON d_orig.employee_id    = e_orig.employee_id
JOIN doctor_grade dg_orig ON d_orig.grade_id       = dg_orig.grade_id
JOIN doctor       d_sup   ON sc.supervisor_id      = d_sup.doctor_id
JOIN employee     e_sup   ON d_sup.employee_id     = e_sup.employee_id
JOIN doctor_grade dg_sup  ON d_sup.grade_id        = dg_sup.grade_id
ORDER BY sc.original_doctor_id, sc.level;
