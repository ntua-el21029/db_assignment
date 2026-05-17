-- Q07: Για κάθε δραστική ουσία, αριθμός ασθενών με δηλωμένη αλλεργία και
-- αριθμός φαρμάκων που την περιέχουν, ταξινομημένα κατά συνολικό αριθμό
-- αλλεργικών ασθενών (φθίνουσα).

SELECT
    asb.active_substance_id,
    asb.substance_name,
    COUNT(DISTINCT pha.patient_id)         AS num_allergic_patients,
    COUNT(DISTINCT mhas.medication_id)     AS num_medicines
FROM active_substances asb
LEFT JOIN patient_has_allergy            pha  ON asb.active_substance_id = pha.active_substance_id
LEFT JOIN medicine_has_active_substance  mhas ON asb.active_substance_id = mhas.active_substance_id
GROUP BY asb.active_substance_id, asb.substance_name
ORDER BY num_allergic_patients DESC, num_medicines DESC, asb.substance_name;
