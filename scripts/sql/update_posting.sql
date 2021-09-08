UPDATE posting_current AS t1
SET
    t1.job_id = t2.job_id,
    t1.company = t2.company,
    t1.post_date = t2.post_date,
    t1.salary = t2.salary,
    t1.city = t2.city,
    t1.title = t2.title,
    t1.remove_date = t2.remove_date
FROM posting_20210601 AS t2
WHERE t1.job_id = t2.job_id;
