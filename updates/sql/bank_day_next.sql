-- Function: bank_day_next(date,int)

-- DROP FUNCTION bank_day_next(date);

CREATE OR REPLACE FUNCTION bank_day_next(date, int)
  RETURNS date AS
$BODY$
	SELECT
		dates.d
	FROM (
		SELECT d::date AS d
		FROM generate_series($1+'1 day'::interval,$1+($2||' days')::interval+'1 month'::interval,'1 day'::interval) AS d
		WHERE
			extract(dow from d::date)>0 AND extract(dow from d::date)<6
			AND d::date NOT IN (SELECT h.date FROM holidays h)
		LIMIT $2+1
	) AS dates
	ORDER BY dates.d DESC LIMIT 1
	;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION bank_day_next(date,int) OWNER TO ;

