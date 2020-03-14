-- VIEW: doc_flow_examinations_dialog

--DROP VIEW doc_flow_examinations_dialog;

CREATE OR REPLACE VIEW doc_flow_examinations_dialog AS
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
		
		t.description,
		
		t.resolution,
		t.close_date_time,
		t.closed,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		t.application_resolution_state,
		doc_flow_in.from_client_app AS application_based,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain,
		
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		applications_ref(applications) AS applications_ref,
		
		applications.service_type AS application_service_type
		
		
	FROM doc_flow_examinations AS t
	LEFT JOIN doc_flow_in ON doc_flow_in.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_in'
	LEFT JOIN applications ON applications.id = doc_flow_in.from_application_id
	LEFT JOIN doc_flow_out ON doc_flow_out.doc_flow_in_id = doc_flow_in.id
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	LEFT JOIN departments ON departments.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	
	;
	
ALTER VIEW doc_flow_examinations_dialog OWNER TO ;
