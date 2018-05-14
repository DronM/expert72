-- VIEW: report_template_files_dialog

DROP VIEW report_template_files_dialog;

CREATE OR REPLACE VIEW report_template_files_dialog AS
	SELECT
		ft.id,
		report_templates_ref(t) AS report_templates_ref,
		t.fields,
		t.in_params,
		ft.comment_text,		
		ft.file_inf,
		employees_ref(emp) AS employees_ref,
		ft.permissions,
		ft.for_all_views,
		ft.views
	FROM report_template_files AS ft
	LEFT JOIN report_templates AS t ON t.id=ft.report_template_id
	LEFT JOIN employees AS emp ON emp.id=ft.employee_id
	;
	
ALTER VIEW report_template_files_dialog OWNER TO ;
