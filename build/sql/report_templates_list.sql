-- VIEW: report_templates_list

--DROP VIEW report_templates_list;

CREATE OR REPLACE VIEW report_templates_list AS
	SELECT
		id,name 
	FROM report_templates
	ORDER BY name
	;
	
ALTER VIEW report_templates_list OWNER TO ;
