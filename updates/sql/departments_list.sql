-- VIEW: departments_list

--DROP VIEW {{DB_SCHEMA}}.departments_list;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.departments_list AS
	SELECT
		t.*
	FROM {{DB_SCHEMA}}.departments AS t
	ORDER BY
		t.name
	;
	
ALTER VIEW departments_list OWNER TO {{DB_USER}};
