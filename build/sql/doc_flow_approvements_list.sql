-- VIEW: doc_flow_approvements_list

--DROP VIEW doc_flow_approvements_list;

CREATE OR REPLACE VIEW doc_flow_approvements_list AS
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
		
		t.close_result
		
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	LEFT JOIN doc_flow_inside ON doc_flow_inside.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_inside'
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_list OWNER TO ;
