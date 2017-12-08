-- VIEW: departments_dialog

--DROP VIEW {{DB_SCHEMA}}.departments_dialog;

CREATE OR REPLACE VIEW {{DB_SCHEMA}}.departments_dialog AS
	SELECT
		t.*
	FROM {{DB_SCHEMA}}.departments AS t
	;
	
ALTER VIEW departments_dialog OWNER TO {{DB_USER}};
