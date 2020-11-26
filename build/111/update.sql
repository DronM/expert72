-- ******************* update 28/10/2020 06:45:26 ******************
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
	v_corrected_files_t text;
	v_doc_flow_in doc_flow_in;
	v_server_for_href text;
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
	v_application_service_type service_types;
	v_ext_contract bool;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		AND NEW.admin_correction=FALSE
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
		AND (NOT const_client_lk_val() OR const_debug_val())
		AND NEW.admin_correction=FALSE
		THEN
		
			v_server_for_href = 'http://192.168.1.134/expert72/';
		
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0),
				app.service_type,
				coalesce(app.ext_contract,FALSE)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget,
				v_application_service_type,
				v_ext_contract
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.service_type = app.service_type)
					OR (contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
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
			
			--	4) Продление срока
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='contr_other'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='date_prolongate'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='app_contr_revoke'::doc_flow_out_client_types)
			THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
		
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(coalesce(v_applicant->>'name',v_applicant->>'name_full'))::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания, свернуто
				SELECT
					string_agg(paths.file_path,','),
					jsonb_agg(paths.section_o)
				INTO
					v_corrected_sections_t,
					v_corrected_sections_o
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
					GROUP BY app_f.file_path
					ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||
					CASE WHEN v_ext_contract THEN ' (внеконтракт)' ELSE '' END||
					', контракт №'||v_contract_number||', '||(coalesce(v_applicant->>'name',v_applicant->>'name_full'))::text;
			ELSE
				v_doc_flow_subject = enum_doc_flow_out_client_types_val(NEW.doc_flow_out_client_type,'ru')||
					CASE WHEN v_ext_contract THEN ' (внеконтракт)' ELSE '' END;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(coalesce(v_applicant->>'name',v_applicant->>'name_full'))::text;
			END IF;
			
			--Новое входящее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,
				from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections,
				ext_contract
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				
				coalesce(v_applicant->>'name',v_applicant->>'name_full'),
				(v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_other'::doc_flow_out_client_types THEN
						5--Просто письмо входящее
					WHEN NEW.doc_flow_out_client_type='date_prolongate'::doc_flow_out_client_types THEN
						16--Продление срока
					WHEN NEW.doc_flow_out_client_type='app_contr_revoke'::doc_flow_out_client_types AND v_contract_id IS NULL THEN
						13--Отзыв
					
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o,
				v_ext_contract
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			IF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Файлы развернуто со ссылками
				SELECT
					string_agg(fl.f_descr,E'\n\n')
				INTO
					v_corrected_files_t
				FROM(	
					SELECT 
						CASE WHEN app_f.information_list THEN 'Удостоверяющий лист ' ELSE '' END||
						app_f.file_path||'/'||app_f.file_name||
						format(E'\n%s?c=DocFlowOut_Controller&f=get_file&v=ViewXML&file_id=%s&doc_id=%s',
						v_server_for_href,app_f.file_id,v_doc_flow_in_id)
						AS f_descr
					FROM doc_flow_out_client_document_files AS doc_f
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
					WHERE
						doc_f.doc_flow_out_client_id=NEW.id
						AND app_f.document_id<>0
						AND doc_f.is_new
					ORDER BY app_f.information_list,app_f.file_path,app_f.file_name
				) AS fl				
				;
			END IF;
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			--************** all rows ********************************************
			SELECT INTO v_doc_flow_in * FROM doc_flow_in WHERE id=v_doc_flow_in_id;
			--********************************************************************

			IF v_contract_id IS NULL THEN --AND NEW.doc_flow_out_client_type='app'::doc_flow_out_client_types THEN
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
					doc_flow_in_ref(v_doc_flow_in),
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
					doc_flow_in_ref(v_doc_flow_in)
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
						doc_flow_in_ref(v_doc_flow_in)					
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
					doc_flow_in_ref(v_doc_flow_in)					
					
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
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
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
						v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
						doc_flow_in_ref(v_doc_flow_in)
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);								
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
/*				
RAISE EXCEPTION 'contracts_work_end_date=%',(SELECT contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						FROM contracts
						WHERE contracts.id=v_contract_id
					);
*/					
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN
								v_set_budget_contrcat_date
								--Еще есть измененная документация, там тоже сразу экспертиза!
								--Нет такого никогда, т.к. там сразу при рассмотрении экспертиза!!!
								OR
								(v_application_state='waiting_for_contract'
									AND v_application_service_type='modified_documents'
								)
							THEN 'expertise'::application_states
							
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
						ROW('applicant', (coalesce(v_applicant->>'name',v_applicant->>'name_full'))::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value,
						ROW('files',v_corrected_files_t)::template_value,
						ROW('server',v_server_for_href)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
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
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				doc_flow_in_ref(v_doc_flow_in)
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
					WHERE fld.obj->>'dataType'='employees' AND fld.obj->'keys'->>'id' ~ '^[0-9\.]+$'
					)
				)
			);
		
		ELSIF
		(TG_OP='UPDATE' AND NEW.sent=FALSE AND OLD.sent=TRUE)
		AND (NOT const_client_lk_val() OR const_debug_val())
		AND NEW.admin_correction=FALSE
		THEN
			--отмена отправки
			DELETE FROM doc_flow_out_client_reg_numbers WHERE application_id=NEW.application_id AND doc_flow_out_client_id=NEW.id;
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;



-- ******************* update 28/10/2020 10:00:19 ******************

	-- Adding menu item
	INSERT INTO views
	(id,c,f,t,section,descr,limited)
	VALUES (
	'20024',
	'DocFlowExamination_Controller',
	'get_ext_list',
	'DocFlowExaminationExtList',
	'Документы',
	'Рассмотрения (внеконтракты)',
	FALSE
	);
	-- Adding menu item
	INSERT INTO views
	(id,c,f,t,section,descr,limited)
	VALUES (
	'20025',
	'DocFlowApprovement_Controller',
	'get_ext_list',
	'DocFlowApprovementExtList',
	'Документы',
	'Согласования (внеконтракты)',
	FALSE
	);
	

-- ******************* update 28/10/2020 10:07:05 ******************
-- VIEW: doc_flow_examinations_ext_list

--DROP VIEW doc_flow_examinations_ext_list;

CREATE OR REPLACE VIEW doc_flow_examinations_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		doc_flow_in_ref(doc_flow_in) subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		CASE
			WHEN (t.recipient->>'dataType')::data_types='departments'::data_types THEN departments_ref(departments)
			WHEN (t.recipient->>'dataType')::data_types='employees'::data_types THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id,
		
		t.application_resolution_state,
		t.employee_id
		
	FROM doc_flow_examinations AS t
	LEFT JOIN doc_flow_in ON doc_flow_in.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_in'
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	LEFT JOIN departments ON departments.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='employees'
	
	-- EXT
	WHERE doc_flow_in.ext_contract=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_examinations_ext_list OWNER TO expert72;


-- ******************* update 28/10/2020 10:07:45 ******************
-- VIEW: doc_flow_examinations_list

--DROP VIEW doc_flow_examinations_list;

CREATE OR REPLACE VIEW doc_flow_examinations_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		doc_flow_in_ref(doc_flow_in) subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		CASE
			WHEN (t.recipient->>'dataType')::data_types='departments'::data_types THEN departments_ref(departments)
			WHEN (t.recipient->>'dataType')::data_types='employees'::data_types THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id,
		
		t.application_resolution_state,
		t.employee_id
		
	FROM doc_flow_examinations AS t
	LEFT JOIN doc_flow_in ON doc_flow_in.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_in'
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	LEFT JOIN departments ON departments.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='employees'
	
	-- NOT EXT
	WHERE coalesce(doc_flow_in.ext_contract,FALSE)=FALSE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_examinations_list OWNER TO expert72;


-- ******************* update 28/10/2020 10:08:00 ******************
-- VIEW: doc_flow_examinations_ext_list

--DROP VIEW doc_flow_examinations_ext_list;

CREATE OR REPLACE VIEW doc_flow_examinations_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		doc_flow_in_ref(doc_flow_in) subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		CASE
			WHEN (t.recipient->>'dataType')::data_types='departments'::data_types THEN departments_ref(departments)
			WHEN (t.recipient->>'dataType')::data_types='employees'::data_types THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id,
		
		t.application_resolution_state,
		t.employee_id
		
	FROM doc_flow_examinations AS t
	LEFT JOIN doc_flow_in ON doc_flow_in.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_in'
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	LEFT JOIN departments ON departments.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='employees'
	
	-- EXT
	WHERE coalesce(doc_flow_in.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_examinations_ext_list OWNER TO expert72;


-- ******************* update 28/10/2020 10:10:05 ******************
-- VIEW: doc_flow_approvements_list

--DROP VIEW doc_flow_approvements_list;

CREATE OR REPLACE VIEW doc_flow_approvements_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		
		CASE
			WHEN t.subject_doc->>'dataType'='doc_flow_out' THEN doc_flow_out_ref(doc_flow_out)
			WHEN t.subject_doc->>'dataType'='doc_flow_inside' THEN doc_flow_inside_ref(doc_flow_inside)
			ELSE NULL
		END
		AS subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		(SELECT
			string_agg(person_init(list.e,FALSE),', ')
		FROM (
			SELECT
				jsonb_array_elements(t.recipient_list->'rows')->'fields'->'employee'->>'descr' AS e
			) AS list			
		) AS recipient_list,
		
		t.step_count,
		t.current_step,
		
		t.close_result,
		
		ARRAY(
			SELECT
			(jsonb_array_elements(t1.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int
			FROM doc_flow_approvements AS t1 WHERE t1.id=t.id
		) AS recipient_employee_id_list,
		
		t.employee_id,
		
		st.state AS contract_state
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	LEFT JOIN doc_flow_inside ON doc_flow_inside.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_inside'
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN applications ON applications.id=contracts.application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=applications.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	--NOT EXT
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=FALSE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_list OWNER TO expert72;


-- ******************* update 28/10/2020 10:10:59 ******************
-- VIEW: doc_flow_approvements_ext_list

--DROP VIEW doc_flow_approvements_ext_list;

CREATE OR REPLACE VIEW doc_flow_approvements_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		
		CASE
			WHEN t.subject_doc->>'dataType'='doc_flow_out' THEN doc_flow_out_ref(doc_flow_out)
			WHEN t.subject_doc->>'dataType'='doc_flow_inside' THEN doc_flow_inside_ref(doc_flow_inside)
			ELSE NULL
		END
		AS subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		(SELECT
			string_agg(person_init(list.e,FALSE),', ')
		FROM (
			SELECT
				jsonb_array_elements(t.recipient_list->'rows')->'fields'->'employee'->>'descr' AS e
			) AS list			
		) AS recipient_list,
		
		t.step_count,
		t.current_step,
		
		t.close_result,
		
		ARRAY(
			SELECT
			(jsonb_array_elements(t1.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int
			FROM doc_flow_approvements AS t1 WHERE t1.id=t.id
		) AS recipient_employee_id_list,
		
		t.employee_id,
		
		st.state AS contract_state
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	LEFT JOIN doc_flow_inside ON doc_flow_inside.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_inside'
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN applications ON applications.id=contracts.application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=applications.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	--NOT EXT
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_ext_list OWNER TO expert72;


-- ******************* update 28/10/2020 10:11:23 ******************
-- VIEW: doc_flow_approvements_ext_list

--DROP VIEW doc_flow_approvements_ext_list;

CREATE OR REPLACE VIEW doc_flow_approvements_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		
		CASE
			WHEN t.subject_doc->>'dataType'='doc_flow_out' THEN doc_flow_out_ref(doc_flow_out)
			WHEN t.subject_doc->>'dataType'='doc_flow_inside' THEN doc_flow_inside_ref(doc_flow_inside)
			ELSE NULL
		END
		AS subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		(SELECT
			string_agg(person_init(list.e,FALSE),', ')
		FROM (
			SELECT
				jsonb_array_elements(t.recipient_list->'rows')->'fields'->'employee'->>'descr' AS e
			) AS list			
		) AS recipient_list,
		
		t.step_count,
		t.current_step,
		
		t.close_result,
		
		ARRAY(
			SELECT
			(jsonb_array_elements(t1.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int
			FROM doc_flow_approvements AS t1 WHERE t1.id=t.id
		) AS recipient_employee_id_list,
		
		t.employee_id,
		
		st.state AS contract_state
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	LEFT JOIN doc_flow_inside ON doc_flow_inside.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_inside'
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN applications ON applications.id=contracts.application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=applications.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	--NOT EXT
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_ext_list OWNER TO expert72;


-- ******************* update 28/10/2020 10:16:34 ******************
-- VIEW: doc_flow_approvements_ext_list

--DROP VIEW doc_flow_approvements_ext_list;

CREATE OR REPLACE VIEW doc_flow_approvements_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.subject,
		
		CASE
			WHEN t.subject_doc->>'dataType'='doc_flow_out' THEN doc_flow_out_ref(doc_flow_out)
			WHEN t.subject_doc->>'dataType'='doc_flow_inside' THEN doc_flow_inside_ref(doc_flow_inside)
			ELSE NULL
		END
		AS subject_docs_ref,
		
		doc_flow_importance_types_ref(doc_flow_importance_types) AS doc_flow_importance_types_ref,
		t.end_date_time,
		
		employees_ref(employees) AS employees_ref,
		
		t.close_date_time,
		t.closed,
		
		(SELECT
			string_agg(person_init(list.e,FALSE),', ')
		FROM (
			SELECT
				jsonb_array_elements(t.recipient_list->'rows')->'fields'->'employee'->>'descr' AS e
			) AS list			
		) AS recipient_list,
		
		t.step_count,
		t.current_step,
		
		t.close_result,
		
		ARRAY(
			SELECT
			(jsonb_array_elements(t1.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int
			FROM doc_flow_approvements AS t1 WHERE t1.id=t.id
		) AS recipient_employee_id_list,
		
		t.employee_id,
		
		st.state AS contract_state
		
	FROM doc_flow_approvements AS t
	LEFT JOIN doc_flow_out ON doc_flow_out.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_out'
	LEFT JOIN doc_flow_inside ON doc_flow_inside.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_inside'
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN applications ON applications.id=contracts.application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=applications.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	--NOT EXT
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_ext_list OWNER TO expert72;
