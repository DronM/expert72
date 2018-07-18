ALTER TABLE public.contracts ALTER COLUMN date_time DROP DEFAULT;

-- ******************* update 17/07/2018 17:11:14 ******************
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
				
			ELSIF v_main_expert_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
							
				--ЕСТЬ Контракт и есть Гл.эксперт и не возврат контракта - напоминание&&email Гл.эксперту 
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
				UPDATE contracts
				SET
					contract_return_date = NEW.date_time::date,
					date_time = NEW.date_time
				WHERE id=v_contract_id;
				
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
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/07/2018 17:16:32 ******************
-- Function: doc_flow_examinations_process()

-- DROP FUNCTION doc_flow_examinations_process();

CREATE OR REPLACE FUNCTION doc_flow_examinations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_ref JSONB;
	v_application_id int;
	v_app_expertise_type expertise_types;
	v_app_cost_eval_validity bool;
	v_app_modification bool;
	v_app_audit bool;	
	v_app_client_id int;
	v_app_user_id int;
	v_app_applicant JSONB;
	v_primary_contracts_ref JSONB;
	v_modif_primary_contracts_ref JSONB;	
	v_linked_contracts_ref JSONB;
	v_app_process_dt timestampTZ;
	v_linked_app int;
	v_cost_eval_validity_simult bool;
	v_constr_name text;
	v_constr_address jsonb;
	v_constr_technical_features jsonb;
	v_linked_contracts JSONB[];
	v_linked_contracts_n int;
	v_new_contract_number text;
	v_document_type document_types;
	v_expertise_result_number text;
	v_date_type date_types;
	v_work_day_count int;
	v_expert_work_day_count int;
	v_office_id int;
	v_new_contract_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		v_ref = doc_flow_examinations_ref((SELECT doc_flow_examinations FROM doc_flow_examinations WHERE id=NEW.id));
		--статус
		INSERT INTO doc_flow_in_processes (
			doc_flow_in_id, date_time,
			state,
			register_doc,
			doc_flow_importance_type_id,
			description,
			end_date_time
		)
		VALUES (
			(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
			CASE WHEN NEW.closed THEN 'examined'::doc_flow_in_states ELSE 'examining'::doc_flow_in_states END,
			v_ref,
			NEW.doc_flow_importance_type_id,
			NEW.subject,
			NEW.end_date_time
		);
			
		--если тип основания - письмо, чье основание - заявление - сменим его статус
		IF NEW.subject_doc->>'dataType'='doc_flow_in' THEN
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(NEW.subject_doc->'keys'->>'id')::int;
			IF (v_application_id IS NOT NULL) THEN
				IF NEW.closed THEN
					SELECT
						greatest(NEW.date_time,date_time+'1 second'::interval)
					INTO v_app_process_dt
					FROM application_processes
					WHERE application_id=v_application_id
					ORDER BY date_time DESC
					LIMIT 1;
				ELSE
					v_app_process_dt = NEW.date_time;
				END IF;
				--статус
				INSERT INTO application_processes (
					application_id,
					date_time,
					state,
					user_id,
					end_date_time
				)
				VALUES (
					v_application_id,
					v_app_process_dt,
					CASE WHEN NEW.closed THEN NEW.application_resolution_state ELSE 'checking'::application_states END,
					(SELECT user_id FROM employees WHERE id=NEW.employee_id),
					NEW.end_date_time
				);			
			END IF;
		END IF;
			
		--задачи
		INSERT INTO doc_flow_tasks (
			register_doc,
			date_time,end_date_time,
			doc_flow_importance_type_id,
			employee_id,
			recipient,
			description,
			closed,
			close_doc,
			close_date_time,
			close_employee_id
		)
		VALUES (
			v_ref,
			NEW.date_time,NEW.end_date_time,
			NEW.doc_flow_importance_type_id,
			NEW.employee_id,
			NEW.recipient,
			NEW.subject,
			NEW.closed,
			CASE WHEN NEW.closed THEN v_ref ELSE NULL END,
			CASE WHEN NEW.closed THEN now() ELSE NULL END,
			CASE WHEN NEW.closed THEN NEW.close_employee_id ELSE NULL END
		);
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		v_ref = doc_flow_examinations_ref((SELECT doc_flow_examinations FROM doc_flow_examinations WHERE id=NEW.id));
		
		--state
		IF NEW.date_time<>OLD.date_time
			OR NEW.end_date_time<>OLD.end_date_time
			OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
			OR NEW.subject_doc<>OLD.subject_doc
			OR NEW.subject<>OLD.subject
			OR NEW.date_time<>OLD.date_time
			--OR (NEW.employee_id<>OLD.employee_id AND NEW.subject_doc->>'dataType'='doc_flow_in'
		THEN
			UPDATE doc_flow_in_processes
			SET
				date_time			= NEW.date_time,
				doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
				doc_flow_in_id			= (NEW.subject_doc->'keys'->>'id')::int,
				description			= NEW.subject,
				end_date_time			= NEW.end_date_time
			WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=NEW.id;
		END IF;
	
		--сменим статус при закрытии
		IF NEW.closed<>OLD.closed THEN
			INSERT INTO doc_flow_in_processes (
				doc_flow_in_id,
				date_time,
				state,
				register_doc,
				doc_flow_importance_type_id,
				end_date_time
			)
			VALUES (
				(NEW.subject_doc->'keys'->>'id')::int,
				CASE WHEN NEW.closed THEN NEW.close_date_time ELSE now() END,
				CASE WHEN NEW.closed THEN 'examined'::doc_flow_in_states ELSE 'examining'::doc_flow_in_states END,
				v_ref,
				NEW.doc_flow_importance_type_id,
				NEW.end_date_time
			);		
		END IF;
	
		--если тип основания - заявление - сменим его статус
		IF NEW.subject_doc->>'dataType'='doc_flow_in' AND NEW.closed<>OLD.closed AND NEW.closed THEN
			SELECT
				from_application_id,
				doc_flow_out.new_contract_number
			INTO
				v_application_id,
				v_new_contract_number
			FROM doc_flow_in
			LEFT JOIN doc_flow_out ON doc_flow_out.doc_flow_in_id=doc_flow_in.id
			WHERE doc_flow_in.id=(NEW.subject_doc->'keys'->>'id')::int;
			
			IF v_application_id IS NOT NULL THEN
				IF NEW.closed THEN
					SELECT
						greatest(NEW.close_date_time,date_time+'1 second'::interval)
					INTO v_app_process_dt
					FROM application_processes
					WHERE application_id=v_application_id
					ORDER BY date_time DESC
					LIMIT 1;
				ELSE
					v_app_process_dt = NEW.close_date_time;
				END IF;
			
				--статус
				INSERT INTO application_processes (
					application_id,
					date_time,
					state,
					user_id,
					end_date_time
				)
				VALUES (
					v_application_id,
					v_app_process_dt,
					CASE WHEN NEW.closed THEN NEW.application_resolution_state ELSE 'checking'::application_states END,
					(SELECT user_id FROM employees WHERE id=NEW.employee_id),
					CASE WHEN NEW.closed THEN NULL ELSE NEW.end_date_time END					
				);			
			END IF;
			
			--НОВЫЙ КОНТРАКТ
			IF NEW.application_resolution_state='waiting_for_contract' THEN
				SELECT
					app.expertise_type,
					app.cost_eval_validity,
					app.modification,
					app.audit,
					app.user_id,
					app.applicant,
					(contracts_ref(p_contr))::jsonb,
					(contracts_ref(mp_contr))::jsonb,
					coalesce(app.base_application_id,app.derived_application_id),
					app.cost_eval_validity_simult,
					app.constr_name,
					app.constr_address,
					app.constr_technical_features,
					CASE
						WHEN app.expertise_type IS NOT NULL THEN 'pd'::document_types
						WHEN app.cost_eval_validity THEN 'cost_eval_validity'::document_types
						WHEN app.modification THEN 'modification'::document_types
						WHEN app.audit THEN 'audit'::document_types						
					END,
					app.office_id
					
				INTO
					v_app_expertise_type,
					v_app_cost_eval_validity,
					v_app_modification,
					v_app_audit,
					v_app_user_id,
					v_app_applicant,
					v_primary_contracts_ref,
					v_modif_primary_contracts_ref,
					v_linked_app,
					v_cost_eval_validity_simult,
					v_constr_name,
					v_constr_address,
					v_constr_technical_features,
					v_document_type,
					v_office_id
					
				FROM applications AS app
				LEFT JOIN contracts AS p_contr ON p_contr.application_id=app.primary_application_id
				LEFT JOIN contracts AS mp_contr ON mp_contr.application_id=app.modif_primary_application_id
				WHERE app.id=v_application_id;
				
				--applicant -->> client
				UPDATE clients
				SET
					name		= v_app_applicant->>'name',
					name_full	= v_app_applicant->>'name_full',
					ogrn		= v_app_applicant->>'ogrn',
					inn		= v_app_applicant->>'inn',
					kpp		= v_app_applicant->>'kpp',
					okpo		= v_app_applicant->>'okpo',
					okved		= v_app_applicant->>'okved',
					post_address	= v_app_applicant->'post_address',
					user_id		= v_app_user_id,
					legal_address	= v_app_applicant->'legal_address',
					bank_accounts	= v_app_applicant->'bank_accounts',
					client_type	= (v_app_applicant->>'client_type')::client_types,
					base_document_for_contract = v_app_applicant->>'base_document_for_contract',
					person_id_paper	= v_app_applicant->'person_id_paper',
					person_registr_paper = v_app_applicant->'person_registr_paper'
				WHERE name = v_app_applicant->>'name' OR (inn=v_app_applicant->>'inn' AND kpp=v_app_applicant->>'kpp')
				RETURNING id INTO v_app_client_id;
				
				IF NOT FOUND THEN
					INSERT INTO clients
					(
						name,
						name_full,
						inn,
						kpp,
						ogrn,
						okpo,
						okved,
						post_address,
						user_id,
						legal_address,
						bank_accounts,
						client_type,
						base_document_for_contract,
						person_id_paper,
						person_registr_paper
					)
					VALUES(
						v_app_applicant->>'name',
						v_app_applicant->>'name_full',
						v_app_applicant->>'inn',
						v_app_applicant->>'kpp',
						v_app_applicant->>'ogrn',
						v_app_applicant->>'okpo',
						v_app_applicant->>'okved',
						v_app_applicant->'post_address',
						v_app_user_id,
						v_app_applicant->'legal_address',
						v_app_applicant->'bank_accounts',
						(v_app_applicant->>'client_type')::client_types,
						v_app_applicant->>'base_document_for_contract',
						v_app_applicant->'person_id_paper',
						v_app_applicant->'person_registr_paper'
					)				
					RETURNING id
					INTO v_app_client_id
					;
				END IF;
				
				v_linked_contracts_n = 0;
				IF (v_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					v_linked_contracts_n = v_linked_contracts_n + 1;
					v_linked_contracts = v_linked_contracts || jsonb_build_object('fields',jsonb_build_object('id',v_linked_contracts_n,'contracts_ref',v_primary_contracts_ref));
				END IF;
				IF (v_modif_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					v_linked_contracts_n = v_linked_contracts_n + 1;
					v_linked_contracts = v_linked_contracts || jsonb_build_object('fields',jsonb_build_object('id',v_linked_contracts_n,'contracts_ref',v_modif_primary_contracts_ref));
				END IF;
				
				IF v_linked_app IS NOT NULL THEN
					--Поиск связного контракта по заявлению
					SELECT contracts_ref(contracts) INTO v_linked_contracts_ref FROM contracts WHERE application_id=v_linked_app;
					IF v_linked_contracts_ref IS NOT NULL THEN
						v_linked_contracts_n = v_linked_contracts_n + 1;
						v_linked_contracts = v_linked_contracts || jsonb_build_object('fields',jsonb_build_object('id',v_linked_contracts_n,'contracts_ref',v_linked_contracts_ref));
					END IF;
				END IF;
				
				--Сначала из исх.письма, затем генерим новый
				IF v_new_contract_number IS NULL THEN
					v_new_contract_number = contracts_next_number(v_document_type,now()::date);
				END IF;
				
				--Номер экспертного заключения
				v_expertise_result_number = regexp_replace(v_new_contract_number,'\D+.*$','');
				v_expertise_result_number = substr('0000',1,4-length(v_expertise_result_number))||
							v_expertise_result_number||
							'/'||(extract(year FROM now())-2000)::text;
				
				--Дни проверки
				SELECT
					services.date_type,
					services.work_day_count,
					services.expertise_day_count
				INTO
					v_date_type,
					v_work_day_count,
					v_expert_work_day_count
				FROM services
				WHERE services.id=
				((
					CASE
						WHEN v_document_type='pd' THEN pdfn_services_expertise()
						WHEN v_document_type='cost_eval_validity' THEN pdfn_services_cost_eval_validity()
						WHEN v_document_type='modification' THEN pdfn_services_modification()
						WHEN v_document_type='audit' THEN pdfn_services_audit()
						ELSE NULL
					END
				)->'keys'->>'id')::int;
								
				--RAISE EXCEPTION 'v_linked_contracts=%',v_linked_contracts;
				--Контракт
				INSERT INTO contracts (
					--date_time,
					application_id,
					client_id,
					employee_id,
					document_type,
					expertise_type,
					cost_eval_validity_pd_order,
					constr_name,
					constr_address,
					constr_technical_features,
					contract_number,
					expertise_result_number,
					linked_contracts,
					contract_date,					
					date_type,
					expertise_day_count,
					expert_work_day_count,
					work_end_date,
					expert_work_end_date,
					permissions,
					user_id)
				VALUES (
					--now(),
					v_application_id,
					v_app_client_id,
					NEW.close_employee_id,
					v_document_type,
					v_app_expertise_type,
					CASE
						WHEN v_app_cost_eval_validity THEN
							CASE
								WHEN v_cost_eval_validity_simult THEN 'simult_with_pd'::cost_eval_validity_pd_orders
								WHEN v_linked_app IS NOT NULL THEN 'after_pd'::cost_eval_validity_pd_orders
								ELSE 'no_pd'::cost_eval_validity_pd_orders
							END
						ELSE NULL
					END,
					v_constr_name,
					v_constr_address,
					v_constr_technical_features,
					
					v_new_contract_number,
					v_expertise_result_number,
					
					--linked_contracts
					CASE WHEN v_linked_contracts IS NOT NULL THEN
						jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',v_linked_contracts
						)
					ELSE
						'{"id":"LinkedContractList_Model","rows":[]}'::jsonb
					END,
					
					now()::date,--contract_date
					
					v_date_type,
					v_work_day_count,
					v_expert_work_day_count,
					
					--ПРИ ОПЛАТЕ client_payments_process()
					--ставятся work_start_date&&work_end_date
					--contracts_work_end_date(v_office_id, v_date_type, now(), v_work_day_count),
					NULL,
					NULL,					
					
					'{"id":"AccessPermission_Model","rows":[]}'::jsonb,
					
					v_app_user_id
				)
				RETURNING id INTO v_new_contract_id;
				
				--В связные контракты запишем данный по текущему новому
				IF (v_linked_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
				--RAISE EXCEPTION 'Updating contracts, id=%',(v_linked_contracts_ref->'keys'->>'id')::int;
					UPDATE contracts
					SET
						linked_contracts = jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',
							linked_contracts->'rows'||
								jsonb_build_object(
								'fields',jsonb_build_object(
									'id',
									jsonb_array_length(linked_contracts->'rows')+1,
									'contracts_ref',contracts_ref((SELECT contracts FROM contracts WHERE id=v_new_contract_id))
									)
								)							
						)
					WHERE id=(v_linked_contracts_ref->'keys'->>'id')::int;
				END IF;
				IF (v_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					UPDATE contracts
					SET
						linked_contracts = jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',
							linked_contracts->'rows'||
								jsonb_build_object(
								'fields',jsonb_build_object(
									'id',
									jsonb_array_length(linked_contracts->'rows')+1,
									'contracts_ref',contracts_ref((SELECT contracts FROM contracts WHERE id=v_new_contract_id))
									)
								)							
						)
					WHERE id=(v_primary_contracts_ref->'keys'->>'id')::int;
				END IF;
				IF (v_modif_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					UPDATE contracts
					SET
						linked_contracts = jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',
							linked_contracts->'rows'||
								jsonb_build_object(
								'fields',jsonb_build_object(
									'id',
									jsonb_array_length(linked_contracts->'rows')+1,
									'contracts_ref',contracts_ref((SELECT contracts FROM contracts WHERE id=v_new_contract_id))
									)
								)							
						)
					WHERE id=(v_modif_primary_contracts_ref->'keys'->>'id')::int;
				END IF;
				
			END IF;
		END IF;
						
		--задачи
		UPDATE doc_flow_tasks
		SET 
			date_time			= NEW.date_time,
			end_date_time			= NEW.end_date_time,
			doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
			employee_id			= NEW.employee_id,
			description			= NEW.subject,
			closed				= NEW.closed,
			close_doc			= CASE WHEN NEW.closed THEN v_ref ELSE NULL END,
			close_date_time			= CASE WHEN NEW.closed THEN now() ELSE NULL END,
			close_employee_id		= CASE WHEN NEW.closed THEN NEW.close_employee_id ELSE NULL END
		WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		--статус
		--DELETE FROM doc_flow_in_processes WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
		--задачи
		--DELETE FROM doc_flow_tasks WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--статус
		DELETE FROM doc_flow_in_processes WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=OLD.id;
		--задачи
		DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=OLD.id;
		IF (OLD.subject_doc->>'dataType')::data_types='doc_flow_in'::data_types THEN
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(OLD.subject_doc->'keys'->>'id')::int;
			IF v_application_id IS NOT NULL THEN
				DELETE FROM application_processes WHERE doc_flow_examination_id=OLD.id;
			END IF;
		END IF;
											
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_examinations_process() OWNER TO expert72;

-- ******************* update 17/07/2018 17:23:40 ******************
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
				
			ELSIF v_main_expert_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
							
				--ЕСТЬ Контракт и есть Гл.эксперт и не возврат контракта - напоминание&&email Гл.эксперту 
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
				UPDATE contracts
				SET
					contract_return_date = NEW.date_time::date,
					contract_date = NEW.date_time
				WHERE id=v_contract_id;
				
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
			);
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 17/07/2018 17:24:14 ******************
-- Function: doc_flow_examinations_process()

-- DROP FUNCTION doc_flow_examinations_process();

CREATE OR REPLACE FUNCTION doc_flow_examinations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_ref JSONB;
	v_application_id int;
	v_app_expertise_type expertise_types;
	v_app_cost_eval_validity bool;
	v_app_modification bool;
	v_app_audit bool;	
	v_app_client_id int;
	v_app_user_id int;
	v_app_applicant JSONB;
	v_primary_contracts_ref JSONB;
	v_modif_primary_contracts_ref JSONB;	
	v_linked_contracts_ref JSONB;
	v_app_process_dt timestampTZ;
	v_linked_app int;
	v_cost_eval_validity_simult bool;
	v_constr_name text;
	v_constr_address jsonb;
	v_constr_technical_features jsonb;
	v_linked_contracts JSONB[];
	v_linked_contracts_n int;
	v_new_contract_number text;
	v_document_type document_types;
	v_expertise_result_number text;
	v_date_type date_types;
	v_work_day_count int;
	v_expert_work_day_count int;
	v_office_id int;
	v_new_contract_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		v_ref = doc_flow_examinations_ref((SELECT doc_flow_examinations FROM doc_flow_examinations WHERE id=NEW.id));
		--статус
		INSERT INTO doc_flow_in_processes (
			doc_flow_in_id, date_time,
			state,
			register_doc,
			doc_flow_importance_type_id,
			description,
			end_date_time
		)
		VALUES (
			(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
			CASE WHEN NEW.closed THEN 'examined'::doc_flow_in_states ELSE 'examining'::doc_flow_in_states END,
			v_ref,
			NEW.doc_flow_importance_type_id,
			NEW.subject,
			NEW.end_date_time
		);
			
		--если тип основания - письмо, чье основание - заявление - сменим его статус
		IF NEW.subject_doc->>'dataType'='doc_flow_in' THEN
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(NEW.subject_doc->'keys'->>'id')::int;
			IF (v_application_id IS NOT NULL) THEN
				IF NEW.closed THEN
					SELECT
						greatest(NEW.date_time,date_time+'1 second'::interval)
					INTO v_app_process_dt
					FROM application_processes
					WHERE application_id=v_application_id
					ORDER BY date_time DESC
					LIMIT 1;
				ELSE
					v_app_process_dt = NEW.date_time;
				END IF;
				--статус
				INSERT INTO application_processes (
					application_id,
					date_time,
					state,
					user_id,
					end_date_time
				)
				VALUES (
					v_application_id,
					v_app_process_dt,
					CASE WHEN NEW.closed THEN NEW.application_resolution_state ELSE 'checking'::application_states END,
					(SELECT user_id FROM employees WHERE id=NEW.employee_id),
					NEW.end_date_time
				);			
			END IF;
		END IF;
			
		--задачи
		INSERT INTO doc_flow_tasks (
			register_doc,
			date_time,end_date_time,
			doc_flow_importance_type_id,
			employee_id,
			recipient,
			description,
			closed,
			close_doc,
			close_date_time,
			close_employee_id
		)
		VALUES (
			v_ref,
			NEW.date_time,NEW.end_date_time,
			NEW.doc_flow_importance_type_id,
			NEW.employee_id,
			NEW.recipient,
			NEW.subject,
			NEW.closed,
			CASE WHEN NEW.closed THEN v_ref ELSE NULL END,
			CASE WHEN NEW.closed THEN now() ELSE NULL END,
			CASE WHEN NEW.closed THEN NEW.close_employee_id ELSE NULL END
		);
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		v_ref = doc_flow_examinations_ref((SELECT doc_flow_examinations FROM doc_flow_examinations WHERE id=NEW.id));
		
		--state
		IF NEW.date_time<>OLD.date_time
			OR NEW.end_date_time<>OLD.end_date_time
			OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
			OR NEW.subject_doc<>OLD.subject_doc
			OR NEW.subject<>OLD.subject
			OR NEW.date_time<>OLD.date_time
			--OR (NEW.employee_id<>OLD.employee_id AND NEW.subject_doc->>'dataType'='doc_flow_in'
		THEN
			UPDATE doc_flow_in_processes
			SET
				date_time			= NEW.date_time,
				doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
				doc_flow_in_id			= (NEW.subject_doc->'keys'->>'id')::int,
				description			= NEW.subject,
				end_date_time			= NEW.end_date_time
			WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=NEW.id;
		END IF;
	
		--сменим статус при закрытии
		IF NEW.closed<>OLD.closed THEN
			INSERT INTO doc_flow_in_processes (
				doc_flow_in_id,
				date_time,
				state,
				register_doc,
				doc_flow_importance_type_id,
				end_date_time
			)
			VALUES (
				(NEW.subject_doc->'keys'->>'id')::int,
				CASE WHEN NEW.closed THEN NEW.close_date_time ELSE now() END,
				CASE WHEN NEW.closed THEN 'examined'::doc_flow_in_states ELSE 'examining'::doc_flow_in_states END,
				v_ref,
				NEW.doc_flow_importance_type_id,
				NEW.end_date_time
			);		
		END IF;
	
		--если тип основания - заявление - сменим его статус
		IF NEW.subject_doc->>'dataType'='doc_flow_in' AND NEW.closed<>OLD.closed AND NEW.closed THEN
			SELECT
				from_application_id,
				doc_flow_out.new_contract_number
			INTO
				v_application_id,
				v_new_contract_number
			FROM doc_flow_in
			LEFT JOIN doc_flow_out ON doc_flow_out.doc_flow_in_id=doc_flow_in.id
			WHERE doc_flow_in.id=(NEW.subject_doc->'keys'->>'id')::int;
			
			IF v_application_id IS NOT NULL THEN
				IF NEW.closed THEN
					SELECT
						greatest(NEW.close_date_time,date_time+'1 second'::interval)
					INTO v_app_process_dt
					FROM application_processes
					WHERE application_id=v_application_id
					ORDER BY date_time DESC
					LIMIT 1;
				ELSE
					v_app_process_dt = NEW.close_date_time;
				END IF;
			
				--статус
				INSERT INTO application_processes (
					application_id,
					date_time,
					state,
					user_id,
					end_date_time
				)
				VALUES (
					v_application_id,
					v_app_process_dt,
					CASE WHEN NEW.closed THEN NEW.application_resolution_state ELSE 'checking'::application_states END,
					(SELECT user_id FROM employees WHERE id=NEW.employee_id),
					CASE WHEN NEW.closed THEN NULL ELSE NEW.end_date_time END					
				);			
			END IF;
			
			--НОВЫЙ КОНТРАКТ
			IF NEW.application_resolution_state='waiting_for_contract' THEN
				SELECT
					app.expertise_type,
					app.cost_eval_validity,
					app.modification,
					app.audit,
					app.user_id,
					app.applicant,
					(contracts_ref(p_contr))::jsonb,
					(contracts_ref(mp_contr))::jsonb,
					coalesce(app.base_application_id,app.derived_application_id),
					app.cost_eval_validity_simult,
					app.constr_name,
					app.constr_address,
					app.constr_technical_features,
					CASE
						WHEN app.expertise_type IS NOT NULL THEN 'pd'::document_types
						WHEN app.cost_eval_validity THEN 'cost_eval_validity'::document_types
						WHEN app.modification THEN 'modification'::document_types
						WHEN app.audit THEN 'audit'::document_types						
					END,
					app.office_id
					
				INTO
					v_app_expertise_type,
					v_app_cost_eval_validity,
					v_app_modification,
					v_app_audit,
					v_app_user_id,
					v_app_applicant,
					v_primary_contracts_ref,
					v_modif_primary_contracts_ref,
					v_linked_app,
					v_cost_eval_validity_simult,
					v_constr_name,
					v_constr_address,
					v_constr_technical_features,
					v_document_type,
					v_office_id
					
				FROM applications AS app
				LEFT JOIN contracts AS p_contr ON p_contr.application_id=app.primary_application_id
				LEFT JOIN contracts AS mp_contr ON mp_contr.application_id=app.modif_primary_application_id
				WHERE app.id=v_application_id;
				
				--applicant -->> client
				UPDATE clients
				SET
					name		= v_app_applicant->>'name',
					name_full	= v_app_applicant->>'name_full',
					ogrn		= v_app_applicant->>'ogrn',
					inn		= v_app_applicant->>'inn',
					kpp		= v_app_applicant->>'kpp',
					okpo		= v_app_applicant->>'okpo',
					okved		= v_app_applicant->>'okved',
					post_address	= v_app_applicant->'post_address',
					user_id		= v_app_user_id,
					legal_address	= v_app_applicant->'legal_address',
					bank_accounts	= v_app_applicant->'bank_accounts',
					client_type	= (v_app_applicant->>'client_type')::client_types,
					base_document_for_contract = v_app_applicant->>'base_document_for_contract',
					person_id_paper	= v_app_applicant->'person_id_paper',
					person_registr_paper = v_app_applicant->'person_registr_paper'
				WHERE name = v_app_applicant->>'name' OR (inn=v_app_applicant->>'inn' AND kpp=v_app_applicant->>'kpp')
				RETURNING id INTO v_app_client_id;
				
				IF NOT FOUND THEN
					INSERT INTO clients
					(
						name,
						name_full,
						inn,
						kpp,
						ogrn,
						okpo,
						okved,
						post_address,
						user_id,
						legal_address,
						bank_accounts,
						client_type,
						base_document_for_contract,
						person_id_paper,
						person_registr_paper
					)
					VALUES(
						v_app_applicant->>'name',
						v_app_applicant->>'name_full',
						v_app_applicant->>'inn',
						v_app_applicant->>'kpp',
						v_app_applicant->>'ogrn',
						v_app_applicant->>'okpo',
						v_app_applicant->>'okved',
						v_app_applicant->'post_address',
						v_app_user_id,
						v_app_applicant->'legal_address',
						v_app_applicant->'bank_accounts',
						(v_app_applicant->>'client_type')::client_types,
						v_app_applicant->>'base_document_for_contract',
						v_app_applicant->'person_id_paper',
						v_app_applicant->'person_registr_paper'
					)				
					RETURNING id
					INTO v_app_client_id
					;
				END IF;
				
				v_linked_contracts_n = 0;
				IF (v_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					v_linked_contracts_n = v_linked_contracts_n + 1;
					v_linked_contracts = v_linked_contracts || jsonb_build_object('fields',jsonb_build_object('id',v_linked_contracts_n,'contracts_ref',v_primary_contracts_ref));
				END IF;
				IF (v_modif_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					v_linked_contracts_n = v_linked_contracts_n + 1;
					v_linked_contracts = v_linked_contracts || jsonb_build_object('fields',jsonb_build_object('id',v_linked_contracts_n,'contracts_ref',v_modif_primary_contracts_ref));
				END IF;
				
				IF v_linked_app IS NOT NULL THEN
					--Поиск связного контракта по заявлению
					SELECT contracts_ref(contracts) INTO v_linked_contracts_ref FROM contracts WHERE application_id=v_linked_app;
					IF v_linked_contracts_ref IS NOT NULL THEN
						v_linked_contracts_n = v_linked_contracts_n + 1;
						v_linked_contracts = v_linked_contracts || jsonb_build_object('fields',jsonb_build_object('id',v_linked_contracts_n,'contracts_ref',v_linked_contracts_ref));
					END IF;
				END IF;
				
				--Сначала из исх.письма, затем генерим новый
				IF v_new_contract_number IS NULL THEN
					v_new_contract_number = contracts_next_number(v_document_type,now()::date);
				END IF;
				
				--Номер экспертного заключения
				v_expertise_result_number = regexp_replace(v_new_contract_number,'\D+.*$','');
				v_expertise_result_number = substr('0000',1,4-length(v_expertise_result_number))||
							v_expertise_result_number||
							'/'||(extract(year FROM now())-2000)::text;
				
				--Дни проверки
				SELECT
					services.date_type,
					services.work_day_count,
					services.expertise_day_count
				INTO
					v_date_type,
					v_work_day_count,
					v_expert_work_day_count
				FROM services
				WHERE services.id=
				((
					CASE
						WHEN v_document_type='pd' THEN pdfn_services_expertise()
						WHEN v_document_type='cost_eval_validity' THEN pdfn_services_cost_eval_validity()
						WHEN v_document_type='modification' THEN pdfn_services_modification()
						WHEN v_document_type='audit' THEN pdfn_services_audit()
						ELSE NULL
					END
				)->'keys'->>'id')::int;
								
				--RAISE EXCEPTION 'v_linked_contracts=%',v_linked_contracts;
				--Контракт
				INSERT INTO contracts (
					date_time,
					application_id,
					client_id,
					employee_id,
					document_type,
					expertise_type,
					cost_eval_validity_pd_order,
					constr_name,
					constr_address,
					constr_technical_features,
					contract_number,
					expertise_result_number,
					linked_contracts,
					--contract_date,					
					date_type,
					expertise_day_count,
					expert_work_day_count,
					work_end_date,
					expert_work_end_date,
					permissions,
					user_id)
				VALUES (
					now(),
					v_application_id,
					v_app_client_id,
					NEW.close_employee_id,
					v_document_type,
					v_app_expertise_type,
					CASE
						WHEN v_app_cost_eval_validity THEN
							CASE
								WHEN v_cost_eval_validity_simult THEN 'simult_with_pd'::cost_eval_validity_pd_orders
								WHEN v_linked_app IS NOT NULL THEN 'after_pd'::cost_eval_validity_pd_orders
								ELSE 'no_pd'::cost_eval_validity_pd_orders
							END
						ELSE NULL
					END,
					v_constr_name,
					v_constr_address,
					v_constr_technical_features,
					
					v_new_contract_number,
					v_expertise_result_number,
					
					--linked_contracts
					CASE WHEN v_linked_contracts IS NOT NULL THEN
						jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',v_linked_contracts
						)
					ELSE
						'{"id":"LinkedContractList_Model","rows":[]}'::jsonb
					END,
					
					--now()::date,--contract_date
					
					v_date_type,
					v_work_day_count,
					v_expert_work_day_count,
					
					--ПРИ ОПЛАТЕ client_payments_process()
					--ставятся work_start_date&&work_end_date
					--contracts_work_end_date(v_office_id, v_date_type, now(), v_work_day_count),
					NULL,
					NULL,					
					
					'{"id":"AccessPermission_Model","rows":[]}'::jsonb,
					
					v_app_user_id
				)
				RETURNING id INTO v_new_contract_id;
				
				--В связные контракты запишем данный по текущему новому
				IF (v_linked_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
				--RAISE EXCEPTION 'Updating contracts, id=%',(v_linked_contracts_ref->'keys'->>'id')::int;
					UPDATE contracts
					SET
						linked_contracts = jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',
							linked_contracts->'rows'||
								jsonb_build_object(
								'fields',jsonb_build_object(
									'id',
									jsonb_array_length(linked_contracts->'rows')+1,
									'contracts_ref',contracts_ref((SELECT contracts FROM contracts WHERE id=v_new_contract_id))
									)
								)							
						)
					WHERE id=(v_linked_contracts_ref->'keys'->>'id')::int;
				END IF;
				IF (v_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					UPDATE contracts
					SET
						linked_contracts = jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',
							linked_contracts->'rows'||
								jsonb_build_object(
								'fields',jsonb_build_object(
									'id',
									jsonb_array_length(linked_contracts->'rows')+1,
									'contracts_ref',contracts_ref((SELECT contracts FROM contracts WHERE id=v_new_contract_id))
									)
								)							
						)
					WHERE id=(v_primary_contracts_ref->'keys'->>'id')::int;
				END IF;
				IF (v_modif_primary_contracts_ref->'keys'->>'id' IS NOT NULL) THEN
					UPDATE contracts
					SET
						linked_contracts = jsonb_build_object(
							'id','LinkedContractList_Model',
							'rows',
							linked_contracts->'rows'||
								jsonb_build_object(
								'fields',jsonb_build_object(
									'id',
									jsonb_array_length(linked_contracts->'rows')+1,
									'contracts_ref',contracts_ref((SELECT contracts FROM contracts WHERE id=v_new_contract_id))
									)
								)							
						)
					WHERE id=(v_modif_primary_contracts_ref->'keys'->>'id')::int;
				END IF;
				
			END IF;
		END IF;
						
		--задачи
		UPDATE doc_flow_tasks
		SET 
			date_time			= NEW.date_time,
			end_date_time			= NEW.end_date_time,
			doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
			employee_id			= NEW.employee_id,
			description			= NEW.subject,
			closed				= NEW.closed,
			close_doc			= CASE WHEN NEW.closed THEN v_ref ELSE NULL END,
			close_date_time			= CASE WHEN NEW.closed THEN now() ELSE NULL END,
			close_employee_id		= CASE WHEN NEW.closed THEN NEW.close_employee_id ELSE NULL END
		WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		--статус
		--DELETE FROM doc_flow_in_processes WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
		--задачи
		--DELETE FROM doc_flow_tasks WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--статус
		DELETE FROM doc_flow_in_processes WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=OLD.id;
		--задачи
		DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_examinations' AND (register_doc->'keys'->>'id')::int=OLD.id;
		IF (OLD.subject_doc->>'dataType')::data_types='doc_flow_in'::data_types THEN
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(OLD.subject_doc->'keys'->>'id')::int;
			IF v_application_id IS NOT NULL THEN
				DELETE FROM application_processes WHERE doc_flow_examination_id=OLD.id;
			END IF;
		END IF;
											
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_examinations_process() OWNER TO expert72;
