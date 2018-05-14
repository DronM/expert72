-- Function: contracts_descr1c(contracts)

-- DROP FUNCTION contracts_descr1c(contracts);

CREATE OR REPLACE FUNCTION contracts_descr1c(contracts)
  RETURNS text AS
$$
	SELECT 'Контракт №'||$1.expertise_result_number||' от '||to_char($1.date_time,'DD/MM/YYYY');
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_descr1c(contracts) OWNER TO ;

