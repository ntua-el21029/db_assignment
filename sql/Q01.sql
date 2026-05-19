-- Q01: Συνολικά έσοδα νοσοκομείου ανά τμήμα και έτος, με ανάλυση ανά ΚΕΝ
-- (βασικό κόστος vs πρόσθετη χρέωση λόγω υπέρβασης ΜΔΝ) και κατανομή
-- νοσηλειών ανά ασφαλιστικό φορέα.
SELECT
    hd.department_name                                  AS department,
    YEAR(h.discharge_date)                              AS year,
    ks.ken_code                                         AS ken_code,
    ks.ken_description                                  AS ken_description,
    p.insurance_provider                                AS insurance_provider,
    COUNT(h.hospitalization_id)                         AS num_hospitalizations,
    SUM(ks.base_cost)                                   AS revenue_base_ken,
    SUM(h.extra_days_cost)                              AS revenue_extra_days,
    SUM(h.total_cost)                                   AS revenue_total
FROM hospitalization h
JOIN hospital_department hd ON h.department_id = hd.department_id
JOIN ken_system           ks ON h.ken_id        = ks.ken_id
JOIN patient              p  ON h.patient_id    = p.patient_id
WHERE h.discharge_date IS NOT NULL
GROUP BY
    hd.department_name,
    YEAR(h.discharge_date),
    ks.ken_code,
    ks.ken_description,
    p.insurance_provider;
