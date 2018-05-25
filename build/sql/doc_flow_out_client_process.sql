-- Function: doc_flow_out_client_process()

-- DROP FUNCTION doc_flow_out_client_process();

CREATE OR REPLACE FUNCTION doc_flow_out_client_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_email_type email_types;
	v_doc_flow_in_id int;
	v_applicant json;
	v_constr_name text;
	v_office_id int;
	v_from_date_time timestampTZ;
	v_end_date_time timestampTZ;
	v_recipient jsonb;
	v_contract_id int;
	v_main_department_id int;
	v_main_expert_id int;
	v_reg_number text;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--application head
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			WHERE app.id = NEW.application_id;
			
			--RAISE EXCEPTION 'v_contract_id=%',v_contract_id;
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			
			--Входящее письмо НАШЕ отделу приема
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id, doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app				
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id, pdfn_doc_flow_types_app(),
				v_end_date_time,
				NEW.subject,
				NEW.content,
				departments_ref((SELECT departments FROM departments WHERE id=(SELECT const_app_recipient_department_val()->'keys'->>'id')::int)),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			
			--Рег номер наш - клиенту
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			
--RAISE EXCEPTION 'v_main_expert_id=%',v_main_expert_id;			
			IF v_contract_id IS NULL THEN
				--НЕТ контракта - Передача на рассмотрение в отдел приема
				INSERT INTO doc_flow_examinations (
					date_time,
					subject,
					description,
					doc_flow_importance_type_id,
					end_date_time,
					employee_id,
					subject_doc,
					recipient
				)
				VALUES (
					v_from_date_time+'1 second'::interval,
					NEW.subject,
					NEW.content,
					(pdfn_doc_flow_importance_types_common()->'keys'->>'id')::int,
					v_end_date_time,
					(SELECT
						employees.id
					FROM employees
					WHERE 
						department_id = (const_app_recipient_department_val()->'keys'->>'id')::int
						AND post_id=(pdfn_posts_dep_boss()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder boss о новых заявлениях
				INSERT INTO reminders
				(register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					employees.id,
					NEW.subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))
				FROM employees
				WHERE
					--employees.department_id=(SELECT const_app_recipient_department_val()->'keys'->>'id')::int
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF v_main_expert_id IS NOT NULL THEN
				--ЕСТь Контракт - Передача на рассмотрение в основной отдел контракта
				/*
				INSERT INTO doc_flow_examinations (
					date_time,
					subject,
					description,
					doc_flow_importance_type_id,
					end_date_time,
					employee_id,
					subject_doc,
					recipient
				)
				VALUES (
					v_from_date_time,
					NEW.subject,
					NEW.content,
					(pdfn_doc_flow_importance_types_common()->'keys'->>'id')::int,
					v_end_date_time,
					v_main_expert_id,
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					departments_ref( (SELECT departments FROM departments WHERE id=v_main_department_id) )
				);
				*/
				--сообщение главному эксперту
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				VALUES(
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					v_main_expert_id,
					NEW.subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
				);
			END IF;
						
			--email to admin(ВСЕГДА!!!) && boss(ТОЛЬКО НОВЫЕ)
			IF v_contract_id IS NOT NULL THEN
				v_email_type = 'app_change';
			ELSE
				v_email_type = 'new_app';
			END IF;
			
			
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
				SELECT t.template AS v,t.mes_subject AS s
				FROM email_templates t
				WHERE t.email_type=v_email_type
				)
			SELECT
			users.email,
			employees.name,
			sms_templates_text(
				ARRAY[
					ROW('applicant', (v_applicant->>'name')::text)::template_value,
					ROW('constr_name',v_constr_name)::template_value,
					ROW('id',NEW.application_id)::template_value
				],
				(SELECT v FROM templ)
			) AS mes_body,		
			NEW.subject||' от ' || (v_applicant->>'name')::text,
			v_email_type
			FROM employees
			LEFT JOIN users ON users.id=employees.user_id
			WHERE
				(
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin' OR (role_id='boss' AND v_email_type = 'new_app'))
				)
				AND users.email IS NOT NULL
				--AND users.email_confirmed					
			);				
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO ;

