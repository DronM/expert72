-- VIEW: doc_flow_approvements_dialog

--DROP VIEW doc_flow_approvements_dialog;

CREATE OR REPLACE VIEW doc_flow_approvements_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		doc_flow_out_ref(doc_flow_out) subject_docs_ref,
		
		t.description,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		t.recipient_list AS recipient_list_ref,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		t.close_result,
		
		t.doc_flow_approvement_type,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		t.step_count,
		t.current_step
		
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	
	;
	
ALTER VIEW doc_flow_approvements_dialog OWNER TO ;
