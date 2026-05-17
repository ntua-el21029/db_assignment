-- Q10: Top-3 ζεύγη δραστικών ουσιών που συνταγογραφήθηκαν ταυτόχρονα
-- στον ίδιο ασθενή κατά την ίδια νοσηλεία, ταξινομημένα κατά συχνότητα.
-- "Ταυτόχρονα" = ίδιο hospitalization_id.

SELECT
    asb1.substance_name                         AS substance_1,
    asb2.substance_name                         AS substance_2,
    COUNT(*)                                    AS co_prescription_frequency
FROM medication_treatment mt1
JOIN medication_treatment mt2
       ON mt1.patient_id         = mt2.patient_id
      AND mt1.hospitalization_id = mt2.hospitalization_id
      AND mt1.medicine_id        < mt2.medicine_id
JOIN medicine_has_active_substance mhas1 ON mt1.medicine_id = mhas1.medication_id
JOIN medicine_has_active_substance mhas2 ON mt2.medicine_id = mhas2.medication_id
JOIN active_substances asb1 ON mhas1.active_substance_id = asb1.active_substance_id
JOIN active_substances asb2 ON mhas2.active_substance_id = asb2.active_substance_id
WHERE asb1.active_substance_id < asb2.active_substance_id     -- αποφυγή διπλασιασμού/ίδιας ουσίας
GROUP BY asb1.substance_name, asb2.substance_name
ORDER BY co_prescription_frequency DESC
LIMIT 3;
