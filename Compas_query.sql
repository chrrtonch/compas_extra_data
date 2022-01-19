SELECT 
	*
FROM people p 
LEFT JOIN prisonhistory p2 ON p.id = p2.person_id

;
SELECT 
	p.person_id,
	count(*) AS count_prison_vists,
	sum(JULIANDAY(p.out_custody)- JULIANDAY(p.in_custody)) AS days_in_prison
FROM prisonhistory p 
GROUP BY person_id;

SELECT 
	j.person_id,
	count(*) AS count_jail_vists,
	sum(JULIANDAY(j.out_custody)- JULIANDAY(j.in_custody)) AS days_in_jail
FROM jailhistory j 
GROUP BY j.person_id ;
SELECT
	c.person_id AS id,
	c.marital_status,
	c.custody_status,
	count(DISTINCT p.id) AS count_prison_stays,
	-- count_prison stays over x_days
	sum(julianday(p.out_custody) - julianday(p.in_custody)) + 0 AS time_in_prison,
	ac.case_m,
	ac.case_f,
	ac.case_total,
	ac.case_hard,
	ac.case_drug,
	ac.case_gambling,
	cast(strftime('%Y.%m%d', ac.first_charge_date) - strftime('%Y.%m%d', p2.dob) as int) AS age_first_offense,
	COUNT(DISTINCT c2.id) AS count_arrest
FROM compas c 
LEFT JOIN prisonhistory p ON c.person_id = p.person_id AND p.in_custody < c.screening_date 
LEFT JOIN casearrest c2  ON c.person_id = c2.person_id  AND c2.arrest_date < c.screening_date 
LEFT JOIN (SELECT c.person_id,	SUM(CASE WHEN SUBSTRING(c.charge_degree,2,1) = 'M' THEN 1 ELSE 0 END) AS case_m, SUM(CASE WHEN SUBSTRING(c.charge_degree,2,1) = 'F' THEN 1 ELSE 0 END) AS case_f, MIN(c.offense_date) AS first_charge_date, SUM(CASE WHEN lower(c.charge) LIKE '%gambl%' THEN 1 ELSE 0 END) AS case_gambling, SUM(CASE WHEN lower(c.charge) LIKE '%murder%' THEN 1 WHEN lower(c.charge) LIKE '%assault%' THEN 1 WHEN lower(c.charge) LIKE '%sex%' THEN 1 WHEN lower(c.charge) LIKE '%aggravated%' THEN 1 WHEN lower(c.charge) LIKE '%grand theft%' THEN 1 ELSE 0 END) AS case_hard, SUM(CASE WHEN lower(c.charge) LIKE '%theft%' THEN 1 WHEN lower(c.charge) LIKE '%speed posted%' THEN 1 WHEN lower(c.charge) LIKE '%expired tag%' THEN 1 WHEN lower(c.charge) LIKE '%fail%' THEN 1 WHEN SUBSTRING(c.charge_degree,2,1) = '0' THEN 1 ELSE 0 END) AS case_light, SUM(CASE WHEN lower(c.charge) LIKE '%cocaine%' THEN 1 WHEN lower(c.charge) LIKE '%cannabis%' THEN 1 WHEN lower(c.charge) LIKE '%meth%' THEN 1	WHEN lower(c.charge) LIKE '%mdma%' THEN 1 WHEN lower(c.charge) LIKE '%lsd%' THEN 1 WHEN lower(c.charge) LIKE '%paraphernalia%' THEN 1 WHEN lower(c.charge) LIKE '%drug%' THEN 1 WHEN lower(c.charge) LIKE '%cannabis%' THEN 1 WHEN lower(c.charge) LIKE '%alprazolam%' THEN 1 ELSE 0 END) AS case_drug, COUNT(*) AS case_total FROM charge c GROUP BY 1 ORDER BY c.charge) ac ON c.person_id = ac.person_id
LEFT JOIN people p2 ON c.person_id = p2.id 
WHERE 1=1
AND c.type_of_assessment = 'Risk of Recidivism'
GROUP BY 1,2,3;

SELECT c.person_id,	SUM(CASE WHEN SUBSTRING(c.charge_degree,2,1) = 'M' THEN 1 ELSE 0 END) AS case_m, SUM(CASE WHEN SUBSTRING(c.charge_degree,2,1) = 'F' THEN 1 ELSE 0 END) AS case_f, MIN(c.offense_date) AS first_charge_date, SUM(CASE WHEN lower(c.charge) LIKE '%gambl%' THEN 1 ELSE 0 END) AS case_gambling, SUM(CASE WHEN lower(c.charge) LIKE '%murder%' THEN 1 WHEN lower(c.charge) LIKE '%assault%' THEN 1 WHEN lower(c.charge) LIKE '%sex%' THEN 1 WHEN lower(c.charge) LIKE '%aggravated%' THEN 1 WHEN lower(c.charge) LIKE '%grand theft%' THEN 1 ELSE 0 END) AS case_hard, SUM(CASE WHEN lower(c.charge) LIKE '%theft%' THEN 1 WHEN lower(c.charge) LIKE '%speed posted%' THEN 1 WHEN lower(c.charge) LIKE '%expired tag%' THEN 1 WHEN lower(c.charge) LIKE '%fail%' THEN 1 WHEN SUBSTRING(c.charge_degree,2,1) = '0' THEN 1 ELSE 0 END) AS case_light, SUM(CASE WHEN lower(c.charge) LIKE '%cocaine%' THEN 1 WHEN lower(c.charge) LIKE '%cannabis%' THEN 1 WHEN lower(c.charge) LIKE '%meth%' THEN 1	WHEN lower(c.charge) LIKE '%mdma%' THEN 1 WHEN lower(c.charge) LIKE '%lsd%' THEN 1 WHEN lower(c.charge) LIKE '%paraphernalia%' THEN 1 WHEN lower(c.charge) LIKE '%drug%' THEN 1 WHEN lower(c.charge) LIKE '%cannabis%' THEN 1 WHEN lower(c.charge) LIKE '%alprazolam%' THEN 1 ELSE 0 END) AS case_drug, COUNT(*) AS case_total FROM charge c GROUP BY 1 ORDER BY c.charge
;

SELECT * FROM charge WHERE charge LIKE '%punt%'


