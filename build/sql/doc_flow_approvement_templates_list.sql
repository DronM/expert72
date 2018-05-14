-- VIEW: doc_flow_approvement_templates_list

--DROP VIEW doc_flow_approvement_templates_list;

CREATE OR REPLACE VIEW doc_flow_approvement_templates_list AS
	SELECT
		t.id,
		t.name,
		employees_ref(employees) AS employees_ref,
		t.permission_ar,
		t.for_all_employees,
		t.employee_id
		
	FROM doc_flow_approvement_templates AS t
	LEFT JOIN employees ON employees.id = t.employee_id
	;
	
ALTER VIEW doc_flow_approvement_templates_list OWNER TO ;
