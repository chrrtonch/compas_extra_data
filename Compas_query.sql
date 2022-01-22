
SELECT
	c.person_id AS id,
	c.marital_status,
	c.custody_status
FROM compas c 
LEFT JOIN prisonhistory p ON c.person_id = p.person_id AND p.in_custody < c.screening_date 
LEFT JOIN casearrest c2  ON c.person_id = c2.person_id  AND c2.arrest_date < c.screening_date 
LEFT JOIN people p2 ON c.person_id = p2.id 
LEFT JOIN (SELECT c.person_id, min(c.date_charge_filed) AS first_charge_date FROM charge c GROUP BY c.person_id) ac ON c.person_id = ac.person_id
WHERE 1=1
AND c.type_of_assessment = 'Risk of Recidivism'
GROUP BY 1,2,3,4
ORDER BY id;

SELECT c.person_id,	SUM(CASE WHEN SUBSTRING(c.charge_degree,2,1) = 'M' THEN 1 ELSE 0 END) AS case_m, SUM(CASE WHEN SUBSTRING(c.charge_degree,2,1) = 'F' THEN 1 ELSE 0 END) AS case_f, MIN(c.offense_date) AS first_charge_date, SUM(CASE WHEN lower(c.charge) LIKE '%gambl%' THEN 1 ELSE 0 END) AS case_gambling, SUM(CASE WHEN lower(c.charge) LIKE '%murder%' THEN 1 WHEN lower(c.charge) LIKE '%assault%' THEN 1 WHEN lower(c.charge) LIKE '%sex%' THEN 1 WHEN lower(c.charge) LIKE '%aggravated%' THEN 1 WHEN lower(c.charge) LIKE '%grand theft%' THEN 1 ELSE 0 END) AS case_hard, SUM(CASE WHEN lower(c.charge) LIKE '%theft%' THEN 1 WHEN lower(c.charge) LIKE '%speed posted%' THEN 1 WHEN lower(c.charge) LIKE '%expired tag%' THEN 1 WHEN lower(c.charge) LIKE '%fail%' THEN 1 WHEN SUBSTRING(c.charge_degree,2,1) = '0' THEN 1 ELSE 0 END) AS case_light, SUM(CASE WHEN lower(c.charge) LIKE '%cocaine%' THEN 1 WHEN lower(c.charge) LIKE '%cannabis%' THEN 1 WHEN lower(c.charge) LIKE '%meth%' THEN 1	WHEN lower(c.charge) LIKE '%mdma%' THEN 1 WHEN lower(c.charge) LIKE '%lsd%' THEN 1 WHEN lower(c.charge) LIKE '%paraphernalia%' THEN 1 WHEN lower(c.charge) LIKE '%drug%' THEN 1 WHEN lower(c.charge) LIKE '%cannabis%' THEN 1 WHEN lower(c.charge) LIKE '%alprazolam%' THEN 1 ELSE 0 END) AS case_drug, COUNT(*) AS case_total FROM charge c GROUP BY 1 ORDER BY c.charge
;
-- takes ~6h dont rerun this mess
SELECT 
	c.case_number,
	(SELECT count(*) FROM charge c2 WHERE c2.person_id = c.person_id AND c2.date_charge_filed < c.date_charge_filed) AS case_total,
	(SELECT count(*) FROM charge c2 WHERE c2.person_id = c.person_id AND c2.date_charge_filed < c.date_charge_filed AND SUBSTRING(c2.charge_degree,2,1) = 'M') AS case_m,
	(SELECT count(*) FROM charge c2 WHERE c2.person_id = c.person_id AND c2.date_charge_filed < c.date_charge_filed AND SUBSTRING(c2.charge_degree,2,1) = 'F') AS case_f,
	(SELECT count(*) FROM charge c2 WHERE c2.person_id = c.person_id AND c2.date_charge_filed < c.date_charge_filed AND lower(c2.charge) LIKE '%gambl%') AS case_gambling,
	(SELECT count(*) FROM charge c2 WHERE c2.person_id = c.person_id AND c2.date_charge_filed < c.date_charge_filed AND (lower(c2.charge) LIKE '%murder%' OR lower(c2.charge) LIKE '%assault%' OR lower(c2.charge) LIKE '%sex%' OR lower(c2.charge) LIKE '%aggravated%' OR lower(c2.charge) LIKE '%grand theft%')) AS case_hard,
	(SELECT count(*) FROM charge c2 WHERE c2.person_id = c.person_id AND c2.date_charge_filed < c.date_charge_filed AND (lower(c2.charge) LIKE '%cocaine%' OR lower(c2.charge) LIKE '%cannabis%' OR lower(c2.charge) LIKE '%meth%' OR lower(c2.charge) LIKE '%mdma%' OR lower(c2.charge) LIKE '%lsd%' OR lower(c2.charge) LIKE '%paraphernalia%' OR lower(c2.charge) LIKE '%drug%' OR lower(c2.charge) LIKE '%cannabis%' OR lower(c2.charge) LIKE '%alprazolam%')) AS case_drugs
FROM charge c
WHERE c.charge_degree != '(0)'
GROUP BY 1;


-- takes ~ 30 min
SELECT 
	c.case_number,
	sum(julianday(p.out_custody) - julianday(p.in_custody)) + 0 AS time_in_prison,
	COUNT(DISTINCT p.id) AS count_prison_stays,
	cast(strftime('%Y.%m%d', c2.first_charge_date) - strftime('%Y.%m%d', p2.dob) as int) AS age_first_offense,
	(SELECT count(*) FROM casearrest ca WHERE ca.person_id =c.person_id AND ca.arrest_date < c.date_charge_filed) AS count_arrests
FROM (SELECT c.case_number, c.person_id, c.date_charge_filed FROM charge c GROUP BY 1,2,3) c
LEFT JOIN prisonhistory p ON c.person_id = p.person_id AND c.date_charge_filed > p.out_custody 
LEFT JOIN (SELECT c.person_id, min(c.date_charge_filed) AS first_charge_date FROM charge c GROUP BY 1) c2 ON c.person_id = c2.person_id
LEFT JOIN people p2 ON c.person_id = p2.id 
GROUP BY c.case_number
;

SELECT c.person_id, min(c.date_charge_filed) AS first_charge_date FROM charge c GROUP BY 1;

SELECT c.person_id, count(*) FROM casearrest c;

SELECT 
	c.person_id,
	c.marital_status,
	c.custody_status,
	c.screening_date 
FROM compas c 
WHERE c.type_of_assessment = 'Risk of Recidivism'
GROUP BY 1,2,3,4
ORDER BY 1

SELECT c.person_id, c.screening_date 
FROM compas c WHERE c.type_of_assessment = 'Risk of Recidivism'
GROUP BY 1,2

SELECT 
	c.person_id, 
	count(*), 
	max(c.screening_date), 
	min(c.screening_date), 
	julianday(max(c.screening_date)) - julianday(min(c.screening_date))
FROM compas c WHERE c.type_of_assessment = 'Risk of Recidivism'
GROUP BY 1
HAVING count(*) = 2
ORDER BY 5 asc

SELECT * FROM charge c WHERE c.case_number = '00000155CF10A';


SELECT * FROM prisonhistory p WHERE p.person_id = 2382 AND p.out_custody < '2000-01-02 00:00:00'