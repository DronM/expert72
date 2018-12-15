-- Function: reminders_process()

-- DROP FUNCTION reminders_process();

CREATE OR REPLACE FUNCTION reminders_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN
		
		INSERT INTO mail_for_sending
		(to_addr,to_name,body,subject,email_type)
		(WITH 
			templ AS (
				SELECT
					t.template AS v,
					t.mes_subject AS s
				FROM email_templates t
				WHERE t.email_type= 'new_remind'::email_types
			)
		SELECT
			users.email::text,
			employees.name::text,
			sms_templates_text(
				ARRAY[
					ROW('content', NEW.content)::template_value,
					ROW('id',NEW.id)::template_value
				],
				(SELECT v FROM templ)
			) AS mes_body,		
			(SELECT s FROM templ),
			'new_remind'::email_types
		FROM employees
		LEFT JOIN users ON users.id=employees.user_id
		WHERE
			employees.id=NEW.recipient_employee_id
			AND users.email IS NOT NULL
			AND users.reminders_to_email
			AND users.email_confirmed					
		);				
		
			
		RETURN NEW;

	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION reminders_process() OWNER TO ;
