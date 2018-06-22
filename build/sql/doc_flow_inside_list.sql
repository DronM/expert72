-- VIEW: doc_flow_inside_list

DROP VIEW doc_flow_inside_list;

CREATE OR REPLACE VIEW doc_flow_inside_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		t.doc_flow_importance_type_id AS doc_flow_importance_type,
		contracts_ref(ct) AS contracts_ref,
		t.contract_id AS contract_id,
		employees_ref(emp) AS employees_ref,
		t.employee_id AS employee_id,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc
		
		
	FROM doc_flow_inside AS t
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=t.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=t.contract_id
	LEFT JOIN employees AS emp ON emp.id=t.employee_id
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=t.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_inside_list OWNER TO ;
