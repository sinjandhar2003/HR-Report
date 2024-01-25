USE HR;

SELECT * FROM hr_data; 

SELECT TERMDATE FROM hr_data ORDER BY termdate DESC;

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME,LEFT(termdate,19),120),'yyyy-MM-dd');

ALTER TABLE hr_data ADD new_termdate DATE;

UPDATE hr_data SET new_termdate = CASE
WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST (termdate AS DATETIME) ELSE NULL END;

ALTER TABLE hr_data ADD age nvarchar(50);

UPDATE hr_data SET age = DATEDIFF(YEAR, birthdate, GETDATE());


SELECT MIN(AGE) AS youngest,
MAX(AGE) AS oldest from hr_data;


SELECT age_group, COUNT(*) AS count FROM
(SELECT
CASE
WHEN AGE>=21 AND AGE<=30 THEN '21 TO 30'
WHEN AGE>=31 AND AGE<=40 THEN '31 TO 40'
WHEN AGE>=41 AND AGE<=50 THEN '41 TO 50'
ELSE '50+'
END AS age_group
FROM hr_data
WHERE new_termdate IS NULL ) AS subquery 
GROUP BY age_group
ORDER BY age_group;


SELECT age_group, gender, COUNT(*) AS count FROM
(SELECT
CASE
WHEN AGE>=21 AND AGE<=30 THEN '21 TO 30'
WHEN AGE>=31 AND AGE<=40 THEN '31 TO 40'
WHEN AGE>=41 AND AGE<=50 THEN '41 TO 50'
ELSE '50+'
END AS age_group, gender
FROM hr_data
WHERE new_termdate IS NULL ) AS subquery 
GROUP BY age_group, gender
ORDER BY age_group, gender;


SELECT gender, COUNT(gender) AS count
FROM hr_data WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender;


SELECT department, gender, COUNT(gender) AS count
FROM hr_data WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender;


SELECT department, jobtitle, gender, COUNT(gender) AS count
FROM hr_data WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender;


SELECT race, COUNT(*) AS count
FROM hr_data WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;


SELECT AVG(DATEDIFF(YEAR, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();



SELECT department, total_count, terminated_count,
ROUND((CAST(terminated_count AS float)/total_count),2)*100 AS turnover_rate
FROM
	(SELECT department, COUNT(*) AS total_count,
	SUM(CASE
	WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
	END) AS terminated_count
	FROM hr_data
	GROUP BY department) AS subquery
ORDER BY turnover_rate DESC;



SELECT 
department, AVG(DATEDIFF(YEAR, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;


SELECT location, COUNT(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location;



SELECT location_state, COUNT(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;



SELECT jobtitle, COUNT(*) AS count
FROM hr_data WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;


SELECT hire_year, hires, terminations,
hires - terminations AS net_change,
ROUND(CAST(hires - terminations AS float)/hires,2)*100 AS percent_hire_change
FROM
	(SELECT YEAR(hire_date) AS hire_year,
	COUNT(*) AS hires,
	SUM( CASE 
	WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
	END) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)) AS subquery
ORDER BY percent_hire_change;