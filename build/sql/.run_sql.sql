-- Function: email_ca_update_error(error_str text)

--DROP FUNCTION email_ca_update_error(error_str text);

CREATE OR REPLACE FUNCTION email_ca_update_error(error_str text)
  RETURNS RECORD  AS
$BODY$
	WITH 
		templ AS (
		SELECT t.template AS v,t.mes_subject AS s
		FROM email_templates t
		WHERE t.email_type='ca_update_error'
		)	
	SELECT
		sms_templates_text(
			ARRAY[
				ROW('error',$1)::template_value
			],
			(SELECT v FROM templ)
		)
		AS mes_body,		
		u.email::text AS email,
		(SELECT s FROM templ) AS mes_subject,
		''::text AS firm,
		u.name::text AS client
	FROM users u
	WHERE u.role_id='admin' AND u.email IS NOT NULL;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_ca_update_error(error_str text) OWNER TO expert72;
