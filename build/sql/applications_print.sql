-- VIEW: applications_print

--DROP VIEW applications_print;

CREATE OR REPLACE VIEW applications_print AS
	SELECT
		d.id,
		d.user_id,
		format_date_rus(d.create_dt::DATE,FALSE) AS date_descr,
		d.expertise_type,
		d.cost_eval_validity,
		d.cost_eval_validity_simult,
		
		fund_sources.name AS fund_sources_descr,
		d.fund_percent,
		
		--applicant
		d.applicant AS applicant,
		banks_format((d.applicant->>'bank')::jsonb) AS applicant_bank,
		kladr_parse_addr((d.applicant->>'post_address')::jsonb) AS applicant_post_address,
		kladr_parse_addr((d.applicant->>'legal_address')::jsonb) AS applicant_legal_address,
		
		--customer
		d.customer AS customer,
		banks_format((d.customer->>'bank')::jsonb) AS customer_bank,
		kladr_parse_addr((d.customer->>'post_address')::jsonb) AS customer_post_address,
		kladr_parse_addr((d.customer->>'legal_address')::jsonb) AS customer_legal_address,
		
		--contractors
		array_to_json((SELECT ARRAY(SELECT app_contractors_parse(d.contractors)))) AS contractors,
				
		d.constr_name,
		kladr_parse_addr(d.constr_address) AS constr_address,
		d.constr_technical_features,
		construction_types.name AS construction_types_descr,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		
		clients.name_full AS office_client_name_full,
		contacts_get_persons(clients.id,'clients') AS office_responsable_persons,
		
		d.pd_usage_info,
		--developer
		d.developer AS developer,
		banks_format((d.developer->>'bank')::jsonb) AS developer_bank,
		kladr_parse_addr((d.developer->>'post_address')::jsonb) AS developer_post_address,
		kladr_parse_addr((d.developer->>'legal_address')::jsonb) AS developer_legal_address,
		
		d.auth_letter,
		d.exp_cost_eval_validity,
		d.cost_eval_validity_app_id
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN clients ON clients.id=offices.client_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	;
	
ALTER VIEW applications_print OWNER TO ;

