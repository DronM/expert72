-- Function: bank_day_next(date,int)

-- DROP FUNCTION bank_day_next(date);

CREATE OR REPLACE FUNCTION bank_day_next(date, int)
  RETURNS date AS
$BODY$
	SELECT
		d::date
	FROM generate_series(
		CASE
			WHEN $2<0 THEN $1-'1 month'::interval
			ELSE $1
		END,
	
		CASE
			WHEN $2>0 THEN $1+'1 month'::interval
			ELSE $1
		END,
		'1 day'::interval
	) AS d
	WHERE
		extract(dow from d::date)>0 AND extract(dow from d::date)<6
		AND d::date NOT IN (SELECT h.date FROM holidays h)
	ORDER BY
		CASE WHEN $2<0 THEN d END DESC,
		CASE WHEN $2>0 THEN d END ASC
	OFFSET abs($2) LIMIT 1
	;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION bank_day_next(date,int) OWNER TO ;

