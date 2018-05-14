-- VIEW: departments_list

DROP VIEW {{DB_SCHEMA}}.departments_list;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.departments_list AS
	SELECT
		t.*,
		employees_ref(emp) AS boss_employees_ref
	FROM {{DB_SCHEMA}}.departments AS t
	LEFT JOIN {{DB_SCHEMA}}.employees AS emp ON emp.id=t.boss_employee_id
	ORDER BY
		t.name
	;
	
ALTER VIEW departments_list OWNER TO {{DB_USER}};
