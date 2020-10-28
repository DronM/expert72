-- VIEW: doc_flow_approvements_ext_list

--DROP VIEW doc_flow_approvements_ext_list;

CREATE OR REPLACE VIEW doc_flow_approvements_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		
		CASE
			WHEN t.subject_doc->>'dataType'='doc_flow_out' THEN doc_flow_out_ref(doc_flow_out)
			WHEN t.subject_doc->>'dataType'='doc_flow_inside' THEN doc_flow_inside_ref(doc_flow_inside)
			ELSE NULL
		END
		AS subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		(SELECT
			string_agg(person_init(list.e,FALSE),', ')
		FROM (
			SELECT
				jsonb_array_elements(t.recipient_list->'rows')->'fields'->'employee'->>'descr' AS e
			) AS list			
		) AS recipient_list,
		
		t.step_count,
		t.current_step,
		
		t.close_result,
		
		ARRAY(
			SELECT
			(jsonb_array_elements(t1.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int
			FROM doc_flow_approvements AS t1 WHERE t1.id=t.id
		) AS recipient_employee_id_list,
		
		t.employee_id,
		
		st.state AS contract_state
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	LEFT JOIN doc_flow_inside ON doc_flow_inside.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_inside'
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN applications ON applications.id=contracts.application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=applications.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	--NOT EXT
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_ext_list OWNER TO ;
