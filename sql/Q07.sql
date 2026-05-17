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
