-- VIEW: employee_expert_certificate_list

--DROP VIEW employee_expert_certificate_list;

CREATE OR REPLACE VIEW employee_expert_certificate_list AS
	SELECT
		emp.id 
		,emp.name
		,(SELECT
			json_agg(sub.cert_list)
		FROM
			(SELECT
				json_build_object(
					'date_from',certs.date_from,
					'date_to',certs.date_to,
					'is_valid',(certs.date_to>=now()::date),
					'expert_types_ref',conclusion_dictionary_detail_ref(dict),
					'cert_id',certs.cert_id
				) AS cert_list
			FROM employee_expert_certificates AS certs
			LEFT JOIN conclusion_dictionary_detail AS dict ON dict.conclusion_dictionary_name='tExpertType' AND dict.code=certs.expert_type
			WHERE certs.employee_id = emp.id
			ORDER BY certs.date_to DESC
			) AS sub
		) AS cert_list
		
	FROM employees AS emp
	ORDER BY name
	;
	
ALTER VIEW employee_expert_certificate_list OWNER TO ;
