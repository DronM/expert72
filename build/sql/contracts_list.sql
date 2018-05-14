-- VIEW: contracts_list

DROP VIEW contracts_list;

CREATE OR REPLACE VIEW contracts_list AS
	SELECT
		t.id,
		t.date_time,
		t.application_id,
		applications_ref(applications) AS applications_ref,
		
		t.client_id,
		clients.name AS client_descr,
		--clients_ref(clients) AS clients_ref,
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,

		t.employee_id,
		employees_ref(employees) AS employees_ref,
		
		t.reg_number,
		t.expertise_type,
		t.document_type,
		
		contracts_ref(t) AS self_ref,
		
		t.permission_ar,
		t.main_expert_id,
		m_exp.name AS main_expert_descr,
		--employees_ref(m_exp) AS main_experts_ref,
		
		t.contract_number,
		t.contract_date,
		t.expertise_result_number,
		
		t.comment_text
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_list OWNER TO ;
