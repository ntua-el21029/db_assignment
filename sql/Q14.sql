-- Q14: Κατηγορίες ICD-10 με τον ΙΔΙΟ αριθμό εισαγωγών σε δύο συνεχόμενα έτη,
-- με τουλάχιστον 5 περιστατικά ανά έτος.

WITH category_year_counts AS (
    SELECT
        icd.icd_category,
        YEAR(h.admission_date)            AS year,
        COUNT(*)                          AS admission_count
    FROM hospitalization h
    JOIN ICD10_codes icd ON h.ICD10_admission_id = icd.icd_id
    GROUP BY icd.icd_category, YEAR(h.admission_date)
    HAVING COUNT(*) >= 5
)
SELECT
    a.icd_category,
    a.year                AS year_1,
    b.year                AS year_2,
    a.admission_count     AS admissions_per_year
FROM category_year_counts a
JOIN category_year_counts b
       ON a.icd_category    = b.icd_category
      AND b.year             = a.year + 1
      AND a.admission_count  = b.admission_count
ORDER BY a.icd_category, a.year;
