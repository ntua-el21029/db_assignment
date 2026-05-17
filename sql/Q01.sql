SELECT
    hd.department_name                              AS `Τμήμα`,
    YEAR(h.admission_date)                          AS `Έτος`,
    ks.ken_code                                     AS `Κωδικός ΚΕΝ`,
    ks.ken_description                              AS `Περιγραφή ΚΕΝ`,
    ks.mdn_days                                     AS `ΜΔΝ`,

    -- Αριθμός νοσηλειών
    COUNT(h.hospitalization_id)                     AS `Σύνολο Νοσηλειών`,

    -- Βασικό κόστος (από ΚΕΝ × αριθμό νοσηλειών)
    SUM(ks.base_cost)                               AS `Συνολικό Βασικό Κόστος`,

    -- Πρόσθετη χρέωση λόγω υπέρβασης ΜΔΝ
    SUM(h.extra_days_cost)                          AS `Συνολική Πρόσθετη Χρέωση`,

    -- Συνολικά έσοδα 
    SUM(h.total_cost_with_exams_acts)               AS `Συνολικά Έσοδα`,

    -- Κατανομή ανά ασφαλιστικό φορέα (Απόλυτοι αριθμοί)
    SUM(CASE WHEN p.insurance_provider = 'Public'   THEN 1 ELSE 0 END) AS `Δημόσια Ασφάλιση`,
    SUM(CASE WHEN p.insurance_provider = 'Private'  THEN 1 ELSE 0 END) AS `Ιδιωτική Ασφάλιση`,
    SUM(CASE WHEN p.insurance_provider = 'None'     THEN 1 ELSE 0 END) AS `Ανασφάλιστοι`

FROM hospitalization h
JOIN hospital_department hd ON hd.department_id    = h.department_id
JOIN ken_system ks          ON ks.ken_id           = h.ken_id
JOIN patient p              ON p.patient_id         = h.patient_id
WHERE h.discharge_date IS NOT NULL
GROUP BY
    hd.department_name,
    YEAR(h.admission_date),
    ks.ken_code,
    ks.ken_description,
    ks.mdn_days
ORDER BY
    hd.department_name,
    `Έτος`,
    `Συνολικά Έσοδα` DESC;    
