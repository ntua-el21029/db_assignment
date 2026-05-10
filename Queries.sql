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

//Q3
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
    

//Q4
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
//Q7
SELECT
    asub.active_substance_id,
    asub.substance_name,
    COUNT(DISTINCT pha.patient_id)   AS allergic_patients_count,
    COUNT(DISTINCT mhas.medication_id) AS medicines_containing_count
FROM active_substances asub
LEFT JOIN patient_has_allergy           pha  ON pha.active_substance_id  = asub.active_substance_id
LEFT JOIN medicine_has_active_substance mhas ON mhas.active_substance_id = asub.active_substance_id
GROUP BY asub.active_substance_id, asub.substance_name
ORDER BY allergic_patients_count DESC, medicines_containing_count DESC, asub.substance_name;

//Q8
SET @target_date = '2024-01-07';
SET @target_dept = 1;

WITH busy_employees AS (
    -- Όλοι οι υπάλληλοι που ΕΧΟΥΝ εφημερία στη συγκεκριμένη ημέρα/τμήμα
    SELECT DISTINCT dst.employee_id
    FROM duty_schedule_team dst
    JOIN duty_schedule ds ON ds.duty_id = dst.duty_id
    WHERE ds.duty_date = @target_date
      AND ds.hospital_department_id = @target_dept
)
SELECT
    'Doctor' AS staff_type,
    e.employee_id,
    e.empl_first_name,
    e.empl_last_name,
    e.empl_amka,
    e.empl_phone
FROM employee e
JOIN doctor   d ON d.employee_id = e.employee_id
WHERE e.employee_id NOT IN (SELECT employee_id FROM busy_employees)

UNION ALL

SELECT
    'Nurse' AS staff_type,
    e.employee_id,
    e.empl_first_name,
    e.empl_last_name,
    e.empl_amka,
    e.empl_phone
FROM employee e
JOIN nurse   n ON n.employee_id = e.employee_id
WHERE e.employee_id NOT IN (SELECT employee_id FROM busy_employees)

UNION ALL

SELECT
    'Admin' AS staff_type,
    e.employee_id,
    e.empl_first_name,
    e.empl_last_name,
    e.empl_amka,
    e.empl_phone
FROM employee e
JOIN administrative_staff a ON a.employee_id = e.employee_id
WHERE e.employee_id NOT IN (SELECT employee_id FROM busy_employees)

ORDER BY staff_type, empl_last_name, empl_first_name;

//Q9
WITH patient_year_days AS (
    SELECT 
        h.patient_id,
        YEAR(h.admission_date) AS adm_year,
        SUM(DATEDIFF(h.discharge_date, h.admission_date)) AS total_days
    FROM hospitalization h
    WHERE h.discharge_date IS NOT NULL
    GROUP BY h.patient_id, YEAR(h.admission_date)
    HAVING SUM(DATEDIFF(h.discharge_date, h.admission_date)) > 15
),
matching_groups AS (
    -- Ζεύγη (έτος, total_days) όπου τουλάχιστον 2 ασθενείς έχουν 
    -- τον ίδιο συνολικό αριθμό ημερών μέσα στο ίδιο έτος.
    SELECT adm_year, total_days
    FROM patient_year_days
    GROUP BY adm_year, total_days
    HAVING COUNT(DISTINCT patient_id) >= 2
)
SELECT
    pyd.adm_year,
    pyd.total_days,
    pyd.patient_id,
    p.first_name,
    p.last_name,
    p.amka
FROM patient_year_days pyd
JOIN matching_groups mg
  ON mg.adm_year   = pyd.adm_year
 AND mg.total_days = pyd.total_days
JOIN patient p ON p.patient_id = pyd.patient_id
ORDER BY pyd.adm_year, pyd.total_days DESC, pyd.patient_id;

//Q10
WITH co_prescribed_pairs AS (
    SELECT DISTINCT
        h.hospitalization_id,
        h.patient_id,
        s1.active_substance_id AS substance_a,
        s2.active_substance_id AS substance_b
    FROM hospitalization h
    -- Πρώτη συνταγή στη νοσηλεία
    JOIN medication_treatment   mt1 ON mt1.patient_id = h.patient_id
    JOIN medication_prescription mp1 ON mp1.prescription_id = mt1.med_prescription_id
                                     AND mp1.start_date >= DATE(h.admission_date)
                                     AND mp1.start_date <= DATE(IFNULL(h.discharge_date, mp1.start_date))
    JOIN medicine_has_active_substance s1 ON s1.medication_id = mt1.medicine_id
    -- Δεύτερη συνταγή στην ίδια νοσηλεία (ίδιος ασθενής)
    JOIN medication_treatment   mt2 ON mt2.patient_id = h.patient_id
                                    AND mt2.treatment_id <> mt1.treatment_id
    JOIN medication_prescription mp2 ON mp2.prescription_id = mt2.med_prescription_id
                                     AND mp2.start_date >= DATE(h.admission_date)
                                     AND mp2.start_date <= DATE(IFNULL(h.discharge_date, mp2.start_date))
    JOIN medicine_has_active_substance s2 ON s2.medication_id = mt2.medicine_id
    WHERE h.discharge_date IS NOT NULL
      -- Χρονική επικάλυψη των δύο συνταγών
      AND mp1.start_date <= mp2.end_date
      AND mp2.start_date <= mp1.end_date
      -- Ζεύγος χωρίς διπλομέτρηση και χωρίς αυτο-αναφορά
      AND s1.active_substance_id < s2.active_substance_id
)
SELECT
    cpp.substance_a,
    a1.substance_name AS substance_a_name,
    cpp.substance_b,
    a2.substance_name AS substance_b_name,
    COUNT(*)          AS co_prescription_count
FROM co_prescribed_pairs cpp
JOIN active_substances a1 ON a1.active_substance_id = cpp.substance_a
JOIN active_substances a2 ON a2.active_substance_id = cpp.substance_b
GROUP BY cpp.substance_a, a1.substance_name, cpp.substance_b, a2.substance_name
ORDER BY co_prescription_count DESC, a1.substance_name, a2.substance_name
LIMIT 3;

//Q11
SET @yr = YEAR(CURDATE());

WITH ops_per_doctor AS (
    SELECT 
        d.doctor_id,
        COUNT(ma.act_id) AS ops_count
    FROM doctor d
    LEFT JOIN medical_act ma 
           ON ma.main_surgeon_id = d.doctor_id
          AND YEAR(ma.act_start) = @yr
    GROUP BY d.doctor_id
),
max_ops AS (
    SELECT MAX(ops_count) AS max_count FROM ops_per_doctor
)
SELECT
    opd.doctor_id,
    e.empl_first_name,
    e.empl_last_name,
    sp.specialty_name,
    opd.ops_count,
    mo.max_count,
    (mo.max_count - opd.ops_count) AS difference_from_max
FROM ops_per_doctor opd
CROSS JOIN max_ops mo
JOIN doctor           dr ON dr.doctor_id   = opd.doctor_id
JOIN employee         e  ON e.employee_id  = dr.employee_id
JOIN doctor_specialty sp ON sp.specialty_id = dr.specialty_id
WHERE (mo.max_count - opd.ops_count) >= 5
ORDER BY opd.ops_count DESC, e.empl_last_name;

//Q12
SET @week_start = '2024-01-01';
SET @week_end   = '2024-01-07';

WITH date_range AS (
    -- Παράγουμε με 100% ασφαλή τρόπο τις 7 ημέρες της εβδομάδας χωρίς "RECURSIVE"
    SELECT @week_start AS d
    UNION ALL SELECT DATE_ADD(@week_start, INTERVAL 1 DAY)
    UNION ALL SELECT DATE_ADD(@week_start, INTERVAL 2 DAY)
    UNION ALL SELECT DATE_ADD(@week_start, INTERVAL 3 DAY)
    UNION ALL SELECT DATE_ADD(@week_start, INTERVAL 4 DAY)
    UNION ALL SELECT DATE_ADD(@week_start, INTERVAL 5 DAY)
    UNION ALL SELECT DATE_ADD(@week_start, INTERVAL 6 DAY)
),
slots AS (
    -- Καρτεσιανό γινόμενο: Τμήματα x Ημέρες x Βάρδιες
    SELECT 
        hd.department_id,
        hd.department_name,
        dr.d AS duty_date,
        st.shift_type_id,
        st.shift_type
    FROM hospital_department hd
    CROSS JOIN date_range dr
    CROSS JOIN shift_type st
),
assignments AS (
    -- Όλοι οι εκχωρημένοι υπάλληλοι ανά slot, με την υποκατηγορία τους.
    SELECT 
        s.department_id,
        s.department_name,
        s.duty_date,
        s.shift_type,
        e.empl_type,
        COALESCE(spec.specialty_name, ng.grade_description, sr.role_description) AS sub_category,
        e.employee_id
    FROM slots s
    LEFT JOIN duty_schedule ds 
           ON ds.duty_date              = s.duty_date
          AND ds.shift_type_id          = s.shift_type_id
          AND ds.hospital_department_id = s.department_id
    LEFT JOIN duty_schedule_team dst ON dst.duty_id = ds.duty_id
    LEFT JOIN employee e             ON e.employee_id = dst.employee_id
    LEFT JOIN doctor    d   ON d.employee_id = e.employee_id  AND e.empl_type = 'doctor'
    LEFT JOIN doctor_specialty spec ON spec.specialty_id = d.specialty_id
    LEFT JOIN nurse     n   ON n.employee_id = e.employee_id  AND e.empl_type = 'nurse'
    LEFT JOIN nurse_grade ng ON ng.nurse_grade_id = n.nurse_grade_id
    LEFT JOIN administrative_staff a ON a.employee_id = e.employee_id AND e.empl_type = 'administrative_staff'
    LEFT JOIN staff_role sr ON sr.role_id = a.role_id
)
SELECT
    department_name                              AS `Τμήμα`,
    duty_date                                    AS `Ημερομηνία`,
    shift_type                                   AS `Βάρδια`,
    empl_type                                    AS `Κατηγορία Προσωπικού`,
    sub_category                                 AS `Ανάλυση (Υποκλάση)`,
    COUNT(employee_id)                           AS `Άτομα που έχουν ανατεθεί`,
    
    -- Ολικό απαιτούμενο μίνιμο ανά κατηγορία (από εκφώνηση)
    CASE empl_type
        WHEN 'doctor'               THEN 3
        WHEN 'nurse'                THEN 6
        WHEN 'administrative_staff' THEN 2
        ELSE NULL
    END                                          AS `Απαιτούμενα Άτομα (Ελάχιστο)`
    
FROM assignments
WHERE empl_type IS NOT NULL  -- Κρύβουμε τα κενά slots για να είναι καθαρό το report
GROUP BY 
    department_id, 
    department_name, 
    duty_date, 
    shift_type, 
    empl_type, 
    sub_category
ORDER BY 
    `Τμήμα`, 
    `Ημερομηνία`, 
    FIELD(shift_type, 'Morning', 'Afternoon', 'Night'),
    empl_type, 
    sub_category;

//Q13
WITH RECURSIVE supervision_chain AS (
    -- Anchor: κάθε γιατρός με τον εαυτό του στο level 0
    SELECT
        d.doctor_id        AS doctor_id,
        d.doctor_id        AS ancestor_id,
        d.supervisor_doctor_id AS next_supervisor,
        0                  AS level
    FROM doctor d

    UNION ALL

    -- Recursive: ανέβα ένα επίπεδο προς τον επόπτη
    SELECT
        sc.doctor_id,
        d.doctor_id,
        d.supervisor_doctor_id,
        sc.level + 1
    FROM supervision_chain sc
    JOIN doctor d ON d.doctor_id = sc.next_supervisor
    WHERE sc.next_supervisor IS NOT NULL
      AND sc.level < 50  -- safety guard ενάντια σε accidental cycles
)
SELECT
    sc.doctor_id,
    e_self.empl_first_name  AS doctor_first_name,
    e_self.empl_last_name   AS doctor_last_name,
    g_self.grade_description AS doctor_grade,
    sc.level,
    sc.ancestor_id,
    e_anc.empl_first_name   AS ancestor_first_name,
    e_anc.empl_last_name    AS ancestor_last_name,
    g_anc.grade_description AS ancestor_grade
FROM supervision_chain sc
JOIN doctor      d_self ON d_self.doctor_id = sc.doctor_id
JOIN employee    e_self ON e_self.employee_id = d_self.employee_id
JOIN doctor_grade g_self ON g_self.grade_id = d_self.grade_id
JOIN doctor      d_anc  ON d_anc.doctor_id = sc.ancestor_id
JOIN employee    e_anc  ON e_anc.employee_id = d_anc.employee_id
JOIN doctor_grade g_anc ON g_anc.grade_id = d_anc.grade_id
ORDER BY sc.doctor_id, sc.level;

//Q14
WITH cat_year_admissions AS (
    SELECT
        icd.icd_category,
        YEAR(h.admission_date) AS adm_year,
        COUNT(*)               AS admission_count
    FROM hospitalization h
    JOIN icd10_codes icd ON icd.icd_id = h.ICD10_admission_id
    GROUP BY icd.icd_category, YEAR(h.admission_date)
    HAVING COUNT(*) >= 5
)
SELECT
    a.icd_category,
    a.adm_year       AS year_n,
    a.admission_count AS admissions_year_n,
    b.adm_year       AS year_n_plus_1,
    b.admission_count AS admissions_year_n_plus_1
FROM cat_year_admissions a
JOIN cat_year_admissions b
  ON b.icd_category   = a.icd_category
 AND b.adm_year       = a.adm_year + 1
 AND b.admission_count = a.admission_count
ORDER BY a.icd_category, a.adm_year;

//Q15
(
    -- Section 1: Κατανομή & metrics ΑΝΑ ΕΠΙΠΕΔΟ ΕΠΕΙΓΟΝΤΟΣ
    SELECT
        'BY_LEVEL'                                    AS report_section,
        CAST(t.emergency_level AS CHAR)               AS dimension_key,
        CONCAT('Level ', t.emergency_level)           AS dimension_label,
        COUNT(*)                                      AS triage_cases,
        ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total,
        ROUND(AVG(TIMESTAMPDIFF(MINUTE, t.arrival_time, h.admission_date)), 2) 
                                                      AS avg_wait_minutes,
        SUM(CASE WHEN h.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END) 
                                                      AS led_to_hospitalization,
        ROUND(100.0 * SUM(CASE WHEN h.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END)
                    / COUNT(*), 2)                    AS pct_hospitalized
    FROM triage t
    LEFT JOIN hospitalization h ON h.triage_id = t.triage_id
    GROUP BY t.emergency_level
)
UNION ALL
(
    -- Section 2: Κατανομή ΠΑΡΑΠΟΜΠΩΝ ΑΝΑ ΤΜΗΜΑ (μόνο όσα οδήγησαν σε νοσηλεία)
    SELECT
        'BY_DEPARTMENT'                                       AS report_section,
        CAST(d.department_id AS CHAR)                         AS dimension_key,
        d.department_name                                     AS dimension_label,
        COUNT(*)                                              AS triage_cases,
        ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)    AS pct_of_total,
        NULL                                                  AS avg_wait_minutes,
        COUNT(*)                                              AS led_to_hospitalization,
        100.00                                                AS pct_hospitalized
    FROM triage t
    JOIN hospitalization     h ON h.triage_id = t.triage_id
    JOIN hospital_department d ON d.department_id = h.department_id
    GROUP BY d.department_id, d.department_name
)
ORDER BY report_section, dimension_key;
