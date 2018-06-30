-- ******************* update 29/06/2018 08:37:09 ******************

		ALTER TABLE contracts ADD COLUMN result_sign_expert_list jsonb;


-- ******************* update 29/06/2018 08:37:47 ******************
-- VIEW: contracts_dialog

--DROP VIEW contracts_dialog;

CREATE OR REPLACE VIEW contracts_dialog AS
	SELECT
		t.id,
		t.date_time,		
		employees_ref(employees) AS employees_ref,
		t.reg_number,
		t.expertise_type,
		t.document_type,
		t.expertise_result_number,
		
		--applications
		app.applications_ref,
		applications_client_descr(app.applicant) AS applicant_descr,
		applications_client_descr(app.customer) AS customer_descr,
		applications_client_descr(app.developer) AS developer_descr,
		
		(SELECT
			json_build_object(
				'id','ContractorList_Model',
				'rows',json_build_array(
					json_build_object(
						'fields',
						json_build_object(
							'name',
							sub.contractors->>'name'||
							coalesce(' '||(sub.contractors->>'inn')::text,'')||
							coalesce('/'||(sub.contractors->>'kpp')::text,'')
						)
					)
				)
			)
		FROM (
			SELECT
				jsonb_array_elements(contractors) AS contractors
			FROM applications app_contr WHERE app_contr.id=app.id
		) AS sub		
		)
		AS contractors_list,
		
		app.construction_types_ref,
		t.constr_name AS constr_name,
		--kladr_parse_addr(t.constr_address) AS constr_address,
		t.constr_address,
		t.constr_technical_features,
		t.constr_technical_features_in_compound_obj,
		app.total_cost_eval,
		app.limit_cost_eval,
		app.build_types_ref,
		app.cost_eval_validity_simult,
		app.fund_sources_ref,
		app.primary_application_reg_number AS primary_contract_reg_number,
		app.modif_primary_application_reg_number AS modif_primary_contract_reg_number,
		contracts_ref(prim_contr) AS primary_contracts_ref,
		contracts_ref(modif_prim_contr) AS modif_primary_contracts_ref,
		app.cost_eval_validity,
		app.modification,
		app.audit,
		app.documents,
		--***********************
		
		t.contract_number,
		t.contract_date,		
		t.expertise_cost_budget,
		t.expertise_cost_self_fund,
		
		t.work_start_date,
		t.work_end_date,
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,
		t.expertise_day_count,
		t.kadastr_number,
		t.grad_plan_number,
		t.area_document,
		t.expertise_result,
		t.expertise_result_date,
		
		t.comment_text,
		
		expertise_reject_types_ref(rt) AS expertise_reject_types_ref,		
		
		departments_ref(dp) AS main_departments_ref,
		employees_ref(exp_empl) AS main_experts_ref,
		
		t.permissions,
		
		(
			SELECT
				json_agg(sec_rows.sec_data)
			FROM (
				SELECT
					json_build_object(
						'section_id',sec.section_id,
						'section_name',sec.section_name,
						'experts_list',(
							SELECT string_agg(sub.name||'('||
								CASE WHEN EXTRACT(DAY FROM sub.d)<10 THEN '0'||EXTRACT(DAY FROM sub.d)::text ELSE EXTRACT(DAY FROM sub.d)::text END ||
								'/'||
								CASE WHEN EXTRACT(MONTH FROM sub.d)<10 THEN '0'||EXTRACT(MONTH FROM sub.d)::text ELSE EXTRACT(MONTH FROM sub.d)::text END ||	
							')',',')
							FROM (
							SELECT person_init(employees.name,FALSE) AS name,max(expert_works.date_time)::date AS d
							FROM expert_works
							LEFT JOIN employees ON employees.id=expert_works.expert_id
							WHERE contract_id=t.id AND section_id=sec.section_id
							GROUP BY employees.name
							) AS sub	
						)
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				)
				ORDER BY sec.section_index				
			) AS sec_rows
		) AS expertise_sections,
		
		t.application_id,
		
		t.contract_ext_id,
		
		t.contract_return_date,
		
		t.linked_contracts,
		
		t.cost_eval_validity_pd_order,
		t.date_type,
		t.argument_document,
		t.order_document,
		app.auth_letter,
		
		t.expert_work_day_count,
		t.expert_work_end_date,
		
		app.doc_folders,
		
		t.for_all_employees,
		t.in_estim_cost,
		t.in_estim_cost_recommend,
		t.cur_estim_cost,
		t.cur_estim_cost_recommend,
		
		t.result_sign_expert_list
		
	FROM contracts t
	LEFT JOIN applications_dialog AS app ON app.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN expertise_reject_types AS rt ON rt.id=t.expertise_reject_type_id
	LEFT JOIN departments AS dp ON dp.id=t.main_department_id
	LEFT JOIN employees AS exp_empl ON exp_empl.id=t.main_expert_id
	LEFT JOIN contracts AS prim_contr ON prim_contr.id=t.primary_contract_id
	LEFT JOIN contracts AS modif_prim_contr ON modif_prim_contr.id=t.modif_primary_contract_id
	LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;

-- ******************* update 29/06/2018 09:06:52 ******************
-- VIEW: client_list

DROP VIEW user_list;

CREATE OR REPLACE VIEW user_list AS
	SELECT
		users.id,
		users.name,
		users.name_full,
		users.email,
		phone_cel,
		users.role_id,
		users.create_dt
	FROM users
	ORDER BY users.name
	;
	
ALTER VIEW user_list OWNER TO expert72;

-- ******************* update 29/06/2018 10:07:02 ******************

					ALTER TYPE application_states ADD VALUE 'correcting';
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
		WHEN $1='closed'::application_states AND $2='ru'::locales THEN 'Заключение'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_application_states_val(application_states,locales) OWNER TO expert72;		
		
-- ******************* update 29/06/2018 10:30:54 ******************
-- Function: application_corrections_process()

-- DROP FUNCTION application_corrections_process();

CREATE OR REPLACE FUNCTION application_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
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
ALTER FUNCTION application_corrections_process() OWNER TO expert72;


-- ******************* update 29/06/2018 10:55:05 ******************
-- Trigger: application_corrections_after_trigger on application_corrections

-- DROP TRIGGER application_corrections_after_trigger ON application_corrections;

 CREATE TRIGGER application_corrections_after_trigger
  AFTER INSERT
  ON application_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE application_corrections_process();

-- ******************* update 29/06/2018 11:34:44 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	application_state application_states;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				IF v_application_state = 'correction' THEN
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				SELECT
					st.state
				INTO
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;

				IF v_application_state <> 'correction' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 11:34:52 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				IF v_application_state = 'correction' THEN
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				SELECT
					st.state
				INTO
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;

				IF v_application_state <> 'correction' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 11:55:56 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.state_date
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				IF v_application_state = 'correction' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				SELECT
					st.state
				INTO
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;

				IF v_application_state <> 'correction' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:07:19 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				IF v_application_state = 'correction' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				SELECT
					st.state
				INTO
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;

				IF v_application_state <> 'correction' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:07:55 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				SELECT
					st.state
				INTO
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;

				IF v_application_state <> 'correction' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:08:36 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				SELECT
					st.state
				INTO
					v_application_state
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;

				IF v_application_state <> 'correcting' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:10:35 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state <> 'correcting' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:15:08 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state <> 'correcting' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:15:32 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state <> 'correcting' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:15:46 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state <> 'correcting' THEN		
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:24:17 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						now()+'1 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:26:28 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						now()+'2 seconds'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:28:09 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state,
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'1 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:28:19 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'1 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:31:09 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'client_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						(NEW.date_time+'1 second'::interval),
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:34:05 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				RAISE EXCEPTION 'NEW.date_time=%',NEW.date_time;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'1 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:36:48 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'1 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:38:57 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					/*
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'1 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
					*/
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:43:07 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					/*
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'10 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
					*/
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 12:43:42 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'10 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
					
				ELSE
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 13:21:20 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' OR NEW.state='checking' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF NEW.state='sent' const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				/*
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'10 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
					
				ELSE
				*/
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				--END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 13:21:29 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' OR NEW.state='checking' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF NEW.state='sent' OR const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				/*
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'10 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
					
				ELSE
				*/
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				--END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 13:59:38 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' OR NEW.state='checking' THEN
		
			--Предыдущий статус заявления
			
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					d.applicant,
					d.customer,
					d.contractors,
					st.state,
					st.date_time
				INTO
					v_applicant,
					v_customer,
					v_contractors,
					v_application_state,
					v_application_state_dt
				FROM applications AS d
				LEFT JOIN (
					SELECT
						t.application_id,
						max(t.date_time) AS date_time
					FROM application_processes t
					WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
					GROUP BY t.application_id
				) AS h_max ON h_max.application_id=d.id
				LEFT JOIN application_processes st
					ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
				WHERE d.id = NEW.application_id;
		
				--*** Contacts ***************
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
				DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
			
				PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
			
				PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

				ind = 0;
				FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
				LOOP
					PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
					ind = ind+ 1;
				END LOOP;
				--*** Contacts ***************
			
				-- Если отправка из статуса correcting то уведомление отедлу приема
				--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
				IF v_application_state = 'correcting' THEN
					--все поля из рассмотрения, которое должно быть с прошлой отправки
					INSERT INTO doc_flow_tasks (
						register_doc,
						date_time,end_date_time,
						doc_flow_importance_type_id,
						employee_id,
						recipient,
						description
					)
					(SELECT
						doc_flow_examinations_ref(ex),
						now(),ex.end_date_time,
						ex.doc_flow_importance_type_id,
						ex.employee_id,
						ex.recipient,
						'Исправление по заявлению '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
				END IF;
			END IF;
			
			IF NEW.state='sent' OR const_client_lk_val() OR const_debug_val() THEN			
				--client lk
				/*
				IF v_application_state IS NULL THEN
					SELECT
						st.state
					INTO
						v_application_state
					FROM applications AS d
					LEFT JOIN (
						SELECT
							t.application_id,
							max(t.date_time) AS date_time
						FROM application_processes t
						WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
						GROUP BY t.application_id
					) AS h_max ON h_max.application_id=d.id
					LEFT JOIN application_processes st
						ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
					WHERE d.id = NEW.application_id;
				END IF;
				--RAISE EXCEPTION 'NEW.date_time=%,%',NEW.date_time,NEW.date_time+'1 second'::interval;
				IF v_application_state = 'correcting' THEN		
					--В этом случае сами переводим app в статус checking
					
					INSERT INTO application_processes
					(application_id,date_time,state,user_id,end_date_time,doc_flow_examination_id)
					(SELECT
						NEW.application_id,
						NEW.date_time+'10 second'::interval,
						'checking',
						(SELECT user_id FROM employees WHERE id=ex.employee_id),
						ex.end_date_time,
						ex.id
					FROM doc_flow_examinations ex
					LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
					LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
					WHERE doc_flow_in.from_application_id=NEW.application_id
					)
					;
					
				ELSE
				*/
					--Делаем исх. письмо клиента. ТОЛЬКО ЕСЛИ первый sent
					--В заявлении только одна услуга
					INSERT INTO doc_flow_out_client (
						date_time,
						user_id,
						application_id,
						subject,
						content,
						sent
					)
					(SELECT 
						now(),
						app.user_id,
						NEW.application_id,
						'Новое заявление: '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
							WHEN app.cost_eval_validity THEN 'Достоверность'
							WHEN app.modification THEN 'Модификация'
							WHEN app.audit THEN 'Аудит'
						END||', '||app.constr_name
						,
						app.applicant->>'name'||' просит провести '||
						CASE
							WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
							WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
							WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
							WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
							WHEN app.modification THEN 'модификацию.'
							WHEN app.audit THEN 'аудит'
						END||' по объекту '||app.constr_name
						,
						TRUE
					
					FROM applications AS app
					WHERE app.id = NEW.application_id
					);
				--END IF;	
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 14:12:35 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (OR const_client_lk_val() OR const_debug_val()) THEN
				--client lk
				--Делаем исх. письмо клиента.
				--В заявлении только одна услуга
				INSERT INTO doc_flow_out_client (
					date_time,
					user_id,
					application_id,
					subject,
					content,
					sent
				)
				(SELECT 
					now(),
					app.user_id,
					NEW.application_id,
					'Новое заявление: '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name
					,
					app.applicant->>'name'||' просит провести '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
						WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
						WHEN app.modification THEN 'модификацию.'
						WHEN app.audit THEN 'аудит'
					END||' по объекту '||app.constr_name
					,
					TRUE
				
				FROM applications AS app
				WHERE app.id = NEW.application_id
				LIMIT 1
				--Вдруг как то пролезли 2 услуги???
				);
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 14:12:45 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
				--client lk
				--Делаем исх. письмо клиента.
				--В заявлении только одна услуга
				INSERT INTO doc_flow_out_client (
					date_time,
					user_id,
					application_id,
					subject,
					content,
					sent
				)
				(SELECT 
					now(),
					app.user_id,
					NEW.application_id,
					'Новое заявление: '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name
					,
					app.applicant->>'name'||' просит провести '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
						WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
						WHEN app.modification THEN 'модификацию.'
						WHEN app.audit THEN 'аудит'
					END||' по объекту '||app.constr_name
					,
					TRUE
				
				FROM applications AS app
				WHERE app.id = NEW.application_id
				LIMIT 1
				--Вдруг как то пролезли 2 услуги???
				);
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 14:12:54 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
				--client lk
				--Делаем исх. письмо клиента.
				--В заявлении только одна услуга
				INSERT INTO doc_flow_out_client (
					date_time,
					user_id,
					application_id,
					subject,
					content,
					sent
				)
				(SELECT 
					now(),
					app.user_id,
					NEW.application_id,
					'Новое заявление: '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name
					,
					app.applicant->>'name'||' просит провести '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
						WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
						WHEN app.modification THEN 'модификацию.'
						WHEN app.audit THEN 'аудит'
					END||' по объекту '||app.constr_name
					,
					TRUE
				
				FROM applications AS app
				WHERE app.id = NEW.application_id
				LIMIT 1
				--Вдруг как то пролезли 2 услуги???
				);
			END IF;
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 14:13:12 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 15:40:00 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	raise exception '%',NEW.state;
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 15:40:37 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	raise exception 'STATE=%',NEW.state;
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 15:42:53 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 29/06/2018 16:59:27 ******************
﻿-- Function: contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int)

-- DROP FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int);

CREATE OR REPLACE FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int)
  RETURNS date AS
$$
	SELECT
		CASE
			WHEN in_date_type='bank'::date_types THEN
				(SELECT d2::date FROM applications_check_period(in_office_id,in_date_time,in_days+1) AS (d1 timestampTZ,d2 timestampTZ))
			ELSE (SELECT d2::date FROM applications_check_period(in_office_id,in_date_time::date+((in_days-1)||' days')::interval,1) AS (d1 timestampTZ,d2 timestampTZ))
		END	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_work_end_date(in_office_id int,in_date_type date_types, in_date_time timestampTZ, in_days int) OWNER TO expert72;

-- ******************* update 30/06/2018 06:33:32 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отедлу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				doc_flow_out_client_type,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				'app',
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;