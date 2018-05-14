-- VIEW: report_templates_dialog

--DROP VIEW report_templates_dialog;

CREATE OR REPLACE VIEW report_templates_dialog AS
	SELECT
		id,
		name,
		comment_text,
		fields,
		db_entity,
		in_params
	FROM report_templates
	;
	
ALTER VIEW report_templates_dialog OWNER TO ;
