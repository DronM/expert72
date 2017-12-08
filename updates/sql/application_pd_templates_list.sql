-- VIEW: application_pd_templates_list

--DROP VIEW application_pd_templates_list;

CREATE OR REPLACE VIEW application_pd_templates_list AS
	SELECT
		id,
		comment_text,
		date_time
	FROM application_pd_templates
	ORDER BY date_time DESC
	;
	
ALTER VIEW application_pd_templates_list OWNER TO ;
