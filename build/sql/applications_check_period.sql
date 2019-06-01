-- Function: applications_check_period(in_office_id int,in_date_time timestampTZ, in_days int)

-- DROP FUNCTION applications_check_period(in_office_id int,in_date_time timestampTZ,in_days int);

CREATE OR REPLACE FUNCTION applications_check_period(in_office_id int,in_date_time timestampTZ,in_days int)
  RETURNS record AS
$$
	WITH
		w_hours AS (
			WITH
				week_sched AS (
					SELECT jsonb_array_elements(offices.work_hours) AS hours
					FROM offices
					WHERE id=in_office_id
				)
			SELECT
				d::date,
				(dow_sched.hours->>'from')::time AS h_from,
				(dow_sched.hours->>'to')::time AS h_to				
			FROM generate_series(
				in_date_time::date,
				in_date_time::date+(greatest(in_days*5,30)||' days')::interval,
				'1 day'::interval
			) AS d
			LEFT JOIN office_day_schedules AS off_sched ON off_sched.office_id=in_office_id AND off_sched.day=d::date
			LEFT JOIN holidays AS hol ON hol.date=d::date
			LEFT JOIN week_sched AS dow_sched ON (dow_sched.hours->>'dow')::int=EXTRACT(DOW FROM d)
			WHERE
				(hol.date IS NULL
				AND (dow_sched.hours->>'checked')::bool
				)
				OR off_sched.work_hours IS NOT NULL
			ORDER BY d::date
		),
		period AS (	
			SELECT d,h_from,h_to FROM w_hours OFFSET
						(CASE WHEN (SELECT EXTRACT(hour FROM h_to) FROM w_hours OFFSET 0 LIMIT 1)<=EXTRACT(hour FROM now()) THEN
							1
						ELSE
							0
						END)
					LIMIT in_days
		)
	SELECT	
		(SELECT
			CASE
				WHEN d=in_date_time::date THEN in_date_time
				ELSE (d+h_from)::timestampTZ
			END
		FROM period OFFSET 0 LIMIT 1
		) AS d_from,
		
		(SELECT
			(d+h_to)::timestampTZ
		FROM period OFFSET in_days-1 LIMIT 1
		) AS d_to
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_check_period(in_office_id int,in_date_time timestampTZ,days int) OWNER TO ;
