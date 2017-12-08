-- VIEW: employees_dialog

--DROP VIEW {{DB_SCHEMA}}.employees_dialog;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.employees_dialog AS
	SELECT
		t.*
		,{{DB_SCHEMA}}.users_ref(users_join) AS users_ref
		,{{DB_SCHEMA}}.departments_ref(departments_join) AS departments_ref
	FROM {{DB_SCHEMA}}.employees AS t
	LEFT JOIN {{DB_SCHEMA}}.users AS users_join ON
		t.user_id=users_join.id
	LEFT JOIN {{DB_SCHEMA}}.departments AS departments_join ON
		t.department_id=departments_join.id
		
	ORDER BY
		t.id
	;
	
ALTER VIEW employees_dialog OWNER TO {{DB_USER}};
