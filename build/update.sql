
-- ******************* update 07/10/2018 07:46:07 ******************

		ALTER TABLE file_verifications ADD COLUMN user_id int REFERENCES users(id);


-- ******************* update 07/10/2018 07:49:48 ******************

		ALTER TABLE doc_flow_attachments ADD COLUMN employee_id int REFERENCES employees(id);


-- ******************* update 09/10/2018 10:57:40 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				
				IF v_application_state='waiting_for_contract' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						NEW.date_time,
						'waiting_for_pay'::application_states,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 10/10/2018 10:33:48 ******************

					ALTER TYPE application_states ADD VALUE 'archive';
	/* function */
	CREATE OR REPLACE FUNCTION enum_application_states_val(application_states,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='filling'::application_states AND $2='ru'::locales THEN 'Заполнение анкеты'
		WHEN $1='correcting'::application_states AND $2='ru'::locales THEN 'Исправление анкеты'
		WHEN $1='sent'::application_states AND $2='ru'::locales THEN 'Анкета отправлена на проверку'
		WHEN $1='checking'::application_states AND $2='ru'::locales THEN 'Проверка анкеты'
		WHEN $1='returned'::application_states AND $2='ru'::locales THEN 'Возврат без рассмотрения'
		WHEN $1='closed_no_expertise'::application_states AND $2='ru'::locales THEN 'Возврат без экспертизы'
		WHEN $1='waiting_for_contract'::application_states AND $2='ru'::locales THEN 'Контракт по заявлению'
		WHEN $1='waiting_for_pay'::application_states AND $2='ru'::locales THEN 'Ожидание оплаты'
		WHEN $1='expertise'::application_states AND $2='ru'::locales THEN 'Экспертиза проекта'
		WHEN $1='closed'::application_states AND $2='ru'::locales THEN 'Выдано заключение'
		WHEN $1='archive'::application_states AND $2='ru'::locales THEN 'В архиве'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_application_states_val(application_states,locales) OWNER TO expert72;		
		
-- ******************* update 10/10/2018 10:53:55 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						NEW.date_time,
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 10/10/2018 11:25:29 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				raise 'v_application_state=%',v_application_state;
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						NEW.date_time,
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 10/10/2018 11:27:05 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				RAISE EXCEPTION 'v_application_state=%',v_application_state;
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						NEW.date_time,
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 10/10/2018 11:32:08 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						NEW.date_time,
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 10/10/2018 11:35:12 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						NEW.date_time,
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 10/10/2018 11:59:57 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		/*
		(SELECT json_agg(doc_files.attachments)
		FROM (

			WITH file_q AS (
			SELECT
				t.file_path,
				json_agg(
					json_build_object(
						'file_id',t.file_id,
						'file_name',t.file_name,
						'file_size',t.file_size,
						'file_signed',t.file_signed,
						'file_uploaded','true',
						'file_path',t.file_path,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END
					)
				) AS attachments			
			FROM doc_flow_attachments AS t
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
			LEFT JOIN (
				SELECT
					f_sig.file_id,
					jsonb_agg(
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str,
							'employee_id',u_certs.employee_id,
							'verif_date_time',ver.date_time
						)
					) As signatures
				FROM file_signatures AS f_sig
				LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
				LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
				GROUP BY f_sig.file_id,f_sig.sign_date_time
				ORDER BY f_sig.sign_date_time
				--ТАКАЯ СОРТИРОВКА ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ У УДАЛЕНИЕМ!!!
			) AS sign ON sign.file_id=t.file_id			
			WHERE t.doc_type='doc_flow_out'::data_types AND t.doc_id=doc_flow_out.id
			GROUP BY t.file_path
			)

			SELECT
				json_build_object(
					'fields',json_build_object(
						'id',fld.id,
						'descr',fld.name,
						'required',false,
						'require_client_sig',fld.require_client_sig
					),
					'files',coalesce((SELECT file_q.attachments
						FROM file_q
						WHERE file_q.file_path=fld.name),
						'[]'::json)
				) AS attachments
			FROM application_doc_folders AS fld
			ORDER BY fld.name
			) AS doc_files
		) AS files,
		*/
		folders.files AS files,
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,att.file_path,app_fd.id
		ORDER BY app_fd.id)  AS doc_att	
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 10/10/2018 12:51:42 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		/*
		(SELECT json_agg(doc_files.attachments)
		FROM (

			WITH file_q AS (
			SELECT
				t.file_path,
				json_agg(
					json_build_object(
						'file_id',t.file_id,
						'file_name',t.file_name,
						'file_size',t.file_size,
						'file_signed',t.file_signed,
						'file_uploaded','true',
						'file_path',t.file_path,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END
					)
				) AS attachments			
			FROM doc_flow_attachments AS t
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
			LEFT JOIN (
				SELECT
					f_sig.file_id,
					jsonb_agg(
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str,
							'employee_id',u_certs.employee_id,
							'verif_date_time',ver.date_time
						)
					) As signatures
				FROM file_signatures AS f_sig
				LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
				LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
				GROUP BY f_sig.file_id,f_sig.sign_date_time
				ORDER BY f_sig.sign_date_time
				--ТАКАЯ СОРТИРОВКА ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ У УДАЛЕНИЕМ!!!
			) AS sign ON sign.file_id=t.file_id			
			WHERE t.doc_type='doc_flow_out'::data_types AND t.doc_id=doc_flow_out.id
			GROUP BY t.file_path
			)

			SELECT
				json_build_object(
					'fields',json_build_object(
						'id',fld.id,
						'descr',fld.name,
						'required',false,
						'require_client_sig',fld.require_client_sig
					),
					'files',coalesce((SELECT file_q.attachments
						FROM file_q
						WHERE file_q.file_path=fld.name),
						'[]'::json)
				) AS attachments
			FROM application_doc_folders AS fld
			ORDER BY fld.name
			) AS doc_files
		) AS files,
		*/
		folders.files AS files,
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',all_folders.id,'descr',all_folders.name),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM application_doc_folders AS all_folders
		LEFT JOIN 
		(SELECT
			att.doc_id,
			--att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id
		--att.file_path, ORDER BY app_fd.id
		)  AS doc_att
		ON all_folders.id=doc_att.folder_id
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 10/10/2018 13:02:03 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		/*
		(SELECT json_agg(doc_files.attachments)
		FROM (

			WITH file_q AS (
			SELECT
				t.file_path,
				json_agg(
					json_build_object(
						'file_id',t.file_id,
						'file_name',t.file_name,
						'file_size',t.file_size,
						'file_signed',t.file_signed,
						'file_uploaded','true',
						'file_path',t.file_path,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END
					)
				) AS attachments			
			FROM doc_flow_attachments AS t
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
			LEFT JOIN (
				SELECT
					f_sig.file_id,
					jsonb_agg(
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str,
							'employee_id',u_certs.employee_id,
							'verif_date_time',ver.date_time
						)
					) As signatures
				FROM file_signatures AS f_sig
				LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
				LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
				GROUP BY f_sig.file_id,f_sig.sign_date_time
				ORDER BY f_sig.sign_date_time
				--ТАКАЯ СОРТИРОВКА ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ У УДАЛЕНИЕМ!!!
			) AS sign ON sign.file_id=t.file_id			
			WHERE t.doc_type='doc_flow_out'::data_types AND t.doc_id=doc_flow_out.id
			GROUP BY t.file_path
			)

			SELECT
				json_build_object(
					'fields',json_build_object(
						'id',fld.id,
						'descr',fld.name,
						'required',false,
						'require_client_sig',fld.require_client_sig
					),
					'files',coalesce((SELECT file_q.attachments
						FROM file_q
						WHERE file_q.file_path=fld.name),
						'[]'::json)
				) AS attachments
			FROM application_doc_folders AS fld
			ORDER BY fld.name
			) AS doc_files
		) AS files,
		*/
		folders.files AS files,
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 10/10/2018 13:02:06 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		/*
		(SELECT json_agg(doc_files.attachments)
		FROM (

			WITH file_q AS (
			SELECT
				t.file_path,
				json_agg(
					json_build_object(
						'file_id',t.file_id,
						'file_name',t.file_name,
						'file_size',t.file_size,
						'file_signed',t.file_signed,
						'file_uploaded','true',
						'file_path',t.file_path,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END
					)
				) AS attachments			
			FROM doc_flow_attachments AS t
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
			LEFT JOIN (
				SELECT
					f_sig.file_id,
					jsonb_agg(
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str,
							'employee_id',u_certs.employee_id,
							'verif_date_time',ver.date_time
						)
					) As signatures
				FROM file_signatures AS f_sig
				LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
				LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
				GROUP BY f_sig.file_id,f_sig.sign_date_time
				ORDER BY f_sig.sign_date_time
				--ТАКАЯ СОРТИРОВКА ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ У УДАЛЕНИЕМ!!!
			) AS sign ON sign.file_id=t.file_id			
			WHERE t.doc_type='doc_flow_out'::data_types AND t.doc_id=doc_flow_out.id
			GROUP BY t.file_path
			)

			SELECT
				json_build_object(
					'fields',json_build_object(
						'id',fld.id,
						'descr',fld.name,
						'required',false,
						'require_client_sig',fld.require_client_sig
					),
					'files',coalesce((SELECT file_q.attachments
						FROM file_q
						WHERE file_q.file_path=fld.name),
						'[]'::json)
				) AS attachments
			FROM application_doc_folders AS fld
			ORDER BY fld.name
			) AS doc_files
		) AS files,
		*/
		folders.files AS files,
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 10/10/2018 13:02:43 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		folders.files AS files,
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 05:58:05 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 11/10/2018 06:20:52 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 11/10/2018 10:06:15 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON att.file_path=app_fd.name
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:07:00 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON att.file_path=app_fd.name
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:08:28 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON att.file_path=app_fd.name
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:08:45 ******************
-- VIEW: doc_flow_out_dialog

DROP VIEW doc_flow_out_dialog;


-- ******************* update 11/10/2018 10:08:56 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON att.file_path=app_fd.name
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:11:09 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:12:38 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:15:43 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			CASE WHEN att.file_id IS NULL THEN NULL
			ELSE
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) END AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:17:54 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:18:31 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:18:54 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:19:49 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:20:55 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr
					),
					'parent_id',NULL,
					'files',NULL--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:24:58 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',NULL--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:25:37 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',doc_att.files--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',FALSE,
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:28:36 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',doc_att.files--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:29:59 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',doc_att.files--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:34:42 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'cnt',json_array_length(doc_att.files),
					'files',doc_att.files--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:35:22 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'cnt',doc_att.files->(0),
					'files',doc_att.files--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:36:05 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:36:28 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',doc_att.files->(0),
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:38:08 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:39:39 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',CASE WHEN doc_att.files->(0)='null' THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:39:55 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',CASE WHEN doc_att.files->(0)::text='null' THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:40:34 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',CASE WHEN doc_att.files->(0)->file_id IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:40:43 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:41:06 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',doc_att.files->(0)->'file_id',--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:41:22 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',doc_att.files->(0)->>'file_id',--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:41:40 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',doc_att.files->(0)->'file_id' IS NULL,--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:42:04 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',(doc_att.files->(0)->>'file_id'='null'),--CASE WHEN doc_att.files->(0)->'file_id' IS NULL THEN NULL ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:43:12 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',CASE WHEN doc_att.files->(0) IS NULL THEN 'NoVal' ELSE 'SomeVal' END,
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:43:59 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',doc_att.files->(0),
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:44:28 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',(doc_att.files->(0) IS NULL),
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:45:15 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',(doc_att.files->(0)->'file_id' IS NULL),
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:46:17 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'test',((doc_att.files->(0)->'file_id')::text ='null'),
					'files',CASE WHEN doc_att.files->(0) IS NULL THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:46:41 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN NULL ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:48:34 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN '[]'::json ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				/*CASE WHEN att.file_id IS NULL THEN NULL
				ELSE
				*/	json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',f_ver.date_time,
						'signatures',--sign.signatures
						CASE
							WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
								jsonb_build_array(
									jsonb_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE sign.signatures
						END,
						'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
						'require_client_sig',app_fd.require_client_sig
					)
				--END
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:48:58 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		--folders.files AS files,
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN '[]'::json ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:49:26 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		/**
		 * !!!Нужны ВСЕ папки всегда!!!
		 */
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN '[]'::json ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	/*
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	*/
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:49:37 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		/**
		 * !!!Нужны ВСЕ папки всегда!!!
		 */
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN '[]'::json ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.id
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 11/10/2018 10:52:35 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		/**
		 * !!!Нужны ВСЕ папки всегда!!!
		 */
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN '[]'::json ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.name
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 10:59:56 ******************

					ALTER TYPE doc_flow_out_client_types ADD VALUE 'app_contr_revoke';
	/* function */
	CREATE OR REPLACE FUNCTION enum_doc_flow_out_client_types_val(doc_flow_out_client_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='app'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Заявление'
		WHEN $1='contr_resp'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Ответы на замечания по контракту'
		WHEN $1='contr_return'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Возврат подписанных документов'
		WHEN $1='contr_other'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Прочее'
		WHEN $1='date_prolongate'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Продление срока'
		WHEN $1='app_contr_revoke'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Отзыв заявления/контракта'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_doc_flow_out_client_types_val(doc_flow_out_client_types,locales) OWNER TO expert72;		
		
-- ******************* update 12/10/2018 11:40:47 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		jsonb_build_array(
			jsonb_build_object(
				'files',att.attachments
			)
		)
		AS attachment_files,
		
		jsonb_build_array(
			jsonb_build_object(
				'files',
				CASE
				WHEN t.sent THEN
					att_only_sigs.attachments
				ELSE
					CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
					ELSE '[]'::jsonb
					END
					||
					CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
					ELSE '[]'::jsonb
					END
				END
			)
		)
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 11:41:05 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		jsonb_build_array(
			jsonb_build_object(
				'files',att.attachments
			)
		)
		AS attachment_files,
		
		jsonb_build_array(
			jsonb_build_object(
				'files',
				CASE
				WHEN t.sent THEN
					att_only_sigs.attachments
				ELSE
					CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
					ELSE '[]'::jsonb
					END
					||
					CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
					ELSE '[]'::jsonb
					END
				END
			)
		)
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 13:31:00 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
					END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 15:24:49 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 12/10/2018 15:34:35 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 12/10/2018 15:39:42 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
					END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 15:42:58 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
					END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:10:16 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						ELSE WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						/*
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						*/
					END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:10:27 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						/*
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						*/
					END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:13:36 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				jsonb_agg(t.attachments)
			)
		END AS attachment_files
	FROM (

		SELECT
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,				
				'file_signed_by_client',app_f.file_signed_by_client,
				'signatures',sign.signatures				
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:15:35 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				jsonb_agg(t.attachments)
			)
		END AS attachment_files
	FROM (

		SELECT
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,				
				'file_signed_by_client',app_f.file_signed_by_client,
				'signatures',sign.signatures				
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:15:46 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		jsonb_build_object(
			'files',
			jsonb_agg(t.attachments)
		)
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',
				jsonb_agg(		
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,				
					'file_signed_by_client',app_f.file_signed_by_client,
					'signatures',sign.signatures				
				)
				)
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:15:59 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		jsonb_build_object(
			'files',
			jsonb_agg(t.attachments)
		)
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',
				jsonb_agg(		
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,				
					'file_signed_by_client',app_f.file_signed_by_client,
					'signatures',sign.signatures				
				)
				)
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:16:54 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		jsonb_build_object(
			'files',
			jsonb_agg(t.attachments)
		)
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',
				jsonb_agg(		
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,				
					'file_signed_by_client',app_f.file_signed_by_client,
					'signatures',sign.signatures				
				)
				)
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:18:01 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		jsonb_build_object(
			'files',
			jsonb_agg(t.attachments)
		)
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',
				jsonb_agg(		
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,				
					'file_signed_by_client',app_f.file_signed_by_client,
					'signatures',sign.signatures				
				)
				)
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:19:54 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
		SELECT
			jsonb_agg(		
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,				
					'file_signed_by_client',app_f.file_signed_by_client,
					'signatures',sign.signatures				
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:20:02 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
		SELECT
			jsonb_agg(		
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,				
					'file_signed_by_client',app_f.file_signed_by_client,
					'signatures',sign.signatures				
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:24:10 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',
		
				jsonb_agg(		
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,				
						'file_signed_by_client',app_f.file_signed_by_client,
						'signatures',sign.signatures				
					)
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:29:49 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments||doc_flow_out_client_files_for_signing(t.application_id)
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:30:50 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments||doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:31:26 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments--||doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:33:02 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments->'files'||doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:33:21 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments->'files'--||doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:33:31 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments--||doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:33:58 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:34:27 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
					att_only_sigs.attachments||doc_flow_out_client_files_for_signing(t.application_id)->'files'
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:35:13 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						jsonb_build_object(
						'for_sign',
						doc_flow_out_client_files_for_signing(t.application_id)->'files',
						'att',
						att_only_sigs.attachments
						)
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:36:52 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',		
				jsonb_agg(		
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,				
						'file_signed_by_client',app_f.file_signed_by_client,
						'signatures',sign.signatures				
					)
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 12/10/2018 16:37:24 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						doc_flow_out_client_files_for_signing(t.application_id)->'files'||
						att_only_sigs.attachments
						/*
						jsonb_build_object(
						'for_sign',
						doc_flow_out_client_files_for_signing(t.application_id)->'files',
						'att',
						att_only_sigs.attachments
						)
						*/
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 12/10/2018 16:52:20 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
					/*
					CASE
					WHEN t.sent THEN
						att_only_sigs.attachments
					ELSE
						CASE WHEN att_only_sigs.attachments IS NOT NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN att_only_sigs.attachments || doc_flow_out_client_files_for_signing(t.application_id)
						WHEN att_only_sigs.attachments IS NULL AND doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL
							THEN doc_flow_out_client_files_for_signing(t.application_id)
						ELSE '[]'::jsonb
						END
						
						CASE WHEN att_only_sigs.attachments IS NOT NULL THEN att_only_sigs.attachments
						ELSE '[]'::jsonb
						END
						||
						CASE WHEN doc_flow_out_client_files_for_signing(t.application_id) IS NOT NULL THEN doc_flow_out_client_files_for_signing(t.application_id)->'files'
						ELSE '[]'::jsonb
						END
						
					END
					*/
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 13/10/2018 09:18:14 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN att_only_sigs.attachments
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 13/10/2018 09:21:19 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::jsonb
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 13/10/2018 09:30:17 ******************
-- Trigger: doc_flow_out_client_before_trigger on doc_flow_out_client

DROP TRIGGER doc_flow_out_client_before_trigger ON doc_flow_out_client;

 CREATE TRIGGER doc_flow_out_client_before_trigger
  BEFORE DELETE OR INSERT OR UPDATE
  ON doc_flow_out_client
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_client_process();
  
  
  -- Trigger: doc_flow_out_client_after_trigger on doc_flow_out_client

-- DROP TRIGGER doc_flow_out_client_after_trigger ON doc_flow_out_client;
/*
 CREATE TRIGGER doc_flow_out_client_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_out_client
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_client_process();
*/  

-- ******************* update 13/10/2018 09:30:38 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND ( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE') AND NEW.sent AND NOT coalesce(OLD.sent,FALSE) ) ) THEN		
		NEW.date_time = now();
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 13/10/2018 10:06:27 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ) THEN
			NEW.date_time = now();
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 13/10/2018 10:06:42 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF (TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ) THEN
			NEW.date_time = now();
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 13/10/2018 10:07:03 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ) THEN
			NEW.date_time = now();
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
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
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
								
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
			
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 15/10/2018 12:06:26 ******************
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
	v_doc_flow_type_id int;
	v_date_time timestampTZ;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
	
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
				WHERE id=v_doc_flow_out_id
				RETURNING doc_flow_type_id,to_application_id
				INTO v_doc_flow_type_id,v_to_application_id;
			
				--При заключении по контракту - закрыть дату в контракте
				--Вид заключения и вид отрицательного выставляется из формы исх.письма
				IF v_doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int THEN
					UPDATE contracts
					SET expertise_result_date = NEW.date_time::date				
					WHERE application_id=v_to_application_id;
				END IF;
			
				--если основание - заявление/контракт = ответное письмо клиенту
				INSERT INTO doc_flow_in_client (
					date_time,
					reg_number,
					application_id,
					user_id,
					subject,
					content,
					--files,
					doc_flow_type_id,
					doc_flow_out_id
				)		
				SELECT
					NEW.date_time,
					t.reg_number,
					t.to_application_id,
					ap.user_id,
					--t.to_contract_id
					t.subject,
					t.content,
					/*(SELECT
						jsonb_agg(
							json_build_object(
								'file_id',at.file_id,
								'file_name',at.file_name,
								'file_size',at.file_size,
								'file_signed',at.file_signed,
								'file_uploaded',true,
								'file_path',at.file_path,
								'deleted',false,
								'date_time',at.file_date
							)
							)
					FROM doc_flow_attachments AS at WHERE at.doc_type='doc_flow_out' AND at.doc_id=t.id
					),*/
					t.doc_flow_type_id,
					v_doc_flow_out_id
				
				FROM doc_flow_out t
				LEFT JOIN applications ap ON ap.id=t.to_application_id			
				WHERE t.id=v_doc_flow_out_id AND t.to_application_id IS NOT NULL
				RETURNING id,user_id,subject
				INTO v_doc_flow_in_client,v_user_id,v_subject
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
		END IF;		
		
		IF const_client_lk_val() OR const_debug_val()
		AND NEW.subject_doc->>'dataType'='doc_flow_out' THEN
			--Если есть вложения с папками "в дело" - копируем в application_document_files
			INSERT INTO application_document_files
			(file_id,application_id,document_id,document_type,date_time,file_name,
			file_path,file_signed,file_size)
			SELECT
				at.file_id,
				out.to_application_id,0,'documents',at.file_date,at.file_name,
				at.file_path,at.file_signed,at.file_size
				
			FROM doc_flow_attachments AS at
			LEFT JOIN doc_flow_out out ON out.id=(NEW.subject_doc->'keys'->>'id')::int
			WHERE
				at.doc_type='doc_flow_out'
				AND at.doc_id=(NEW.subject_doc->'keys'->>'id')::int
				AND at.file_path!='Исходящие'
			--Все кроме исходящих
			;
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			SELECT
				doc_flow_out_id,date_time
			FROM doc_flow_out_processes
			INTO v_doc_flow_out_id,v_date_time
			WHERE register_doc->>'dataType'='doc_flow_registrations'
				AND (register_doc->'keys'->>'id')::int=OLD.id;
	
			--статус
			DELETE FROM doc_flow_out_processes
			WHERE register_doc->>'dataType'='doc_flow_registrations'
				AND (register_doc->'keys'->>'id')::int=OLD.id;
							
			DELETE FROM doc_flow_in_client WHERE doc_flow_out_id=v_doc_flow_out_id;
		END IF;
								
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_registrations_process() OWNER TO expert72;

-- ******************* update 15/10/2018 13:14:27 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(
						jsonb_build_object(
							'file_id',app_f.file_id,
							'file_name',app_f.file_name,
							'file_size',app_f.file_size,
							'file_signed',app_f.file_signed,
							'file_uploaded','true',
							'file_path',app_f.file_path,
							'signatures',sign.signatures,
							'file_signed_by_client',app_f.file_signed_by_client
						)
					)
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id									
				WHERE att.doc_type='out' AND att.doc_id=t.doc_flow_out_id
				ORDER BY app_f.file_path,app_f.file_name
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:15:12 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(
						jsonb_build_object(
							'file_id',app_f.file_id,
							'file_name',app_f.file_name,
							'file_size',app_f.file_size,
							'file_signed',app_f.file_signed,
							'file_uploaded','true',
							'file_path',app_f.file_path,
							'signatures',sign.signatures,
							'file_signed_by_client',app_f.file_signed_by_client
						)
					)
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id									
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				ORDER BY app_f.file_path,app_f.file_name
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:16:53 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id									
				GROUP BY app_f.file_path,app_f.file_name
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				ORDER BY app_f.file_path,app_f.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:17:06 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY app_f.file_path,app_f.file_name
				ORDER BY app_f.file_path,app_f.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:17:26 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY app_f.file_path,app_f.file_name,app_f.file_id
				ORDER BY app_f.file_path,app_f.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:23:45 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY app_f.file_path,app_f.file_name,app_f.file_id
				ORDER BY app_f.file_path,app_f.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:24:54 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY app_f.file_path,app_f.file_name,app_f.file_id,sign.signatures
				ORDER BY app_f.file_path,app_f.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 13:36:16 ******************

		CREATE TABLE doc_flow_out_corrections
		(doc_flow_out_id int,file_id  varchar(36),date_time timestampTZ,
		employee_id int references employees(id),
		CONSTRAINT doc_flow_out_corrections_pkey PRIMARY KEY (doc_flow_out_id,file_id)
		);
		ALTER TABLE doc_flow_out_corrections OWNER TO expert72;
		

-- ******************* update 15/10/2018 14:06:31 ******************
-- Function: doc_flow_corrections_process()

-- DROP FUNCTION doc_flow_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=NEW.doc_flow_out_id
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:31:19 ******************
-- Function: doc_flow_corrections_process()

-- DROP FUNCTION doc_flow_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=NEW.doc_flow_out_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:35:10 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY app_f.file_path,app_f.file_name,app_f.file_id,sign.signatures
				ORDER BY app_f.file_path,app_f.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 14:35:33 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY att.file_path,att.file_name,att.file_id,sign.signatures
				ORDER BY att.file_path,att.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 14:35:54 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=app_f.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY att.file_path,att.file_name,att.file_id,sign.signatures,app_f.file_signed_by_client
				ORDER BY att.file_path,att.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 14:36:35 ******************
-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=att.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY att.file_path,att.file_name,att.file_id,sign.signatures,app_f.file_signed_by_client
				ORDER BY att.file_path,att.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
				LEFT JOIN (
					SELECT
						files_t.file_id,
						jsonb_agg(files_t.signatures) AS signatures
					FROM
					(SELECT
						f_sig.file_id,
						jsonb_build_object(
							'owner',u_certs.subject_cert,
							'cert_from',u_certs.date_time_from,
							'cert_to',u_certs.date_time_to,
							'sign_date_time',f_sig.sign_date_time,
							'check_result',ver.check_result,
							'check_time',ver.check_time,
							'error_str',ver.error_str
						) AS signatures
					FROM file_signatures AS f_sig
					LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
					LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
					ORDER BY f_sig.sign_date_time
					) AS files_t
					GROUP BY files_t.file_id
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 15/10/2018 14:40:21 ******************
-- Function: doc_flow_corrections_process()

-- DROP FUNCTION doc_flow_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=NEW.doc_flow_out_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:42:06 ******************
-- Function: doc_flow_corrections_process()

-- DROP FUNCTION doc_flow_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		RAISE EXCEPTION 'NEW.is_new=%',NEW.is_new;
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=NEW.doc_flow_out_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:42:40 ******************
-- DROP TRIGGER doc_flow_out_corrections_after_trigger ON doc_flow_corrections;

 CREATE TRIGGER doc_flow_registrations_after_trigger
  AFTER INSERT
  ON doc_flow_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_corrections_process();


-- ******************* update 15/10/2018 14:43:47 ******************
-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		RAISE EXCEPTION 'NEW.is_new=%',NEW.is_new;
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=NEW.doc_flow_out_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:44:16 ******************
--DROP TRIGGER doc_flow_out_corrections_after_trigger ON doc_flow_out_corrections;

 CREATE TRIGGER doc_flow_out_registrations_after_trigger
  AFTER INSERT
  ON doc_flow_out_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_out_corrections_process();


-- ******************* update 15/10/2018 14:44:32 ******************
-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=NEW.doc_flow_out_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:45:28 ******************
-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.file_id=NEW.file_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:54:35 ******************
-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
		
			UPDATE doc_flow_in_client
			SET
				viewed = FALSE,
				viewed_dt = NULL
			WHERE id=NEW.doc_flow_out_id;
			
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.file_id=NEW.file_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:57:45 ******************
-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
		
			UPDATE doc_flow_in_client
			SET
				viewed = FALSE,
				viewed_dt = NULL
			WHERE id=NEW.doc_flow_out_id;
			
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.file_id=NEW.file_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 14:59:24 ******************
-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
		
			UPDATE doc_flow_in_client
			SET
				viewed = FALSE,
				viewed_dt = NULL
			WHERE doc_flow_out_id=NEW.doc_flow_out_id;
			
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.file_id=NEW.file_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO expert72;

-- ******************* update 15/10/2018 15:57:38 ******************

		ALTER TABLE doc_flow_in ADD COLUMN corrected_sections text;


-- ******************* update 16/10/2018 06:25:50 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections text;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section,', ')
				INTO v_corrected_sections
				FROM
				(SELECT
					DISTINCT app_f.file_path AS section
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;			
			
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('id',NEW.application_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 16/10/2018 06:26:56 ******************
-- VIEW: doc_flow_in_list

DROP VIEW doc_flow_in_list;

CREATE OR REPLACE VIEW doc_flow_in_list AS
	SELECT
		doc_flow_in.id,
		doc_flow_in.date_time,
		doc_flow_in.reg_number,
		doc_flow_in.from_addr_name,
		doc_flow_in.subject,
		
		applications_ref(applications) AS from_applications_ref,
		doc_flow_in.from_application_id AS from_application_id,
		
		contracts_ref(contracts) AS from_contracts_ref,
		contracts.id AS from_contract_id,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		doc_flow_in.recipient,
		
		CASE
			WHEN doc_flow_in.from_application_id IS NOT NULL THEN applications_ref(applications)->>'descr'||', '||(applications.applicant->>'name')
			WHEN doc_flow_in.from_client_id IS NOT NULL THEN clients_ref(clients)->>'descr'
			ELSE doc_flow_in.from_addr_name::text
		END AS sender,
		
		CASE
			WHEN doc_flow_in.from_application_id IS NOT NULL THEN
				applications.constr_name
			ELSE ''
		END AS sender_construction_name,
		
		doc_flow_in.corrected_sections				
		
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN contracts ON contracts.application_id=applications.id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	ORDER BY doc_flow_in.date_time DESC
	;
	
ALTER VIEW doc_flow_in_list OWNER TO expert72;

-- ******************* update 16/10/2018 06:42:59 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections text;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section,', ')
				INTO v_corrected_sections
				FROM
				(SELECT
					DISTINCT app_f.file_path AS section
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;			
			
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 16/10/2018 06:48:13 ******************
-- VIEW: doc_flow_in_dialog

--DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain,
		
		doc_flow_in.corrected_sections
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 16/10/2018 06:48:15 ******************
-- VIEW: doc_flow_in_dialog

--DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain,
		
		doc_flow_in.corrected_sections
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 16/10/2018 06:48:34 ******************
-- VIEW: doc_flow_in_dialog

DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain,
		
		doc_flow_in.corrected_sections
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 16/10/2018 06:48:43 ******************
-- VIEW: doc_flow_in_dialog

DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 16/10/2018 07:20:22 ******************
-- VIEW: doc_flow_in_list

DROP VIEW doc_flow_in_list;

CREATE OR REPLACE VIEW doc_flow_in_list AS
	SELECT
		doc_flow_in.id,
		doc_flow_in.date_time,
		doc_flow_in.reg_number,
		doc_flow_in.from_addr_name,
		doc_flow_in.subject,
		
		applications_ref(applications) AS from_applications_ref,
		doc_flow_in.from_application_id AS from_application_id,
		
		contracts_ref(contracts) AS from_contracts_ref,
		contracts.id AS from_contract_id,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		doc_flow_in.recipient,
		
		CASE
			WHEN doc_flow_in.from_application_id IS NOT NULL THEN applications_ref(applications)->>'descr'||', '||(applications.applicant->>'name')
			WHEN doc_flow_in.from_client_id IS NOT NULL THEN clients_ref(clients)->>'descr'
			ELSE doc_flow_in.from_addr_name::text
		END AS sender,
		
		CASE
			WHEN doc_flow_in.from_application_id IS NOT NULL THEN
				applications.constr_name
			ELSE ''
		END AS sender_construction_name,
		
		(SELECT
			string_agg(sections.section->>'name',', ')
		FROM (SELECT jsonb_array_elements(doc_flow_in.corrected_sections) AS section) AS sections
		) AS corrected_sections
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN contracts ON contracts.application_id=applications.id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	ORDER BY doc_flow_in.date_time DESC
	;
	
ALTER VIEW doc_flow_in_list OWNER TO expert72;

-- ******************* update 16/10/2018 07:21:20 ******************
-- VIEW: doc_flow_in_dialog

DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 17/10/2018 09:36:53 ******************
﻿-- Function: file_name_explode(in_file_name text)

-- DROP FUNCTION file_name_explode(in_file_name text)

CREATE OR REPLACE FUNCTION file_name_explode(in_file_name text)
  RETURNS RECORD AS
$$
	WITH exploded_name AS (SELECT unnest(string_to_array('Какое то там наименование файла .PDF','.')) AS f_name)
	SELECT
		trim(( SELECT string_agg(name_parts.f_name,'.') AS f_name FROM (SELECT f_name FROM exploded_name OFFSET 0 LIMIT (SELECT count(*)-1 FROM exploded_name)) AS name_parts )) AS f_name,
		(SELECT trim(f_name) FROM exploded_name OFFSET (SELECT count(*)-1 FROM exploded_name) LIMIT 1) AS f_ext
	;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION file_name_explode(in_file_name text) OWNER TO expert72;

-- ******************* update 17/10/2018 09:59:06 ******************
﻿-- Function: file_name_explode(in_file_name text)

-- DROP FUNCTION file_name_explode(in_file_name text)

CREATE OR REPLACE FUNCTION file_name_explode(in_file_name text)
  RETURNS RECORD AS
$$
	WITH exploded_name AS (SELECT unnest(string_to_array(in_file_name,'.')) AS f_name)
	SELECT
		trim(( SELECT string_agg(name_parts.f_name,'.') AS f_name FROM (SELECT f_name FROM exploded_name OFFSET 0 LIMIT (SELECT count(*)-1 FROM exploded_name)) AS name_parts )) AS f_name,
		(SELECT trim(f_name) FROM exploded_name OFFSET (SELECT count(*)-1 FROM exploded_name) LIMIT 1) AS f_ext
	;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION file_name_explode(in_file_name text) OWNER TO expert72;

-- ******************* update 17/10/2018 11:55:31 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 11:55:39 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 11:56:06 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 11:56:20 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 11:56:32 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 12:41:09 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			RAISE EXCEPTION '%',v_corrected_sections_o;
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 12:42:41 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb[];
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					array_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			RAISE EXCEPTION '%',v_corrected_sections_o;
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 12:44:53 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					jsonb_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_o,v_corrected_sections_t
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			RAISE EXCEPTION '%',v_corrected_sections_o;
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 12:46:25 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					jsonb_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_t,v_corrected_sections_o
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			RAISE EXCEPTION '%',v_corrected_sections_o;
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 12:46:55 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.section_o->>'name',', '),
					jsonb_agg(paths.section_o)
				FROM
				(SELECT
					DISTINCT ON (app_f.file_path)
					jsonb_build_object('name',app_f.file_path) AS section_o
				INTO v_corrected_sections_t,v_corrected_sections_o
				FROM doc_flow_out_client_document_files AS doc_f
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
				WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
				ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/10/2018 12:52:02 ******************
-- VIEW: doc_flow_in_dialog

DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		WHERE coalesce(app_f.file_deleted,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 17/10/2018 12:52:16 ******************
-- VIEW: doc_flow_in_dialog

DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',files2.attachments
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',files.attachments
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_in'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_in.id

	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id AS client_doc_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			t.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path
				,'signatures',sign.signatures
			) AS attachments
		FROM doc_flow_out_client_document_files AS t
		LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				sub.file_id,
				json_agg(sub.signatures) AS signatures
			FROM (
			SELECT 
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sub
			GROUP BY  sub.file_id		
		)  AS sign ON sign.file_id=t.file_id		
		WHERE coalesce(app_f.deleted,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id		
	) AS files2 ON files2.client_doc_id = doc_flow_in.from_doc_flow_out_client_id
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

-- ******************* update 18/10/2018 07:23:51 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types) THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания
				SELECT
					string_agg(paths.file_path,','),
					jsonb_agg(paths.section_o)
				INTO v_corrected_sections_t,v_corrected_sections_o
				FROM
				(
					SELECT 
					app_f.file_path,
					jsonb_build_object(
						'name',app_f.file_path,
						'deleted',sum(CASE WHEN doc_f.is_new THEN 0 ELSE 1 END),
						'added',sum(CASE WHEN doc_f.is_new THEN 1 ELSE 0 END)
					) AS section_o
					FROM doc_flow_out_client_document_files AS doc_f
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
					GROUP BY app_f.file_path
					ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = NEW.subject;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
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
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject,
						doc_flow_in_ref((SELECT doc_flow_in
									FROM doc_flow_in
									WHERE id = v_doc_flow_in_id
						))
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject,
				doc_flow_in_ref((SELECT doc_flow_in
							FROM doc_flow_in
							WHERE id = v_doc_flow_in_id
				))
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 20/10/2018 06:17:29 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::jsonb
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:17:51 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::json
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::json
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::json ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:17:59 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			json_build_array(
				json_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::json
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::json
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::json ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:18:53 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			json_build_array(
				json_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::json
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::json
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::json ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:19:16 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			json_build_array(
				json_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::json
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::json
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::json ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:20:11 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS json AS
$$
	/*
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			json_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
	*/
		SELECT
			json_build_object(
				'files',		
				json_agg(		
					json_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,				
						'file_signed_by_client',app_f.file_signed_by_client,
						'signatures',sign.signatures				
					)
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				json_agg(
					json_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 20/10/2018 06:20:20 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			json_build_array(
				json_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::json
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::json
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::json ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:20:44 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			json_build_array(
				json_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::json
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::json
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::json ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			json_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 20/10/2018 06:21:07 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',		
				jsonb_agg(		
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,				
						'file_signed_by_client',app_f.file_signed_by_client,
						'signatures',sign.signatures				
					)
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 20/10/2018 06:21:13 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	/*
	SELECT
		CASE WHEN t.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_object(
				'files',
				t.attachments
			)
		END
		AS attachment_files
	FROM (
	*/
		SELECT
			jsonb_build_object(
				'files',		
				jsonb_agg(		
					jsonb_build_object(
						'file_id',app_f.file_id,
						'file_name',app_f.file_name,
						'file_size',app_f.file_size,
						'file_signed',app_f.file_signed,
						'file_uploaded','true',
						'file_path',app_f.file_path,				
						'file_signed_by_client',app_f.file_signed_by_client,
						'signatures',sign.signatures				
					)
				)
			)
			AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	--) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;

-- ******************* update 20/10/2018 06:21:27 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::jsonb
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				jsonb_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 23/10/2018 14:12:06 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		/**
		 * !!!Нужны ВСЕ папки всегда!!!
		 */
		(
		SELECT
			json_agg(
				json_build_object(
					'fields',json_build_object(
						'id',doc_att.folder_id,
						'descr',doc_att.folder_descr,
						'require_client_sig',doc_att.require_client_sig
					),
					'parent_id',NULL,
					'files',CASE WHEN (doc_att.files->(0)->'file_id')::text ='null' THEN '[]'::json ELSE doc_att.files END
				)
			) AS files
		FROM
		(SELECT
			app_fd.name AS folder_descr,
			app_fd.id AS folder_id,
			app_fd.require_client_sig,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							json_build_array(
								json_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				json_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		GROUP BY app_fd.id,att.file_path,app_fd.require_client_sig
		ORDER BY app_fd.name
		)  AS doc_att
		) AS files,
		
		---***************************
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	
	
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 23/10/2018 14:16:54 ******************
-- VIEW: doc_flow_inside_dialog

DROP VIEW doc_flow_inside_dialog;

CREATE OR REPLACE VIEW doc_flow_inside_dialog AS
	SELECT
		doc_flow_inside.*,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		contracts_ref(ct) AS contracts_ref,
		employees_ref(emp) AS employees_ref,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_inside_processes_chain(doc_flow_inside.id) AS doc_flow_inside_processes_chain,
		
		--****************************
		json_build_array(
			json_build_object(
				'files',att.attachments
			)
		) AS files
		---***************************
		
	FROM doc_flow_inside
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=doc_flow_inside.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=doc_flow_inside.contract_id
	LEFT JOIN employees AS emp ON emp.id=doc_flow_inside.employee_id
	
	LEFT JOIN 
		(SELECT
			t.doc_id,
			json_agg(json_build_object(
				'file_id',t.file_id,
				'file_name',t.file_name,
				'file_size',t.file_size,
				'file_signed',t.file_signed,
				'file_uploaded','true',
				'file_path',t.file_path,
				'signatures',sign.signatures
			))
			AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str,
						'employee_id',u_certs.employee_id,
						'verif_date_time',ver.date_time
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id,f_sig.sign_date_time
			ORDER BY ver.date_time
			--ТАКАЯ СОРТИРОВКА ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ У УДАЛЕНИЕМ!!!
		) AS sign ON sign.file_id=t.file_id
	WHERE t.doc_type='doc_flow_inside'::data_types
	GROUP BY t.doc_id
	) AS att ON att.doc_id=doc_flow_inside.id

	
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=doc_flow_inside.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_inside_dialog OWNER TO expert72;

-- ******************* update 23/10/2018 14:17:47 ******************
-- VIEW: doc_flow_inside_dialog

DROP VIEW doc_flow_inside_dialog;

CREATE OR REPLACE VIEW doc_flow_inside_dialog AS
	SELECT
		doc_flow_inside.*,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		contracts_ref(ct) AS contracts_ref,
		employees_ref(emp) AS employees_ref,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_inside_processes_chain(doc_flow_inside.id) AS doc_flow_inside_processes_chain,
		
		--****************************
		json_build_array(
			json_build_object(
				'files',att.attachments
			)
		) AS files
		---***************************
		
	FROM doc_flow_inside
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=doc_flow_inside.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=doc_flow_inside.contract_id
	LEFT JOIN employees AS emp ON emp.id=doc_flow_inside.employee_id
	
	LEFT JOIN 
		(SELECT
			t.doc_id,
			json_agg(json_build_object(
				'file_id',t.file_id,
				'file_name',t.file_name,
				'file_size',t.file_size,
				'file_signed',t.file_signed,
				'file_uploaded','true',
				'file_path',t.file_path,
				'signatures',sign.signatures
			))
			AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str,
						'employee_id',u_certs.employee_id,
						'verif_date_time',ver.date_time
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id,f_sig.sign_date_time
			ORDER BY f_sig.sign_date_time
			--ТАКАЯ СОРТИРОВКА ЧТОБЫ НЕ БЫЛО ПРОБЛЕМ У УДАЛЕНИЕМ!!!
		) AS sign ON sign.file_id=t.file_id
	WHERE t.doc_type='doc_flow_inside'::data_types
	GROUP BY t.doc_id
	) AS att ON att.doc_id=doc_flow_inside.id

	
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=doc_flow_inside.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_inside_dialog OWNER TO expert72;

-- ******************* update 23/10/2018 14:24:45 ******************
-- VIEW: doc_flow_inside_dialog

DROP VIEW doc_flow_inside_dialog;

CREATE OR REPLACE VIEW doc_flow_inside_dialog AS
	SELECT
		doc_flow_inside.*,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		contracts_ref(ct) AS contracts_ref,
		employees_ref(emp) AS employees_ref,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_inside_processes_chain(doc_flow_inside.id) AS doc_flow_inside_processes_chain,
		
		--****************************
		json_build_array(
			json_build_object(
				'files',att.attachments
			)
		) AS files
		---***************************
		
	FROM doc_flow_inside
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=doc_flow_inside.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=doc_flow_inside.contract_id
	LEFT JOIN employees AS emp ON emp.id=doc_flow_inside.employee_id
	
	LEFT JOIN 
		(SELECT
			t.doc_id,
			json_agg(json_build_object(
				'file_id',t.file_id,
				'file_name',t.file_name,
				'file_size',t.file_size,
				'file_signed',t.file_signed,
				'file_uploaded','true',
				'file_path',t.file_path,
				'signatures',sign.signatures
			))
			AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				json_agg(files_t.signatures) AS signatures
			FROM			
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str,
					'employee_id',u_certs.employee_id,
					'verif_date_time',ver.date_time
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id
	WHERE t.doc_type='doc_flow_inside'::data_types
	GROUP BY t.doc_id
	) AS att ON att.doc_id=doc_flow_inside.id

	
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=doc_flow_inside.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_inside_dialog OWNER TO expert72;

-- ******************* update 23/10/2018 14:24:57 ******************
-- VIEW: doc_flow_inside_dialog

DROP VIEW doc_flow_inside_dialog;

CREATE OR REPLACE VIEW doc_flow_inside_dialog AS
	SELECT
		doc_flow_inside.*,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		contracts_ref(ct) AS contracts_ref,
		employees_ref(emp) AS employees_ref,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_inside_processes_chain(doc_flow_inside.id) AS doc_flow_inside_processes_chain,
		
		--****************************
		json_build_array(
			json_build_object(
				'files',att.attachments
			)
		) AS files
		---***************************
		
	FROM doc_flow_inside
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=doc_flow_inside.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=doc_flow_inside.contract_id
	LEFT JOIN employees AS emp ON emp.id=doc_flow_inside.employee_id
	
	LEFT JOIN 
		(SELECT
			t.doc_id,
			json_agg(json_build_object(
				'file_id',t.file_id,
				'file_name',t.file_name,
				'file_size',t.file_size,
				'file_signed',t.file_signed,
				'file_uploaded','true',
				'file_path',t.file_path,
				'signatures',sign.signatures
			))
			AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				json_agg(files_t.signatures) AS signatures
			FROM			
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str,
					'employee_id',u_certs.employee_id,
					'verif_date_time',ver.date_time
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=t.file_id
	WHERE t.doc_type='doc_flow_inside'::data_types
	GROUP BY t.doc_id
	) AS att ON att.doc_id=doc_flow_inside.id

	
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=doc_flow_inside.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_inside_dialog OWNER TO expert72;

-- ******************* update 25/10/2018 09:40:42 ******************
-- VIEW: doc_flow_out_client_list

--DROP VIEW doc_flow_out_client_list;

CREATE OR REPLACE VIEW doc_flow_out_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO expert72;

-- ******************* update 30/10/2018 17:52:40 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::jsonb
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;
