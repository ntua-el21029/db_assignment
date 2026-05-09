//Q1
-- Q1: Συνολικά έσοδα νοσοκομείου ανά τμήμα και ανά έτος,
--     με ανάλυση ανά ΚΕΝ κωδικό (βασικό κόστος vs πρόσθετη χρέωση λόγω ΜΔΝ)
--     και κατανομή νοσηλειών ανά ασφαλιστικό φορέα (χωρίς ποσοστά).

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

//Q2
-- Q2: Για συγκεκριμένη ειδικότητα ιατρού (Χειρουργική), βρείτε όλους 
--     τους ιατρούς που ανήκουν σε αυτήν, με ένδειξη αν είχαν εφημερία (τρέχον έτος)
--     και πόσες επεμβάσεις εκτέλεσαν ως κύριοι χειρουργοί (συνολικά & τρέχον έτος).

SELECT 
    d.doctor_id                                     AS `Κωδικός Ιατρού`,
    e.empl_first_name                               AS `Όνομα`,
    e.empl_last_name                                AS `Επώνυμο`,
    dsp.specialty_name                              AS `Ειδικότητα`,
    dg.grade_description                            AS `Βαθμίδα`,
    e.empl_hiring_date                              AS `Ημ. Πρόσληψης`,

    -- Ένδειξη εφημερίας για το δυναμικό τρέχον έτος
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM duty_schedule_team dst
            JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
            WHERE dst.employee_id = e.employee_id 
              AND YEAR(ds.duty_date) = YEAR(CURDATE())
        ) THEN 'Ναι' 
        ELSE 'Όχι' 
    END                                             AS `Είχε Εφημερία (Τρέχον Έτος)`,

    -- Αριθμός εφημεριών για το δυναμικό τρέχον έτος
    (
        SELECT COUNT(*) 
        FROM duty_schedule_team dst
        JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
        WHERE dst.employee_id = e.employee_id 
          AND YEAR(ds.duty_date) = YEAR(CURDATE())
    )                                               AS `Σύνολο Εφημεριών (Τρέχον Έτος)`,

    -- Επεμβάσεις ως κύριος χειρουργός (όλα τα χρόνια ανεξαιρέτως)
    COUNT(ma.act_id)                                AS `Σύνολο Επεμβάσεων`,

    -- Επεμβάσεις ως κύριος χειρουργός (μόνο για το δυναμικό τρέχον έτος)
    SUM(CASE WHEN YEAR(ma.act_start) = YEAR(CURDATE()) THEN 1 ELSE 0 END) 
                                                    AS `Επεμβάσεις (Τρέχον Έτος)`

FROM doctor d
LEFT JOIN employee e           ON e.employee_id      = d.employee_id
LEFT JOIN doctor_specialty dsp ON dsp.specialty_id   = d.specialty_id
LEFT JOIN doctor_grade dg      ON dg.grade_id        = d.grade_id
LEFT JOIN medical_act ma       ON ma.main_surgeon_id = d.doctor_id

-- Φιλτράρισμα μόνο για τους Χειρουργούς (Ειδικότητα = 2)
WHERE d.specialty_id = 2 

GROUP BY 
    d.doctor_id, 
    e.empl_first_name, 
    e.empl_last_name, 
    dsp.specialty_name, 
    dg.grade_description, 
    e.empl_hiring_date,
    e.employee_id
ORDER BY 
    `Σύνολο Επεμβάσεων` DESC;

//Q5
SELECT 
    d.doctor_id                                         AS `Κωδικός Ιατρού`,
    e.empl_first_name                                   AS `Όνομα`,
    e.empl_last_name                                    AS `Επώνυμο`,
    TIMESTAMPDIFF(YEAR, e.empl_birth_date, CURDATE())   AS `Ηλικία`,
    COUNT(ma.act_id)                                    AS `Σύνολο Επεμβάσεων`
FROM doctor d
JOIN employee e      ON e.employee_id = d.employee_id
JOIN medical_act ma  ON ma.main_surgeon_id = d.doctor_id
-- Αυστηρό φίλτρο: Κάτω από 35 ετών
WHERE TIMESTAMPDIFF(YEAR, e.empl_birth_date, CURDATE()) < 35
GROUP BY 
    d.doctor_id, 
    e.empl_first_name, 
    e.empl_last_name, 
    e.empl_birth_date
ORDER BY 
    `Σύνολο Επεμβάσεων` DESC;
//Q6
-- Q6: Για συγκεκριμένο ασθενή, βρείτε το ιστορικό νοσηλειών του, 
--     τις αντίστοιχες διαγνώσεις (ICD-10), το συνολικό κόστος ανά νοσηλεία 
--     και τον μέσο όρο αξιολόγησής του.

-- Ορίζουμε τον συγκεκριμένο ασθενή που ψάχνουμε (π.χ. patient_id = 1)
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
