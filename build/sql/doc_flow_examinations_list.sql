-- VIEW: doc_flow_examinations_list

--DROP VIEW doc_flow_examinations_list;

CREATE OR REPLACE VIEW doc_flow_examinations_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		doc_flow_in_ref(doc_flow_in) subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		CASE
			WHEN (t.recipient->>'dataType')::data_types='departments'::data_types THEN departments_ref(departments)
			WHEN (t.recipient->>'dataType')::data_types='employees'::data_types THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id,
		
		t.application_resolution_state
		
	FROM doc_flow_examinations AS t
	LEFT JOIN doc_flow_in ON doc_flow_in.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_in'
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	LEFT JOIN departments ON departments.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='employees'
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_examinations_list OWNER TO ;
