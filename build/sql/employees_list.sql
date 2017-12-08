-- VIEW: employees_list

--DROP VIEW {{DB_SCHEMA}}.employees_list;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.employees_list AS
	SELECT
		t.*
		,{{DB_SCHEMA}}.departments_ref(departments_join) AS departments_ref
	FROM {{DB_SCHEMA}}.employees AS t
	LEFT JOIN {{DB_SCHEMA}}.departments AS departments_join ON
		t.department_id=departments_join.id
	ORDER BY
		t.name
	;
	
ALTER VIEW employees_list OWNER TO {{DB_USER}};
