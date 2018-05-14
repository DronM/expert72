-- View: email_templates_list

--DROP VIEW email_templates_list;

CREATE OR REPLACE VIEW email_templates_list AS 
	SELECT
		st.id,
		st.email_type,
		st.template
	FROM email_templates AS st;

ALTER TABLE email_templates_list OWNER TO ;

