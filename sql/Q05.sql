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
