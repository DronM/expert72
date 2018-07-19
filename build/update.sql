
-- ******************* update 18/07/2018 13:54:08 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	SELECT
		'с '||
		CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
		||' по '||
		CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:01:32 ******************
CREATE OR REPLACE FUNCTION last_month_day(date)
  RETURNS date AS
$BODY$
  SELECT (date_trunc('MONTH', $1) + INTERVAL '1 MONTH - 1 day')::date;
$BODY$
  LANGUAGE sql IMMUTABLE STRICT
  COST 100;
  
  ALTER FUNCTION last_month_day(date) OWNER TO expert72;

-- ******************* update 18/07/2018 14:02:44 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	SELECT
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN
			'January'
		--Default
		ELSE
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:12:27 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	SELECT
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN
			--Same month, same year
			CASE WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||to_char(in_date_to,'TMMonth')||to_char(in_date_to,'YYYY')||'г.'
			ELSE
				'not_done'
		--Default
		ELSE
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:12:47 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	SELECT
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN
			--Same month, same year
			CASE WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||to_char(in_date_to,'TMMonth')||to_char(in_date_to,'YYYY')||'г.'
			ELSE
				'not_done'
			END
		--Default
		ELSE
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:13:04 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	SELECT
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN
			--Same month, same year
			CASE WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||to_char(in_date_to,'TMMonth')||' '||to_char(in_date_to,'YYYY')||'г.'
			ELSE
				'not_done'
			END
		--Default
		ELSE
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:14:26 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	SELECT
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN
			--Same month, same year
			CASE WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'
			ELSE
				'not_done'
			END
		--Default
		ELSE
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:16:42 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	WITH
	def_format AS (
		SELECT
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		AS per	
	)
	SELECT
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN
			--Same month, same year
			CASE WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'
			ELSE
				(SELECT per FROM def_format)
			END
		--Default
		ELSE
			(SELECT per FROM def_format)
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:18:52 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	WITH
	def_format AS (
		SELECT
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		AS per	
	)
	SELECT
		--Same month, same year
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN			
			CASE
				--1 month
				WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'

				--first quarter
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=3 THEN
				'за 1 квартал '||to_char(in_date_to,'YYYY')||'г.'
				
				ELSE
				(SELECT per FROM def_format)
			END
		--Default
		ELSE
			(SELECT per FROM def_format)
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:22:29 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	WITH
	def_format AS (
		SELECT
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		AS per	
	)
	SELECT
		--Same month, same year
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN			
			CASE
				--1 month
				WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'

				--first quarter
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=3 THEN
				'за 1 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--second quarter
				WHEN
				extract(month FROM in_date_from)=4 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за 2 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--third quarter
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 3 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--forth quarter
				WHEN
				extract(month FROM in_date_from)=10 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за 4 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--6 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за первое полугодие '||to_char(in_date_to,'YYYY')||'г.'

				--9 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 9 месяцев '||to_char(in_date_to,'YYYY')||'г.'
				
				--second half
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за второе полугодие '||to_char(in_date_to,'YYYY')||'г.'
				
				--year
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за '||to_char(in_date_to,'YYYY')||' год'
				
				ELSE
				(SELECT per FROM def_format)
			END
		--Default
		ELSE
			(SELECT per FROM def_format)
		END
	;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:24:37 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	WITH
	def_format AS (
		SELECT
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		AS per	
	)
	SELECT
		--Same month, same year
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN			
			CASE
				--1 month
				WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'

				--first quarter
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=3 THEN
				'за 1 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--second quarter
				WHEN
				extract(month FROM in_date_from)=4 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за 2 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--third quarter
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 3 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--forth quarter
				WHEN
				extract(month FROM in_date_from)=10 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за 4 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--6 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за первое полугодие '||to_char(in_date_to,'YYYY')||'г.'

				--9 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 9 месяцев '||to_char(in_date_to,'YYYY')||'г.'
				
				--second half
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за второе полугодие '||to_char(in_date_to,'YYYY')||'г.'
				
				--year
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за '||to_char(in_date_to,'YYYY')||' год'
				
				ELSE
				(SELECT per FROM def_format)
			END
		--Default
		ELSE
			(SELECT per FROM def_format)
		END
	;
$$
  LANGUAGE sql IMMUTABLE STRICT CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:24:47 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	WITH
	def_format AS (
		SELECT
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		AS per	
	)
	SELECT
		--Same month, same year
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN			
			CASE
				--1 month
				WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'

				--first quarter
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=3 THEN
				'за 1 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--second quarter
				WHEN
				extract(month FROM in_date_from)=4 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за 2 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--third quarter
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 3 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--forth quarter
				WHEN
				extract(month FROM in_date_from)=10 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за 4 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--6 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за первое полугодие '||to_char(in_date_to,'YYYY')||'г.'

				--9 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 9 месяцев '||to_char(in_date_to,'YYYY')||'г.'
				
				--second half
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за второе полугодие '||to_char(in_date_to,'YYYY')||'г.'
				
				--year
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за '||to_char(in_date_to,'YYYY')||' год'
				
				ELSE
				(SELECT per FROM def_format)
			END
		--Default
		ELSE
			(SELECT per FROM def_format)
		END
	;
$$
  LANGUAGE sql IMMUTABLE CALLED ON NULL INPUT STRICT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 14:24:53 ******************
﻿-- Function: format_period_rus(in_date_from date, in_date_to date, in_date_format text)

-- DROP FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text);

CREATE OR REPLACE FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text)
  RETURNS text AS
$$
	WITH
	def_format AS (
		SELECT
			'с '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_from,'DD/MM/YY') ELSE to_char(in_date_from,in_date_format) END
			||' по '||
			CASE WHEN in_date_format IS NULL THEN to_char(in_date_to,'DD/MM/YY') ELSE to_char(in_date_to,in_date_format) END
		AS per	
	)
	SELECT
		--Same month, same year
		CASE WHEN extract(day FROM in_date_from)=1 AND last_month_day(in_date_to)=in_date_to THEN			
			CASE
				--1 month
				WHEN
				extract(month FROM in_date_from)=extract(month FROM in_date_to) AND extract(year FROM in_date_from)=extract(year FROM in_date_to) THEN
				'за '||lower(to_char(in_date_to,'TMMonth'))||' '||to_char(in_date_to,'YYYY')||'г.'

				--first quarter
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=3 THEN
				'за 1 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--second quarter
				WHEN
				extract(month FROM in_date_from)=4 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за 2 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--third quarter
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 3 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--forth quarter
				WHEN
				extract(month FROM in_date_from)=10 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за 4 квартал '||to_char(in_date_to,'YYYY')||'г.'

				--6 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=6 THEN
				'за первое полугодие '||to_char(in_date_to,'YYYY')||'г.'

				--9 months
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=9 THEN
				'за 9 месяцев '||to_char(in_date_to,'YYYY')||'г.'
				
				--second half
				WHEN
				extract(month FROM in_date_from)=7 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за второе полугодие '||to_char(in_date_to,'YYYY')||'г.'
				
				--year
				WHEN
				extract(month FROM in_date_from)=1 AND extract(year FROM in_date_from)=extract(year FROM in_date_to)
				AND extract(month FROM in_date_to)=12 THEN
				'за '||to_char(in_date_to,'YYYY')||' год'
				
				ELSE
				(SELECT per FROM def_format)
			END
		--Default
		ELSE
			(SELECT per FROM def_format)
		END
	;
$$
  LANGUAGE sql IMMUTABLE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION format_period_rus(in_date_from date, in_date_to date, in_date_format text) OWNER TO expert72;

-- ******************* update 18/07/2018 18:01:51 ******************
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30000',
		'Contract_Controller',
		NULL,
		'RepReestrExpertise',
		'Отчеты',
		'Реестр заключений по гос.экспертизе',
		FALSE
		);
	

-- ******************* update 18/07/2018 18:04:38 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30001',
		'Contract_Controller',
		NULL,
		'RepReestrCostEval',
		'Отчеты',
		'Реестр заключений по достоверности',
		FALSE
		);
	
