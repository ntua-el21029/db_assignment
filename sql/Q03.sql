-- Q03: Ασθενείς που έχουν νοσηλευτεί περισσότερες από 3 φορές στο ίδιο τμήμα,
-- με το συνολικό κόστος νοσηλείας τους (αθροιστικά για το συγκεκριμένο τμήμα).

SELECT
    p.patient_id,
    p.amka,
    p.first_name,
    p.last_name,
    hd.department_id,
    hd.department_name,
    COUNT(h.hospitalization_id)            AS num_hospitalizations,
    SUM(COALESCE(h.total_cost, 0))         AS total_cost_in_department
FROM hospitalization h
JOIN patient             p  ON h.patient_id    = p.patient_id
JOIN hospital_department hd ON h.department_id = hd.department_id
GROUP BY
    p.patient_id, p.amka, p.first_name, p.last_name,
    hd.department_id, hd.department_name
HAVING COUNT(h.hospitalization_id) > 3
ORDER BY num_hospitalizations DESC, total_cost_in_department DESC;
