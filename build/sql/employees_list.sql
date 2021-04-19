-- VIEW: employees_list

--DROP VIEW {{DB_SCHEMA}}.employees_list;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.employees_list AS
	SELECT
		t.*
		,{{DB_SCHEMA}}.departments_ref(departments_join) AS departments_ref
		,{{DB_SCHEMA}}.posts_ref(posts_join) AS posts_ref
	FROM {{DB_SCHEMA}}.employees AS t
	LEFT JOIN {{DB_SCHEMA}}.departments AS departments_join ON
		t.department_id=departments_join.id
	LEFT JOIN {{DB_SCHEMA}}.posts AS posts_join ON
		t.post_id=posts_join.id
		
	ORDER BY
		t.name
	;
	
ALTER VIEW employees_list OWNER TO {{DB_USER}};
