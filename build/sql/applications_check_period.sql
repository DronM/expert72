-- Function: applications_check_period(in_office_id int,days int)

-- DROP FUNCTION applications_check_period(in_office_id int,days int);

CREATE OR REPLACE FUNCTION applications_check_period(in_office_id int,days int)
  RETURNS record AS
$$
	WITH
		w_hours AS (
			WITH
				week_sched AS (SELECT jsonb_array_elements(offices.work_hours) AS hours FROM offices)
			SELECT
				d::date,
				((SELECT
					CASE WHEN off_sched.work_hours IS NOT NULL THEN
						off_sched.work_hours
					ELSE
						(SELECT week_sched.hours FROM week_sched OFFSET (CASE WHEN EXTRACT(DOW FROM d)-1<0 THEN 6 ELSE EXTRACT(DOW FROM d)-1 END ) LIMIT 1)
					END
				)->>'from')::time AS h_from,
				((SELECT
					CASE WHEN off_sched.work_hours IS NOT NULL THEN
						off_sched.work_hours
					ELSE
						(SELECT week_sched.hours FROM week_sched OFFSET (CASE WHEN EXTRACT(DOW FROM d)-1<0 THEN 6 ELSE EXTRACT(DOW FROM d)-1 END ) LIMIT 1)
					END
				)->>'to')::time AS h_to
			FROM generate_series(now()::date,now()::date+'30 days'::interval,'1 day'::interval) AS d
			LEFT JOIN office_day_schedules AS off_sched ON off_sched.office_id=in_office_id AND off_sched.day=d::date
			LEFT JOIN holidays AS hol ON hol.date=d::date
			WHERE
				(hol.date IS NULL
				AND ((SELECT week_sched.hours FROM week_sched OFFSET (CASE WHEN EXTRACT(DOW FROM d)-1<0 THEN 6 ELSE EXTRACT(DOW FROM d)-1 END ) LIMIT 1)->>'checked')::bool
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
					LIMIT days
		)
	SELECT	
		(SELECT
			CASE
				WHEN d=now()::date THEN now()
				ELSE (d+h_from)::timestampTZ
			END
		FROM period OFFSET 0 LIMIT 1
		) AS d_from,
		
		(SELECT
			(d+h_to)::timestampTZ
		FROM period OFFSET days-1 LIMIT 1
		) AS d_to
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_check_period(in_office_id int,days int) OWNER TO ;
