-- VIEW: doc_flow_registrations_list

--DROP VIEW doc_flow_registrations_list;

CREATE OR REPLACE VIEW doc_flow_registrations_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject_doc AS subject_docs_ref,
		employees_ref(employees) AS employees_ref,
		t.employee_id
		
	FROM doc_flow_registrations AS t
	LEFT JOIN employees ON employees.id=t.employee_id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_registrations_list OWNER TO ;
