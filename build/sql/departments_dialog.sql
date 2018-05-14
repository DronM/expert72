-- VIEW: departments_dialog

--DROP VIEW {{DB_SCHEMA}}.departments_dialog;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.departments_dialog AS
	SELECT
		t.*,
		employees_ref(emp) AS boss_employees_ref
	FROM {{DB_SCHEMA}}.departments AS t
	LEFT JOIN {{DB_SCHEMA}}.employees AS emp ON emp.id=t.boss_employee_id
	;
	
ALTER VIEW departments_dialog OWNER TO {{DB_USER}};
