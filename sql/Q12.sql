-- Q12: Πλήθος (προγραμματισμένου) προσωπικού ανά τμήμα και ανά βάρδια για
-- συγκεκριμένη εβδομάδα, με ανάλυση ανά υποκλάση:
--   - Ιατροί ανά ειδικότητα
--   - Νοσηλευτές ανά βαθμίδα
--   - Διοικητικό προσωπικό ανά ρόλο
-- Παράμετροι: '2026-04-13' (Δευτέρα) έως '2026-04-19' (Κυριακή)

SELECT
    hd.department_name,
    ds.duty_date,
    st.shift_type                                                          AS shift,
    e.empl_type,
    COALESCE(sp.specialty_name, ng.grade_description, sr.role_description) AS subclass,
    COUNT(*)                                                               AS personnel_count
FROM duty_schedule       ds
JOIN hospital_department hd  ON ds.hospital_department_id = hd.department_id
JOIN shift_type          st  ON ds.shift_type_id          = st.shift_type_id
JOIN duty_schedule_team  dst ON ds.duty_id                = dst.duty_id
JOIN employee            e   ON dst.employee_id           = e.employee_id
LEFT JOIN doctor              d  ON e.employee_id = d.employee_id
LEFT JOIN doctor_specialty    sp ON d.specialty_id = sp.specialty_id
LEFT JOIN nurse               n  ON e.employee_id = n.employee_id
LEFT JOIN nurse_grade         ng ON n.nurse_grade_id = ng.nurse_grade_id
LEFT JOIN administrative_staff a ON e.employee_id = a.employee_id
LEFT JOIN staff_role          sr ON a.role_id = sr.role_id
WHERE ds.duty_date BETWEEN '2026-04-13' AND '2026-04-19'   -- <-- εβδομάδα
GROUP BY
    hd.department_name,
    ds.duty_date,
    st.shift_type,
    e.empl_type,
    subclass
ORDER BY
    hd.department_name,
    ds.duty_date,
    FIELD(st.shift_type, 'Morning', 'Afternoon', 'Night'),
    e.empl_type,
    subclass;
