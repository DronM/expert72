
-- ******************* update 05/07/2018 06:37:43 ******************
﻿-- Function: contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int)

-- DROP FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int);

CREATE OR REPLACE FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int)
  RETURNS date AS
$$
	SELECT
		CASE
			WHEN in_date_type='bank'::date_types THEN
				(SELECT d2::date FROM applications_check_period(in_office_id,in_date_time,in_days+1) AS (d1 timestampTZ,d2 timestampTZ))
			ELSE (SELECT d2::date FROM applications_check_period(in_office_id,in_date_time::date+((in_days-1)||' days')::interval,1) AS (d1 timestampTZ,d2 timestampTZ))
		END	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int) OWNER TO expert72;

-- ******************* update 05/07/2018 06:37:50 ******************
﻿-- Function: contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int)

-- DROP FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int);

CREATE OR REPLACE FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int)
  RETURNS date AS
$$
	SELECT
		CASE
			WHEN in_date_type='bank'::date_types THEN
				(SELECT d2::date FROM applications_check_period(in_office_id,in_date_time,in_days) AS (d1 timestampTZ,d2 timestampTZ))
			ELSE (SELECT d2::date FROM applications_check_period(in_office_id,in_date_time::date+((in_days-1)||' days')::interval,1) AS (d1 timestampTZ,d2 timestampTZ))
		END	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int) OWNER TO expert72;
