-- VIEW: doc_flow_approvement_templates_dialog

DROP VIEW doc_flow_approvement_templates_dialog;

CREATE OR REPLACE VIEW doc_flow_approvement_templates_dialog AS
	SELECT
		t.id,
		t.name,
		employees_ref(employees) AS employees_ref,
		t.permissions,				
		t.permission_ar,
		t.for_all_employees,
		t.comment_text,
		t.recipient_list AS recipient_list_ref,
		t.doc_flow_approvement_type
		
	FROM doc_flow_approvement_templates AS t
	LEFT JOIN employees ON employees.id = t.employee_id
	;
	
ALTER VIEW doc_flow_approvement_templates_dialog OWNER TO ;
