-- Function: contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool);

-- с 19/08/20 функция имеет 3 параметра, + in_ext_contract bool
CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)
  RETURNS text AS
$$
	SELECT
		CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END||
		--'\D+.*$'
		coalesce(max(regexp_replace(ct.contract_number,'[^0-9]+','','g')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
		AND (
			(in_ext_contract=FALSE AND coalesce(app.ext_contract,FALSE)=FALSE)
			OR (in_ext_contract AND coalesce(app.ext_contract,FALSE))
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool) OWNER TO ;
