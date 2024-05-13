--to eixa etoimo auto apo proigoumeno erwthma
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
    skills AS skill_name,
    remote_job_skills.skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5

/*
Question: What are the most in-demand skills for data engineers?
-Join job postings to inner join table similar to query 2
-Identify the top 5 in-demand skills for a data engineer.
-Focus on all job postings.
-Why? Retrieves the top 5 skills with the highest demand in the job market, providing insights into the most valuable skills for job seekers.
---We are rewriting the above query to make it shorter---
*/

SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Engineer' AND
    job_work_from_home = true
GROUP BY 
    skills
ORDER BY
    demand_count DESC
LIMIT 5
