-- master
DROP TABLE IF EXISTS "master";
CREATE TABLE "master" (
    job_id text,
    company text,
    post_date timestamp,
    salary bigint,
    city text
);
CREATE INDEX job_id_on_master ON "master" (job_id);

-- title
DROP TABLE IF EXISTS title;
CREATE TABLE title (
    job_id text,
    title text
);
CREATE INDEX job_id_on_title ON title (job_id);

-- timelog
DROP TABLE IF EXISTS timelog;
CREATE TABLE timelog (
    job_id text,
    remove_date timestamp
);
CREATE INDEX job_id_on_timelog ON timelog (job_id);
