SELECT
    p.patient_id,
    p.amka,
    p.first_name,
    p.last_name,
    d.department_id,
    d.department_name,
    COUNT(*)                                           AS num_hospitalizations,
    SUM(h.total_cost_with_exams_acts)                  AS total_cost_per_dept,
    -- Επιπλέον ανάλυση κόστους (προαιρετικά, για context):
    SUM(h.total_cost)                                  AS hospitalization_only_cost,
    SUM(h.extra_days_cost)                             AS extra_days_cost_total
FROM hospitalization h
JOIN patient             p ON p.patient_id    = h.patient_id
JOIN hospital_department d ON d.department_id = h.department_id
WHERE h.discharge_date IS NOT NULL
GROUP BY p.patient_id, p.amka, p.first_name, p.last_name,
         d.department_id, d.department_name
HAVING COUNT(*) > 3
ORDER BY num_hospitalizations DESC, total_cost_per_dept DESC;
    
