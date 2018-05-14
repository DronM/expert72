-- Function: bank_day_diff(date, date)

-- DROP FUNCTION bank_day_diff(date, date);

CREATE OR REPLACE FUNCTION bank_day_diff(date,date)
  RETURNS interval AS
$BODY$
	SELECT (count(*)::int||' days')::interval
	FROM generate_series($1,$2,'1 day'::interval) AS d
	WHERE
		extract(dow from d::date)>0 AND extract(dow from d::date)<6
		AND d::date NOT IN (SELECT h.date FROM holidays h)
	;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION bank_day_diff(date, date) OWNER TO expert72;

