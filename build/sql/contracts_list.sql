-- VIEW: contracts_list

--DROP VIEW contracts_list;

CREATE OR REPLACE VIEW contracts_list AS
	SELECT
		t.id,
		t.date_time,
		t.application_id,
		applications_ref(applications) AS applications_ref,
		
		t.client_id,
		clients.name AS client_descr,
		--clients_ref(clients) AS clients_ref,
		coalesce(t.constr_name,applications.constr_name) AS constr_name,
		
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
		
		t.main_expert_id,
		t.main_department_id,
		m_exp.name AS main_expert_descr,
		--employees_ref(m_exp) AS main_experts_ref,
		
		t.contract_number,
		t.contract_date,
		t.expertise_result_number,
		
		t.comment_text,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_date,
		
		t.for_all_employees,
		CASE
			WHEN (coalesce(pm.cnt,0)=0) THEN 'no_pay'
			WHEN st.state='returned' OR st.state='closed_no_expertise' THEN 'returned'
			WHEN t.expertise_result IS NULL AND t.expertise_result_date<=now()::date THEN 'no_result'
			ELSE NULL
		END AS state_for_color,
		
		applications.exp_cost_eval_validity,
		
		t.permission_ar AS condition_ar
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=t.application_id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	LEFT JOIN (
		SELECT
			client_payments.contract_id,
			count(*) AS cnt
		FROM client_payments
		GROUP BY client_payments.contract_id
	) AS pm ON pm.contract_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW contracts_list OWNER TO ;
