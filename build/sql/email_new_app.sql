-- Function: email_new_app(app_id int,to_email text,to_name text)

--DROP FUNCTION email_new_app(app_id int,to_email text,to_name text);

CREATE OR REPLACE FUNCTION email_new_app(app_id int,to_email text,to_name text)
  RETURNS RECORD  AS
$BODY$
	WITH 
		templ AS (
		SELECT t.template AS v,t.mes_subject AS s
		FROM email_templates t
		WHERE t.email_type='new_app'
		)	
	SELECT
		sms_templates_text(
			ARRAY[
				ROW('applicant',(app.applicant->>'name')::text)::template_value,
				ROW('constr_name',app.constr_name::text)::template_value,
				ROW('id',app.id)::template_value
			],
			(SELECT v FROM templ)
		) AS mes_body,		
		$2 AS email,
		(SELECT s FROM templ) AS mes_subject,
		''::text AS firm,
		$3 AS client
	FROM applications app
	WHERE app.id=$1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_new_app(app_id int,to_email text,to_name text) OWNER TO ;
