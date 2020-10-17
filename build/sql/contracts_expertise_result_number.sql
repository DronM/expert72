-- Function: contracts_expertise_result_number(in_contract_number text,in_contract_date date)

-- DROP FUNCTION contracts_expertise_result_number(in_contract_number text,in_contract_date date);

CREATE OR REPLACE FUNCTION contracts_expertise_result_number(in_contract_number text,in_contract_date date)
  RETURNS text AS
$$
	WITH contr_num AS (
		SELECT regexp_replace(in_contract_number,'[^0-9]+','','g') AS v
	)
	SELECT
		substr('0000',1,4-length( (SELECT v FROM contr_num) ))||
		(SELECT v FROM contr_num)||
		'/'||
		(extract(year FROM in_contract_date)-2000)::text
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_expertise_result_number(in_contract_number text,in_contract_date date) OWNER TO ;
