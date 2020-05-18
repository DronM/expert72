-- Function: contracts_next_number(in_service_type service_types,in_date date)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date);

CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date)
  RETURNS text AS
$$
	SELECT
		coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date) OWNER TO ;
