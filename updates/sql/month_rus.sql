-- Function: format_date_rus(date,short_year bool)

-- DROP FUNCTION format_date_rus(date,short_year bool);

CREATE OR REPLACE FUNCTION format_date_rus(date,short_year bool)
  RETURNS text AS
$BODY$
	SELECT
		date_part('day',$1)
		||' '||CASE
			WHEN date_part('month',$1)=1 THEN 'Января'
			WHEN date_part('month',$1)=2 THEN 'Февраля'
			WHEN date_part('month',$1)=3 THEN 'Марта'
			WHEN date_part('month',$1)=4 THEN 'Апреля'
			WHEN date_part('month',$1)=5 THEN 'Мая'
			WHEN date_part('month',$1)=6 THEN 'Июня'
			WHEN date_part('month',$1)=7 THEN 'Июля'
			WHEN date_part('month',$1)=8 THEN 'Августа'
			WHEN date_part('month',$1)=9 THEN 'Сентября'
			WHEN date_part('month',$1)=10 THEN 'Октября'
			WHEN date_part('month',$1)=11 THEN 'Ноября'
			WHEN date_part('month',$1)=12 THEN 'Декабря'
		END
		||' '|| CASE short_year WHEN TRUE THEN date_part('year',$1)-2000 ELSE date_part('year',$1) END;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION format_date_rus(date,short_year bool) OWNER TO ;


