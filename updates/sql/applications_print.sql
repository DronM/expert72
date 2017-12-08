-- VIEW: applications_print

DROP VIEW applications_print;

CREATE OR REPLACE VIEW applications_print AS
	SELECT
		d.id,
		d.user_id,
		format_date_rus(d.create_dt::DATE,FALSE) AS date_descr,
		d.expertise_type,
		enum_estim_cost_types_val(d.estim_cost_type,'ru'::locales) AS estim_cost_type,
		enum_fund_sources_val(d.fund_source,'ru'::locales) AS fund_source,
		
		d.applicant AS applicant,
		banks_format((d.applicant->>'bank')::jsonb) AS applicant_bank,
		kladr_parse_addr((d.applicant->>'post_address')::jsonb) AS applicant_post_address,
		kladr_parse_addr((d.applicant->>'legal_address')::jsonb) AS applicant_legal_address,
		
		d.customer AS customer,
		banks_format((d.customer->>'bank')::jsonb) AS customer_bank,
		kladr_parse_addr((d.customer->>'post_address')::jsonb) AS customer_post_address,
		kladr_parse_addr((d.customer->>'legal_address')::jsonb) AS customer_legal_address,
		
		array_to_json((SELECT ARRAY(SELECT app_contractors_parse(d.contractors)))) AS contractors,
		--d.contractors,
				
		d.constr_name,
		kladr_parse_addr(d.constr_address) AS constr_address,
		d.constr_technical_features,
		enum_construction_types_val(d.constr_construction_type,'ru'::locales) AS constr_construction_type,
		d.constr_total_est_cost,
		clients.name_full AS office_client_name_full,
		clients.responsable_persons AS office_responsable_persons
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN clients ON clients.id=offices.client_id
	;
	
ALTER VIEW applications_print OWNER TO ;

