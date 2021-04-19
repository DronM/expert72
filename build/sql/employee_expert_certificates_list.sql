-- VIEW: employee_expert_certificates_list

--DROP VIEW employee_expert_certificates_list;

CREATE OR REPLACE VIEW employee_expert_certificates_list AS
	SELECT
		cert.id
		,employees_ref(emp) AS employees_ref
		,conclusion_dictionary_detail_ref(dict) AS expert_types_ref
		,cert.cert_id
		,cert.date_from
		,cert.date_to
		,(cert.date_to >= now()::date) cert_not_expired
		,cert.employee_id AS employee_id
		
	FROM employee_expert_certificates AS cert
	LEFT JOIN employees AS emp ON emp.id = cert.employee_id
	LEFT JOIN conclusion_dictionary_detail AS dict ON cert.expert_type = dict.code AND dict.conclusion_dictionary_name='tExpertType'
	ORDER BY emp.name,cert.date_to DESC
	;
	
ALTER VIEW employee_expert_certificates_list OWNER TO ;
