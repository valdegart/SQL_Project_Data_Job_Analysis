/*
Question: What skills are required for the top-paying data engineer jobs?
-Use the top 10 highest-paying Data Engineer jobs from first query
-Add the specific skills required for these roles
-Why? It provides a detailed look at which high-paying jobs demand certain skills, helping job seekers uderstand which skills to develop that align with top salaries
*/

WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Engineer' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*, --select all the columns from that table
    skills_dim.skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY 
    salary_year_avg DESC

--we don't need left join because we don't really care too much for jobs that doesn't have any skills. Also not right join either because we don't care for skills that are not connected to a job. So inner join to obtain only those jobs that hav a skill that is connected to the skills dim table.