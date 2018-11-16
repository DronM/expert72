-- Function: doc_flow_in_client_process()

-- DROP FUNCTION doc_flow_in_client_process();

CREATE OR REPLACE FUNCTION doc_flow_in_client_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN
			--Если это достоверность одновременно с ПД - сделать не одновременно
			--это при возврате заявления без рассмотрения
			UPDATE applications AS app
			SET cost_eval_validity_simult = FALSE
			FROM (
				SELECT t.id
				FROM applications t
				WHERE t.id=NEW.application_id
				AND coalesce(t.cost_eval_validity,FALSE) AND coalesce(t.cost_eval_validity_simult,FALSE)
				AND NEW.doc_flow_type_id=(pdfn_doc_flow_types_app_resp_return()->'keys'->>'id')::int
			) AS base
			WHERE app.id=base.id;
		END IF;
		
		RETURN NEW;
				
	ELSIF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--письмо клиенту со ссылкой на вход.документ
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'out_mail_to_app'::email_types
				)
			SELECT
				users.email,
				coalesce(users.name_full,users.name),
				sms_templates_text(
					ARRAY[
						ROW('subject', NEW.subject)::template_value,
						ROW('id',NEW.id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'out_mail_to_app'::email_types
			FROM users
			WHERE
				users.id=NEW.user_id
				AND users.email IS NOT NULL
				AND users.reminders_to_email
				--AND users.email_confirmed					
			);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN
			DELETE FROM doc_flow_in_client_reg_numbers WHERE doc_flow_in_client_id=OLD.id;
		END IF;
		RETURN OLD;
		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_client_process() OWNER TO ;

