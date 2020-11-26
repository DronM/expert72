-- Function: applications_work_h(in_date_time timestampTZ,in_office_id int)

-- DROP FUNCTION applications_work_h(in_date_time timestampTZ,in_office_id int);

CREATE OR REPLACE FUNCTION applications_work_h(in_date_time timestampTZ,in_office_id int)
  RETURNS bool AS
$$
	WITH
	in_t AS (SELECT in_date_time AS v)
	SELECT
		coalesce(
			(SELECT v FROM in_t)::time BETWEEN (sub.hours->>'from')::time AND (sub.hours->>'to')::time
		,FALSE)  AS work_h
	FROM (
	SELECT jsonb_array_elements(offices.work_hours) AS hours
	FROM offices WHERE id=in_office_id
		) AS sub
	LEFT JOIN holidays AS h ON h.date=(SELECT v FROM in_t)::date
	WHERE (sub.hours->>'checked')::bool
	AND (sub.hours->>'dow')::int=(SELECT EXTRACT(DOW FROM (SELECT v FROM in_t)))
	AND h.date is NULL
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_work_h(in_date_time timestampTZ,in_office_id int) OWNER TO ;


