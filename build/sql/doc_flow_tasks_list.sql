-- VIEW: doc_flow_tasks_list

--DROP VIEW doc_flow_tasks_list;

CREATE OR REPLACE VIEW doc_flow_tasks_list AS
	SELECT
		t.id,
		
		t.recipient As recipients_ref,
		
		t.register_doc AS register_docs_ref,
		
		t.end_date_time,
		t.date_time,
		
		doc_flow_importance_types_ref(imp) AS doc_flow_importance_types_ref,
		t.doc_flow_importance_type_id,
		
		t.description,
		
		t.closed,
		t.close_date_time,		
		t.close_doc AS close_docs_ref,
		
		t.employee_id,
		employees_ref(empl) AS employees_ref,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id
		
		
	FROM doc_flow_tasks t
	LEFT JOIN doc_flow_importance_types AS imp ON imp.id=t.doc_flow_importance_type_id
	LEFT JOIN employees AS empl ON empl.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_tasks_list OWNER TO ;
