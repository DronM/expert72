-- VIEW: report_template_files_list

DROP VIEW report_template_files_list;

CREATE OR REPLACE VIEW report_template_files_list AS
	SELECT
		tf.id,
		tf.file_inf->>'name' AS file_name,
		t.name AS report_templates_name,
		employees_ref(emp) AS employees_ref,
		tf.employee_id,
		tf.permission_ar
		
	FROM report_template_files AS tf
	LEFT JOIN report_templates AS t ON t.id=tf.report_template_id
	LEFT JOIN employees AS emp ON emp.id=tf.employee_id
	ORDER BY t.name
	;
	
ALTER VIEW report_template_files_list OWNER TO ;
