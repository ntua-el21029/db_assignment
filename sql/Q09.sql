-- Q09: Ασθενείς που νοσηλεύτηκαν τον ΙΔΙΟ αριθμό ημερών σε διάστημα ενός
-- έτους (καλεντρικού), με συνολική διάρκεια άνω των 15 ημερών.
-- Επιστρέφει ομάδες ασθενών με κοινό σύνολο ημερών ανά έτος.

WITH patient_year_totals AS (
    SELECT
        p.patient_id,
        p.first_name,
        p.last_name,
        YEAR(h.admission_date)                                    AS year,
        SUM(DATEDIFF(h.discharge_date, h.admission_date))         AS total_days,
        COUNT(*)                                                  AS num_hospitalizations
    FROM hospitalization h
    JOIN patient p ON h.patient_id = p.patient_id
    WHERE h.discharge_date IS NOT NULL
    GROUP BY p.patient_id, p.first_name, p.last_name, YEAR(h.admission_date)
    HAVING SUM(DATEDIFF(h.discharge_date, h.admission_date)) > 15
)
SELECT
    a.year,
    a.total_days,
    a.patient_id,
    a.first_name,
    a.last_name,
    a.num_hospitalizations
FROM patient_year_totals a
WHERE EXISTS (
    SELECT 1
    FROM patient_year_totals b
    WHERE b.year       = a.year
      AND b.total_days = a.total_days
      AND b.patient_id <> a.patient_id
)
ORDER BY a.year, a.total_days DESC, a.patient_id;
