-- Function: application_corrections_process()

-- DROP FUNCTION application_corrections_process();

CREATE OR REPLACE FUNCTION application_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--письмо заявителю
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'app_to_correction'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('app_number', app.id)::template_value,
						ROW('app_date',to_char(app.create_dt,'DD/MM/YY'))::template_value,
						ROW('end_date',to_char(NEW.end_date_time,'DD/MM/YY'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'app_to_correction'::email_types
			FROM applications AS app
			LEFT JOIN users ON users.id=app.user_id
			WHERE app.id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
	
		IF const_client_lk_val() OR const_debug_val() THEN
			--client server, update application state
			INSERT INTO public.application_processes(
				    application_id, date_time, state, user_id, end_date_time, doc_flow_examination_id)
			    VALUES (
			    NEW.application_id,
			    NEW.date_time,
			    'correcting'::application_states,
			    NEW.user_id,
			    NEW.end_date_time,
			    NEW.doc_flow_examination_id
			    );			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_corrections_process() OWNER TO ;

