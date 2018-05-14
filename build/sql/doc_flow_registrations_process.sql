-- Function: doc_flow_registrations_process()

-- DROP FUNCTION doc_flow_registrations_process();

CREATE OR REPLACE FUNCTION doc_flow_registrations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_out_id int;
	v_to_application_id int;
	v_user_id int;
	v_subject text;
	v_doc_flow_in_client int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		v_doc_flow_out_id = (NEW.subject_doc->'keys'->>'id')::int;
	
		--статус
		INSERT INTO doc_flow_out_processes (
			doc_flow_out_id, date_time,
			state,
			register_doc,
			doc_flow_importance_type_id,
			description,
			end_date_time
		)
		VALUES (
			v_doc_flow_out_id,NEW.date_time,
			'registered'::doc_flow_out_states,
			doc_flow_registrations_ref(NEW),
			NULL,
			'Зарегистрирован исходящий документ',
			NULL
		);	
		
						
		IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
			--Установка подписанта исходящего документа
			UPDATE
				doc_flow_out
			SET
				signed_by_employee_id = NEW.employee_id
			WHERE id=v_doc_flow_out_id;
			
			
			--если основание - заявление/контракт = ответное письмо клиенту
			INSERT INTO doc_flow_in_client (
				date_time,
				reg_number,
				application_id,
				user_id,
				subject,
				content,
				files
			)		
			SELECT
				NEW.date_time,
				t.reg_number,
				t.to_application_id,
				ap.user_id,
				--t.to_contract_id
				t.subject,
				t.content,
				(SELECT
					jsonb_agg(
						json_build_object(
							'file_id',at.file_id,
							'file_name',at.file_name,
							'file_size',at.file_size,
							'file_signed',at.file_signed,
							'file_uploaded',true,
							'deleted',false
						)
						)
				FROM doc_flow_attachments AS at WHERE at.doc_type='doc_flow_out' AND at.doc_id=t.id
				)				
			FROM doc_flow_out t
			LEFT JOIN applications ap ON ap.id=t.to_application_id
			WHERE t.id=v_doc_flow_out_id AND t.to_application_id IS NOT NULL
			RETURNING id,application_id,user_id,subject
			INTO v_doc_flow_in_client,v_to_application_id,v_user_id,v_subject
			;
			
			--Если нужно - письмо клиенту со ссылкой на вход.документ
			IF v_doc_flow_in_client IS NOT NULL THEN
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
							ROW('subject', v_subject)::template_value,
							ROW('id',v_doc_flow_in_client)::template_value
						],
						(SELECT v FROM templ)
					) AS mes_body,		
					(SELECT s FROM templ),
					'out_mail_to_app'::email_types
				FROM users
				WHERE
					users.id=v_user_id
					AND users.email IS NOT NULL
					AND users.reminders_to_email
					--AND users.email_confirmed					
				);				
			END IF;			
		END IF;		
		
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--статус
		DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_registrations'
			AND (register_doc->'keys'->>'id')::int=OLD.id;
											
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_registrations_process() OWNER TO ;
