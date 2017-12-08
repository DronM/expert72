-- Function: banks_format(jsonb)

-- DROP FUNCTION banks_format(jsonb);

CREATE OR REPLACE FUNCTION banks_format(jsonb)
  RETURNS text AS
$$
	SELECT
		'Сч.№ '||acc_number||
		', БИК '||b_bik||
		', '||b_name||
		', к/сч.№ '||b_korshet
	FROM banks_parse($1)
		AS (acc_number varchar(20),b_bik varchar(9),b_name text,b_korshet varchar(9),b_address text,b_gor text)
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION banks_format(jsonb) OWNER TO ;
