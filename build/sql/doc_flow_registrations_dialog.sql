-- VIEW: doc_flow_registrations_dialog

DROP VIEW doc_flow_registrations_dialog;

CREATE OR REPLACE VIEW doc_flow_registrations_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.subject_doc AS subject_docs_ref,
		
		employees_ref(employees) AS employees_ref,
		
		t.comment_text
		
	FROM doc_flow_registrations AS t
	LEFT JOIN employees ON employees.id=t.employee_id
	;
	
ALTER VIEW doc_flow_registrations_dialog OWNER TO ;
