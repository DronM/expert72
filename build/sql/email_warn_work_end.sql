-- Function: email_warn_work_end(warn_period_days int)

-- DROP FUNCTION email_warn_work_end(warn_period_days int);

CREATE OR REPLACE FUNCTION email_warn_work_end(warn_period_days int)
  RETURNS void AS
$$
	INSERT INTO mail_for_sending
		(from_addr,from_name,
		to_addr,to_name,
		reply_addr,reply_name,
		sender_addr,subject,body,email_type)
	(
	WITH 
		templ AS (
			SELECT t.template AS v,t.mes_subject AS s
			FROM email_templates t
			WHERE t.email_type='warn_work_end'
		),
		outmail_data AS (
			SELECT
				t->>'from_addr' AS from_addr,
				t->>'from_name' AS from_name	
			FROM const_outmail_data_val() AS t
		)
	SELECT
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		u.email,
		u.name_full,
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT s FROM templ),
		
		sms_templates_text(
			ARRAY[
				ROW('end_date',to_char(contr.work_end_date,'DD/MM/YYYY'))::template_value,
				ROW('contract_number',contr.contract_number::text)::template_value,
				ROW('contract_date',to_char(contr.contract_date,'DD/MM/YYYY'))::template_value,
				ROW('user_name',u.name_full::text)::template_value,
				ROW('applicant',app.applicant->>'name')::template_value,
				ROW('constr_name',coalesce(contr.constr_name,app.constr_name)::text)::template_value
			],
			(SELECT v FROM templ)
		),
		'warn_work_end'::email_types
	FROM contracts contr
	LEFT JOIN applications AS app ON app.id=contr.application_id
	LEFT JOIN users AS u ON u.id=app.user_id
	WHERE contr.work_end_date=(SELECT d2::date FROM applications_check_period(app.office_id,now(),$1) AS (d1 timestampTZ,d2 timestampTZ))
		AND u.email_confirmed
	);

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_warn_work_end(warn_period_days int) OWNER TO ;
