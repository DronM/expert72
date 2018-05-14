-- ******************* update 12/05/2018 06:23:06 ******************
ALTER TABLE contracts ADD COLUMN invoice_number text,ADD COLUMN invoice_date date;

-- ******************* update 12/05/2018 07:21:36 ******************
	DROP INDEX IF EXISTS contracts_contract_ext_id_idx;
	CREATE INDEX contracts_contract_ext_id_idx ON contracts(contract_ext_id);




-- ******************* update 14/05/2018 10:55:02 ******************
ALTER TABLE contracts ADD COLUMN akt_total  numeric(15,2) DEFAULT 0;

-- ******************* update 14/05/2018 16:08:50 ******************
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


-- ******************* update 14/05/2018 16:09:32 ******************
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

