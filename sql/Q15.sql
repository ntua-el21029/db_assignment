-- Q15: Κατανομή περιστατικών triage ανά επίπεδο επείγοντος, με:
--   - μέσο χρόνο αναμονής ανά επίπεδο (από arrival_time έως admission_date)
--   - ποσοστό περιστατικών που οδήγησαν σε νοσηλεία
--   - κατανομή παραπομπών ανά τμήμα (μία γραμμή ανά επίπεδο × τμήμα)

SELECT
    t.emergency_level,
    hd.department_name,
    COUNT(t.triage_id)                                                   AS triage_cases,
    SUM(CASE WHEN t.outcome = 'Hospitalization' THEN 1 ELSE 0 END)       AS hospitalized,
    SUM(CASE WHEN t.outcome = 'Discharge'       THEN 1 ELSE 0 END)       AS discharged,
    ROUND(
        100.0 * SUM(CASE WHEN t.outcome = 'Hospitalization' THEN 1 ELSE 0 END)
              / NULLIF(COUNT(t.triage_id), 0),
        2
    )                                                                    AS hospitalization_pct,
    ROUND(
        AVG(CASE
                WHEN h.admission_date IS NOT NULL
                THEN TIMESTAMPDIFF(MINUTE, t.arrival_time, h.admission_date)
            END),
        2
    )                                                                    AS avg_waiting_minutes
FROM triage t
LEFT JOIN hospitalization     h  ON t.triage_id    = h.triage_id
LEFT JOIN hospital_department hd ON h.department_id = hd.department_id
GROUP BY t.emergency_level, hd.department_name
ORDER BY t.emergency_level, triage_cases DESC, hd.department_name;
