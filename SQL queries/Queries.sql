SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date::DATE AS date --remove the timestamp from the date column
FROM
    job_postings_fact

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' date --metatrepoume to timezone apo UTC (pou kseroume oti einai ta data mas) se EST.
FROM
    job_postings_fact

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' date,
    EXTRACT(MONTH FROM job_posted_date) AS Month
FROM
    job_postings_fact
LIMIT 5;

SELECT --Posa jobs exoun vgei ana mhna??
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS Month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    Month
ORDER BY
    job_posted_count DESC

CREATE TABLE january_jobs AS --thelw na ftiaxw ksexwristous pinakes gia kathe mhna.
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS --thelw na ftiaxw ksexwristous pinakes gia kathe mhna.
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS --thelw na ftiaxw ksexwristous pinakes gia kathe mhna.
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;


SELECT --thelw na dhmiourghsw ena neo column kai na grapsw px opou Anywhere, remote.
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact;


SELECT --thelw na dhmiourghsw ena neo column kai na grapsw px opou Anywhere, remote. Sth synexeia psaxnw me condition auto to column pou eftiaxa.
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;

--Subqueries and CTEs (Common Table Expressions)
--Used for organizing and simplifying complex queries. This is a temporary result set NOT a temporary table.
--Subqueries are for simpler queries
--CYEs are for more complex queries

SELECT *
FROM ( --Subquery starts here. It is always executed first and the result is passed to the outer query
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

WITH january_jobs AS ( --CTE definition starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) --CTE definition ends here

SELECT *
FROM january_jobs;


--Subqueries

SELECT -- poies etairies dexontai na mhn exeis ptuxio
  company_id, 
  name AS company_name --epestrepse ta company names
FROM 
  company_dim --apo auton ton pinaka pou exei ta names
WHERE 
  company_id IN (
    --gia ekeina ta company_id pou uparxoun ston apo katw pinaka
    SELECT 
      company_id 
    FROM 
      job_postings_fact 
    WHERE 
      job_no_degree_mention = true
  ) --einai san na kaname join


--CTEs

--Find the companies who have the most job openings.

WITH company_job_count AS ( --DEN MPORW NA TREXW MONO TO CTE GIATI EINAI ENA TEMPORARY RESULT SET INTENDED TO BE USED AS PART OF A LARGER QUERY.
  SELECT 
    company_id, 
    COUNT(*) AS total_jobs
  FROM 
    job_postings_fact 
  GROUP BY 
    company_id
)

SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC

--CTEs again

--Find the count of the number of remote job postings per skill

--We will first build a CTE that collects the number  of job postings and skill. So we will need to join with skills_job_dim. And when we have this we will join with the skills_dim table to obtain the skill name
--We need a count of jobs that actually exist. Don't really care for values that don't exist. So INNER JOIN

WITH remote_job_skills AS(
SELECT --apo edw mexri kai to group by otan to ftiaxoume leei we pretty much have our CTE built. Opote panta ksekinaei prwta apo mesa.
    skill_id,
    COUNT(*) AS skill_count
FROM
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE 
    job_postings.job_work_from_home = true AND
    job_postings.job_title_short = 'Data Engineer'
GROUP BY
    skill_id
) --Now that we we have combined fact table with skills job dim table and we have them in one table (the CTE) we will inner join with the skills dim table to obtain the skill name

SELECT 
    skills.skill_id,
    skills AS skill_name,
    remote_job_skills.skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5


--UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs

--UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs


--Find job postings from the first quarter that have a salary greater than $70K. We will do it with subquery.

SELECT
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::DATE,
    quarter1_job_postings.salary_year_avg
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000 AND
    quarter1_job_postings.job_title_short = 'Data Engineer'
ORDER BY
    salary_year_avg  DESC