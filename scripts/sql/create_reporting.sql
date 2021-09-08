DROP TABLE IF EXISTS reporting;
CREATE TABLE reporting AS (
	SELECT
		"new".month,
		"new".count_new,
		"new".salary_new,
		active.count_active,
		active.salary_active,
		removed.count_removed,
		removed.salary_removed
	FROM (
		SELECT
			to_char(post_date, 'YYYY-MM') AS "month",
			count(*) AS count_new,
			round(avg(salary)) AS salary_new 
		FROM posting
		GROUP BY "month"
	) AS "new"
	LEFT JOIN (
		SELECT 
			staging.month AS "month",
			sum(staging.staging_count) OVER (
				ORDER BY "month" ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) AS count_active,
			round(avg(staging.staging_salary) OVER (
				ORDER BY "month" ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			)) AS salary_active
		FROM (
			SELECT
				to_char(post_date, 'YYYY-MM') AS "month",
				count(1) AS staging_count,
				round(avg(salary)) AS staging_salary
			FROM posting
			GROUP BY 1
		) AS staging
	) AS active
		ON "new".month = active.month
	LEFT JOIN (
		SELECT
			to_char(post_date, 'YYYY-MM') AS "month",
			count(*) AS count_removed,
			round(avg(salary)) AS salary_removed
		FROM posting
		WHERE remove_date IS NOT NULL
		GROUP BY "month"
	) AS removed
		ON "new".month = removed.month
	ORDER BY "month" ASC
);
