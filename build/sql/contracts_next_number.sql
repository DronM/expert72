-- Function: contracts_next_number(in_document_type document_types,in_date date)

-- DROP FUNCTION contracts_next_number(in_document_type document_types,in_date date);

CREATE OR REPLACE FUNCTION contracts_next_number(in_document_type document_types,in_date date)
  RETURNS text AS
$$
	SELECT
		coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1||
		(SELECT
				coalesce(services.contract_postf,'')
			FROM services
			WHERE services.id=
			((
				CASE
					WHEN in_document_type='pd' THEN pdfn_services_expertise()
					WHEN in_document_type='cost_eval_validity' THEN pdfn_services_eng_survey()
					WHEN in_document_type='modification' THEN pdfn_services_modification()
					WHEN in_document_type='audit' THEN pdfn_services_audit()
					ELSE NULL
				END
			)->'keys'->>'id')::int
		)
	FROM contracts AS ct
	WHERE
		ct.document_type=in_document_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_document_type document_types,in_date date) OWNER TO ;
