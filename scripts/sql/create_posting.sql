/** 
    Please note that there are a small number of overlaps between tables:
        - master AND timelog = 4
        - master AND title = 414
        - timelog AND title = 0
 */
DROP TABLE IF EXISTS posting;
CREATE TABLE posting AS (
    SELECT
        ms.job_id,
        ms.company,
        ms.post_date,
        ms.salary,
        ms.city,
        ti.title,
        tm.remove_date
    FROM master AS ms
    LEFT JOIN title AS ti
        ON ms.job_id = ti.job_id
    LEFT JOIN timelog AS tm
        ON ms.job_id = tm.job_id
);
CREATE INDEX job_id_on_posting ON posting (job_id);
