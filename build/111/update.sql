
-- ******************* update 18/08/2020 10:25:13 ******************
-- VIEW: clients_dialog

--DROP VIEW clients_dialog;

CREATE OR REPLACE VIEW clients_dialog AS
	SELECT
		clients.*,
		contacts_get_persons(clients.id,'clients') AS responsable_persons
	FROM clients
	;
	
ALTER VIEW clients_dialog OWNER TO expert72;


-- ******************* update 18/08/2020 10:26:32 ******************

		ALTER TABLE users ADD COLUMN allow_ext_contracts bool
			DEFAULT FALSE;



-- ******************* update 18/08/2020 10:27:29 ******************
-- VIEW: user_dialog

DROP VIEW user_dialog;

CREATE OR REPLACE VIEW user_dialog AS
	SELECT
		users.id,
		users.name,
		users.name_full,
		users.banned,
		users.email,
		users.role_id,
		time_zone_locales_ref(time_zone_locales) AS time_zone_locales_ref,
		users.phone_cel,
		users.color_palette,
		users.reminders_to_email,
		users.private_file,
		users.allow_ext_contracts
		
	FROM users
	LEFT JOIN time_zone_locales ON time_zone_locales.id=users.time_zone_locale_id
	;
	
ALTER VIEW user_dialog OWNER TO expert72;


-- ******************* update 18/08/2020 10:32:37 ******************
-- VIEW: user_view

DROP VIEW user_view;

CREATE OR REPLACE VIEW user_view AS
	SELECT
		u.*,
		tzl.name AS user_time_locale,
		employees_ref(emp) AS employees_ref,
		departments_ref(dep) AS departments_ref,
		(emp.id=dep.boss_employee_id) department_boss,
		
		CASE WHEN st.id IS NULL THEN pdfn_short_message_recipient_states_free()
		ELSE short_message_recipient_states_ref(st)
		END AS recipient_states_ref,
		
		(u.private_pem IS NOT NULL AND u.private_file IS NOT NULL) AS cloud_key_exists,
		emp.snils
		
	FROM users u
	LEFT JOIN time_zone_locales tzl ON tzl.id=u.time_zone_locale_id
	LEFT JOIN employees emp ON emp.user_id=u.id
	LEFT JOIN departments dep ON dep.id=emp.department_id
	LEFT JOIN short_message_recipient_current_states cur_st ON cur_st.recipient_id=emp.id
	LEFT JOIN short_message_recipient_states st ON st.id=cur_st.recipient_state_id
	;
	
ALTER VIEW user_view OWNER TO expert72;


-- ******************* update 18/08/2020 10:42:02 ******************

		ALTER TABLE applications ADD COLUMN ext_contract bool
			DEFAULT FALSE;
	


-- ******************* update 18/08/2020 10:43:05 ******************
-- VIEW: applications_list

DROP VIEW applications_list;

CREATE OR REPLACE VIEW applications_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
			ELSE ''
			END
		) AS service_list,
		
		(
		SELECT json_agg(doc_flow_in_client_ref(in_docs))
		FROM doc_flow_in_client AS in_docs
		WHERE in_docs.application_id=l.id AND NOT coalesce(in_docs.viewed,FALSE)
		) AS unviewed_in_docs,
		
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		l.base_application_id
				
	FROM applications AS l
	LEFT JOIN offices_list AS off ON off.id=l.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=l.id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=l.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = FALSE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 18/08/2020 10:45:35 ******************
-- VIEW: applications_ext_list

--DROP VIEW applications_ext_list;

CREATE OR REPLACE VIEW applications_ext_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
			ELSE ''
			END
		) AS service_list,
		
		(
		SELECT json_agg(doc_flow_in_client_ref(in_docs))
		FROM doc_flow_in_client AS in_docs
		WHERE in_docs.application_id=l.id AND NOT coalesce(in_docs.viewed,FALSE)
		) AS unviewed_in_docs,
		
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		l.base_application_id
				
	FROM applications AS l
	LEFT JOIN offices_list AS off ON off.id=l.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=l.id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=l.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = TRUE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_ext_list OWNER TO expert72;



-- ******************* update 18/08/2020 11:08:24 ******************

	-- Adding menu item
	INSERT INTO views
	(id,c,f,t,section,descr,limited)
	VALUES (
	'20020',
	'Application_Controller',
	'get_ext_list',
	'ApplicationExtList',
	'Документы',
	'Заявления (внеконтрактные)',
	FALSE
	);
	

-- ******************* update 18/08/2020 13:22:16 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(NEW.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(NEW.ext_contract,FALSE) THEN ' (внеконтрактное) ' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
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



-- ******************* update 18/08/2020 13:22:26 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(NEW.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(NEW.ext_contract,FALSE) THEN ' (внеконтрактное)' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
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



-- ******************* update 18/08/2020 14:11:20 ******************

		ALTER TABLE doc_flow_in ADD COLUMN ext_contract bool;



-- ******************* update 18/08/2020 14:11:58 ******************

		ALTER TABLE doc_flow_in DROP COLUMN ext_contract;



-- ******************* update 18/08/2020 14:12:09 ******************

		ALTER TABLE doc_flow_in ADD COLUMN ext_contract bool DEFAULT FALSE;



-- ******************* update 18/08/2020 14:13:56 ******************
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
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
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
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = enum_doc_flow_out_client_types_val(NEW.doc_flow_out_client_type,'ru');
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
				corrected_sections,
				ext_contract
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
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
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
					WHERE fld.obj->>'dataType'='employees'
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



-- ******************* update 18/08/2020 14:31:05 ******************
﻿-- Function: doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool)

-- DROP FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool);

CREATE OR REPLACE FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool)
  RETURNS text AS
$$
	WITH
		pref AS (
			SELECT
				num_prefix||
				CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END
				AS n
			FROM doc_flow_types
			WHERE id = in_doc_flow_type_id
		)
	SELECT
		(SELECT n FROM pref) || (coalesce(max(substr(reg_number,length((SELECT n FROM pref))+1)::int),0)+1)::text
	FROM doc_flow_in
	WHERE substr(reg_number,1,length((SELECT n FROM pref)))=(SELECT n FROM pref)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool) OWNER TO expert72;


-- ******************* update 18/08/2020 14:31:08 ******************
-- Function: doc_flow_in_process()

-- DROP FUNCTION doc_flow_in_process();

CREATE OR REPLACE FUNCTION doc_flow_in_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF
			(NOT const_client_lk_val() OR const_debug_val())
			AND NEW.reg_number IS NULL
			AND (
				--ЛЮБОЕ ОТ КЛИЕНТА
				--doc_flow_type_id=1 OR NEW.doc_flow_type_id=3
				NEW.from_application_id IS NOT NULL
			)
		THEN
			--назначим номер
			NEW.reg_number = doc_flow_in_next_num(NEW.doc_flow_type_id,coalesce(NEW.ext_contract,FALSE));
		END IF;
		
		RETURN NEW;

	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		IF (NOT const_client_lk_val() OR const_debug_val()) THEN
			DELETE FROM doc_flow_in_processes WHERE doc_flow_in_id = OLD.id;
			DELETE FROM doc_flow_out WHERE doc_flow_in_id = OLD.id;
			DELETE FROM doc_flow_attachments WHERE doc_type='doc_flow_in' AND doc_id = OLD.id;
		END IF;

		IF (const_client_lk_val() OR const_debug_val()) THEN
			UPDATE doc_flow_out_client
			SET sent = FALSE
			WHERE id = OLD.from_doc_flow_out_client_id;

		END IF;
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_process() OWNER TO expert72;



-- ******************* update 18/08/2020 14:32:30 ******************
-- VIEW: doc_flow_in_list

--DROP VIEW doc_flow_in_list;

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
		) AS corrected_sections,
		
		doc_flow_in.ext_contract
		
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


-- ******************* update 18/08/2020 14:36:44 ******************
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
	
	WHERE coalesce(doc_flow_in.ext_contract,FALSE) = FALSE
	
	ORDER BY doc_flow_in.date_time DESC
	;
	
ALTER VIEW doc_flow_in_list OWNER TO expert72;


-- ******************* update 18/08/2020 14:37:52 ******************
-- VIEW: doc_flow_in_ext_list

--DROP VIEW doc_flow_in_ext_list;

CREATE OR REPLACE VIEW doc_flow_in_ext_list AS
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
	
	WHERE coalesce(doc_flow_in.ext_contract,FALSE) = TRUE
	
	ORDER BY doc_flow_in.date_time DESC
	;
	
ALTER VIEW doc_flow_in_ext_list OWNER TO expert72;


-- ******************* update 18/08/2020 14:39:09 ******************
-- VIEW: doc_flow_in_ext_list

--DROP VIEW doc_flow_in_ext_list;

CREATE OR REPLACE VIEW doc_flow_in_ext_list AS
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
	
	WHERE coalesce(doc_flow_in.ext_contract,FALSE) = TRUE
	
	ORDER BY doc_flow_in.date_time DESC
	;
	
ALTER VIEW doc_flow_in_ext_list OWNER TO expert72;


-- ******************* update 18/08/2020 14:48:21 ******************

	-- Adding menu item
	INSERT INTO views
	(id,c,f,t,section,descr,limited)
	VALUES (
	'20021',
	'DocFlowIn_Controller',
	'get_ext_list',
	'DocFlowInExtList',
	'Документы',
	'Входяшие документы (внеконтракт)',
	FALSE
	);
	

-- ******************* update 19/08/2020 05:50:13 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактное)' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
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



-- ******************* update 19/08/2020 06:00:08 ******************
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
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
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
					', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = enum_doc_flow_out_client_types_val(NEW.doc_flow_out_client_type,'ru')||
					CASE WHEN v_ext_contract THEN ' (внеконтракт)' ELSE '' END;
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
				corrected_sections,
				ext_contract
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
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
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
					WHERE fld.obj->>'dataType'='employees'
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



-- ******************* update 19/08/2020 06:04:30 ******************
--DROP FUNCTION applications_ref(applications)

--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT 
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Заявление '||
				CASE WHEN coalesce($1.ext_contract,FALSE)=TRUE THEN '(внеконтракт) ' ELSE '' END||
				'№'||$1.id||' от '||to_char($1.create_dt,'DD/MM/YY'),
			'dataType','applications'
		)
	;
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO expert72;	



-- ******************* update 19/08/2020 06:08:30 ******************

		ALTER TABLE doc_flow_out ADD COLUMN ext_contract bool
			DEFAULT FALSE;



-- ******************* update 19/08/2020 06:12:52 ******************
-- VIEW: doc_flow_out_dialog

DROP VIEW doc_flow_out_dialog;

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
					'signatures',
					(WITH sign AS
					(SELECT
						json_agg(files_t.signatures) AS signatures
					FROM
						(SELECT
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
						WHERE f_sig.file_id=f_ver.file_id
						ORDER BY f_sig.sign_date_time
						) AS files_t
					)					
					SELECT
						CASE
							WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
								json_build_array(
									json_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE (SELECT sign.signatures FROM sign)
						END
					),
					'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id),
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
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
		expertise_reject_types.id AS expertise_reject_type_id,
		
		employees_ref(employees3) AS to_contract_main_experts_ref
		
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
	LEFT JOIN employees AS employees3 ON employees3.id=contracts.main_expert_id
	
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


-- ******************* update 19/08/2020 06:14:37 ******************
-- VIEW: doc_flow_examinations_dialog

--DROP VIEW doc_flow_examinations_dialog;

CREATE OR REPLACE VIEW doc_flow_examinations_dialog AS
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
		
		t.description,
		
		t.resolution,
		t.close_date_time,
		t.closed,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		t.application_resolution_state,
		doc_flow_in.from_client_app AS application_based,
		
		employees_ref(close_empl) AS close_employees_ref,
		t.close_employee_id,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain,
		
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		applications_ref(applications) AS applications_ref,
		
		applications.service_type AS application_service_type,
		applications.ext_contract AS application_ext_contract
		
		
	FROM doc_flow_examinations AS t
	LEFT JOIN doc_flow_in ON doc_flow_in.id = (t.subject_doc->'keys'->>'id')::int AND t.subject_doc->>'dataType'='doc_flow_in'
	LEFT JOIN applications ON applications.id = doc_flow_in.from_application_id
	LEFT JOIN doc_flow_out ON doc_flow_out.doc_flow_in_id = doc_flow_in.id
	--LEFT JOIN doc_flow_inside ON doc_flow_in.id = t.subject_doc_id AND t.subject_doc_type='doc_flow_inside'::data_types
	LEFT JOIN doc_flow_importance_types ON doc_flow_importance_types.id=t.doc_flow_importance_type_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS close_empl ON close_empl.id=t.close_employee_id
	LEFT JOIN departments ON departments.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (t.recipient->'keys'->>'id')::int AND t.recipient->>'dataType'='employees'
	
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
	
ALTER VIEW doc_flow_examinations_dialog OWNER TO expert72;


-- ******************* update 19/08/2020 07:01:16 ******************
﻿-- Function: doc_flow_out_next_num(in_doc_flow_type_id int, in_ext_contract bool)

-- DROP FUNCTION doc_flow_out_next_num(in_doc_flow_type_id int, in_ext_contract bool);

CREATE OR REPLACE FUNCTION doc_flow_out_next_num(in_doc_flow_type_id int, in_ext_contract bool)
  RETURNS text AS
$$
	WITH
		pref AS (
			SELECT
				num_prefix||
					CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END
				AS n
			FROM doc_flow_types
			WHERE id = in_doc_flow_type_id
		)
	SELECT
		(SELECT n FROM pref) || (coalesce(max(
			REGEXP_REPLACE(substr(reg_number,length((SELECT n FROM pref))+1), '[^0-9]+', '', 'g') ::int),
			0)+1)::text
	FROM doc_flow_out
	WHERE substr(reg_number,1,length((SELECT n FROM pref)))=(SELECT n FROM pref)
	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_next_num(in_doc_flow_type_id int, in_ext_contract bool) OWNER TO expert72;


-- ******************* update 19/08/2020 09:14:12 ******************
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
						'files',
						(SELECT
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
									'file_path',app_f.file_path,
									'is_switched',(clorg_f.new_file_id IS NOT NULL),
									'deleted',coalesce(app_f.deleted,FALSE),
									'signatures',
									(SELECT
										json_agg(sub.signatures) AS signatures
									FROM (
										SELECT 
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
										WHERE f_sig.file_id=t.file_id
										ORDER BY f_sig.sign_date_time
									) AS sub
									)
								) AS attachments
							FROM doc_flow_out_client_document_files AS t
							LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
							LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
							LEFT JOIN doc_flow_out_client_original_files AS clorg_f ON clorg_f.doc_flow_out_client_id=t.doc_flow_out_client_id AND clorg_f.new_file_id=t.file_id
							WHERE
								--coalesce(app_f.deleted,FALSE)=FALSE
								--AND
								t.doc_flow_out_client_id=doc_flow_in.from_doc_flow_out_client_id
								AND app_f.file_id IS NOT NULL
							ORDER BY app_f.file_path,app_f.file_name
							) AS files_t
						)
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',
						(SELECT
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
						WHERE t.doc_type='doc_flow_in'::data_types AND t.doc_id=doc_flow_in.id
						)		
						
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
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;


-- ******************* update 19/08/2020 09:48:03 ******************
﻿-- Function: contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool);

-- с 19/08/20 функция имеет 3 параметра, + in_ext_contract bool
CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)
  RETURNS text AS
$$
	SELECT
		CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END||
		coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool) OWNER TO expert72;


-- ******************* update 19/08/2020 09:50:54 ******************
﻿-- Function: contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool);

-- с 19/08/20 функция имеет 3 параметра, + in_ext_contract bool
CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)
  RETURNS text AS
$$
	SELECT
		CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END||
		coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
		AND NOT in_ext_contract OR app.ext_contract=TRUE
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool) OWNER TO expert72;


-- ******************* update 19/08/2020 09:51:28 ******************
﻿-- Function: contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool);

-- с 19/08/20 функция имеет 3 параметра, + in_ext_contract bool
CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)
  RETURNS text AS
$$
	SELECT
		CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END||
		coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
		AND (NOT in_ext_contract OR app.ext_contract=TRUE)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool) OWNER TO expert72;


-- ******************* update 19/08/2020 09:52:41 ******************
﻿-- Function: contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool);

-- с 19/08/20 функция имеет 3 параметра, + in_ext_contract bool
CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)
  RETURNS text AS
$$
	SELECT
		CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END||
		coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
		AND (
			(in_ext_contract=FALSE AND coalesce(app.ext_contract,FALSE)=FALSE)
			OR (in_ext_contract AND coalesce(app.ext_contract,FALSE))
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool) OWNER TO expert72;


-- ******************* update 19/08/2020 12:31:17 ******************
-- VIEW: doc_flow_out_list

--DROP VIEW doc_flow_out_list;

CREATE OR REPLACE VIEW doc_flow_out_list AS
	SELECT
		doc_flow_out.id,
		doc_flow_out.date_time,
		doc_flow_out.reg_number,
		doc_flow_out.to_addr_names,
		doc_flow_out.subject,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_out.to_application_id AS to_application_id,
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		employees_ref(employees) AS employees_ref,
		person_init(employees.name::text,FALSE) AS employee_short_name,

		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		(applications.applicant->>'name')::text||' '||(applications.applicant->>'inn')::text AS applicant_descr,
		
		applications.constr_name AS to_constr_name,
		
		doc_flow_out.content
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=FALSE
	ORDER BY doc_flow_out.date_time DESC
	;
	
ALTER VIEW doc_flow_out_list OWNER TO expert72;


-- ******************* update 19/08/2020 12:32:37 ******************
-- VIEW: doc_flow_out_ext_list

--DROP VIEW doc_flow_out_ext_list;

CREATE OR REPLACE VIEW doc_flow_out_ext_list AS
	SELECT
		doc_flow_out.id,
		doc_flow_out.date_time,
		doc_flow_out.reg_number,
		doc_flow_out.to_addr_names,
		doc_flow_out.subject,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_out.to_application_id AS to_application_id,
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		employees_ref(employees) AS employees_ref,
		person_init(employees.name::text,FALSE) AS employee_short_name,

		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		(applications.applicant->>'name')::text||' '||(applications.applicant->>'inn')::text AS applicant_descr,
		
		applications.constr_name AS to_constr_name,
		
		doc_flow_out.content
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=TRUE
	ORDER BY doc_flow_out.date_time DESC
	;
	
ALTER VIEW doc_flow_out_ext_list OWNER TO expert72;


-- ******************* update 19/08/2020 12:43:16 ******************

	-- Adding menu item
	INSERT INTO views
	(id,c,f,t,section,descr,limited)
	VALUES (
	'20022',
	'DocFlowOut_Controller',
	'get_ext_list',
	'DocFlowOutExtList',
	'Документы',
	'Исходящие документы (внеконтракт)',
	FALSE
	);
	

-- ******************* update 19/08/2020 12:51:01 ******************
-- VIEW: contracts_list

--DROP VIEW contracts_list;

CREATE OR REPLACE VIEW contracts_list AS
	SELECT
		t.id,
		t.date_time,
		t.application_id,
		applications_ref(applications) AS applications_ref,
		
		t.client_id,
		clients.name AS client_descr,
		--clients_ref(clients) AS clients_ref,
		coalesce(t.constr_name,applications.constr_name) AS constr_name,
		
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,

		t.employee_id,
		employees_ref(employees) AS employees_ref,
		
		t.reg_number,
		t.expertise_type,
		t.document_type,
		
		contracts_ref(t) AS self_ref,
		
		t.main_expert_id,
		t.main_department_id,
		m_exp.name AS main_expert_descr,
		--employees_ref(m_exp) AS main_experts_ref,
		
		t.contract_number,
		t.contract_date,
		t.expertise_result_number,
		
		t.comment_text,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_date,
		
		t.for_all_employees,
		CASE
			WHEN (coalesce(pm.cnt,0)=0) THEN 'no_pay'
			WHEN st.state='returned' OR st.state='closed_no_expertise' THEN 'returned'
			WHEN t.expertise_result IS NULL AND t.expertise_result_date<=now()::date THEN 'no_result'
			ELSE NULL
		END AS state_for_color,
		
		applications.exp_cost_eval_validity,
		
		t.permission_ar AS condition_ar,
		
		t.allow_new_file_add,
		
		t.service_type,
		
		CASE WHEN t.service_type = 'modified_documents' THEN contracts_ref(exp_maint_ct)			
		ELSE NULL
		END AS expert_maintenance_contracts_ref,
		CASE WHEN t.service_type = 'modified_documents' THEN exp_maint_ct.id
		ELSE NULL
		END AS expert_maintenance_contract_id
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN contracts AS exp_maint_ct ON exp_maint_ct.application_id=applications.base_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=t.application_id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	LEFT JOIN (
		SELECT
			client_payments.contract_id,
			count(*) AS cnt
		FROM client_payments
		GROUP BY client_payments.contract_id
	) AS pm ON pm.contract_id=t.id
	
	WHERE coalesce(applications.ext_contract,FALSE)=FALSE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW contracts_list OWNER TO expert72;


-- ******************* update 19/08/2020 12:52:39 ******************
-- VIEW: contracts_ext_list

--DROP VIEW contracts_ext_list;

CREATE OR REPLACE VIEW contracts_ext_list AS
	SELECT
		t.id,
		t.date_time,
		t.application_id,
		applications_ref(applications) AS applications_ref,
		
		t.client_id,
		clients.name AS client_descr,
		--clients_ref(clients) AS clients_ref,
		coalesce(t.constr_name,applications.constr_name) AS constr_name,
		
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,

		t.employee_id,
		employees_ref(employees) AS employees_ref,
		
		t.reg_number,
		t.expertise_type,
		t.document_type,
		
		contracts_ref(t) AS self_ref,
		
		t.main_expert_id,
		t.main_department_id,
		m_exp.name AS main_expert_descr,
		--employees_ref(m_exp) AS main_experts_ref,
		
		t.contract_number,
		t.contract_date,
		t.expertise_result_number,
		
		t.comment_text,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_date,
		
		t.for_all_employees,
		CASE
			WHEN (coalesce(pm.cnt,0)=0) THEN 'no_pay'
			WHEN st.state='returned' OR st.state='closed_no_expertise' THEN 'returned'
			WHEN t.expertise_result IS NULL AND t.expertise_result_date<=now()::date THEN 'no_result'
			ELSE NULL
		END AS state_for_color,
		
		applications.exp_cost_eval_validity,
		
		t.permission_ar AS condition_ar,
		
		t.allow_new_file_add,
		
		t.service_type,
		
		CASE WHEN t.service_type = 'modified_documents' THEN contracts_ref(exp_maint_ct)			
		ELSE NULL
		END AS expert_maintenance_contracts_ref,
		CASE WHEN t.service_type = 'modified_documents' THEN exp_maint_ct.id
		ELSE NULL
		END AS expert_maintenance_contract_id
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN contracts AS exp_maint_ct ON exp_maint_ct.application_id=applications.base_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=t.application_id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	LEFT JOIN (
		SELECT
			client_payments.contract_id,
			count(*) AS cnt
		FROM client_payments
		GROUP BY client_payments.contract_id
	) AS pm ON pm.contract_id=t.id
	
	WHERE coalesce(applications.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW contracts_ext_list OWNER TO expert72;


-- ******************* update 19/08/2020 12:57:09 ******************

	-- Adding menu item
	INSERT INTO views
	(id,c,f,t,section,descr,limited)
	VALUES (
	'20023',
	'Contract_Controller',
	'get_list',
	'ContractExtList',
	'Документы',
	'Контракты (внеконтракты)',
	FALSE
	);
	

-- ******************* update 19/08/2020 13:05:42 ******************

UPDATE 	views SET f='get_ext_list' WHERE id='20023';



-- ******************* update 20/08/2020 15:10:15 ******************
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
	v_service_type service_types;
	v_expertise_type expertise_types;
	v_ext_contract bool;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
			
		END IF;
					
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
			
				--Создание Нового КОНТРАКТА
				IF NEW.application_resolution_state='waiting_for_contract'
					--это для измененной документации
					OR NEW.application_resolution_state='expertise'
				THEN
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
							ELSE  'pd'::document_types
						END,
						app.office_id,
						app.service_type,
						app.expertise_type,
						app.ext_contract						
					
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
						v_office_id,
						v_service_type,
						v_expertise_type,
						v_ext_contract
					
					FROM applications AS app
					LEFT JOIN contracts AS p_contr ON p_contr.application_id=app.primary_application_id
					LEFT JOIN contracts AS mp_contr ON mp_contr.application_id=app.modif_primary_application_id
					WHERE app.id=v_application_id;
				
					--applicant -->> client
					UPDATE clients
					SET
						name		= substr(v_app_applicant->>'name',1,100),
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
						client_type	= 
							CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
							ELSE (v_app_applicant->>'client_type')::client_types
							END,
						base_document_for_contract = v_app_applicant->>'base_document_for_contract',
						person_id_paper	= v_app_applicant->'person_id_paper',
						person_registr_paper = v_app_applicant->'person_registr_paper'
					WHERE (inn=v_app_applicant->>'inn' AND kpp=v_app_applicant->>'kpp')
					--name = v_app_applicant->>'name' OR 
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
							CASE WHEN v_app_applicant->>'name' IS NULL THEN v_app_applicant->>'name_full'
							ELSE v_app_applicant->>'name'
							END,
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
							CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
							ELSE (v_app_applicant->>'client_type')::client_types
							END,
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
						v_new_contract_number = contracts_next_number(v_service_type,now()::date,v_ext_contract);
					END IF;
				
					--Номер экспертного заключения
					--'\D+.*$'
					v_expertise_result_number = regexp_replace(v_new_contract_number,'[^0-9]+','','g');
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
					WHERE services.service_type=v_service_type
						AND
						(v_expertise_type IS NULL
						OR services.expertise_type=v_expertise_type
						)
					LIMIT 1
					;
								
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
						user_id,
						service_type)
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
					
						v_app_user_id,
						v_service_type
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
			END IF;					
			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		--статус
		--DELETE FROM doc_flow_in_processes WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
		--задачи
		--DELETE FROM doc_flow_tasks WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_examinations_process() OWNER TO expert72;


-- ******************* update 20/08/2020 15:10:47 ******************
﻿-- Function: contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)

-- DROP FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool);

-- с 19/08/20 функция имеет 3 параметра, + in_ext_contract bool
CREATE OR REPLACE FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool)
  RETURNS text AS
$$
	SELECT
		CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END||
		--'\D+.*$'
		coalesce(max(regexp_replace(ct.contract_number,'[^0-9]+','','g')::int),0)+1||
		(SELECT
			coalesce(services.contract_postf,'')
		FROM services
		WHERE services.service_type=in_service_type
		LIMIT 1
		)
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE
		ct.service_type=in_service_type
		AND extract(year FROM ct.date_time)=extract(year FROM in_date)
		AND (
			(in_ext_contract=FALSE AND coalesce(app.ext_contract,FALSE)=FALSE)
			OR (in_ext_contract AND coalesce(app.ext_contract,FALSE))
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_next_number(in_service_type service_types,in_date date,in_ext_contract bool) OWNER TO expert72;


-- ******************* update 20/08/2020 15:23:56 ******************
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
		applications_ref(app) AS applications_ref,
		applications_client_descr(app.applicant) AS applicant_descr,
		
		CASE WHEN (app.customer->>'customer_is_developer')::bool THEN applications_client_descr(app.developer)
		ELSE applications_client_descr(app.customer)
		END AS customer_descr,
		
		applications_client_descr(app.developer) AS developer_descr,
		
		(SELECT
			json_build_object(
				'id','ContractorList_Model',
				'rows',json_agg(
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
		
		construction_types_ref(construction_types) AS construction_types_ref,
		t.constr_name AS constr_name,
		--kladr_parse_addr(t.constr_address) AS constr_address,
		t.constr_address,
		t.constr_technical_features,
		t.constr_technical_features_in_compound_obj,
		app.total_cost_eval,
		app.limit_cost_eval,
		build_types_ref(build_types) AS build_types_ref,
		app.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
		app.modif_primary_application_reg_number AS modif_primary_contract_reg_number,
		contracts_ref(prim_contr) AS primary_contracts_ref,
		contracts_ref(modif_prim_contr) AS modif_primary_contracts_ref,
		app.cost_eval_validity,
		app.modification,
		app.audit,
		
		--Documents
		app.documents AS documents,
		/*
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(app.create_dt::date) l
			WHERE
				(app.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=app.construction_type_id AND
				l.document_type IN (
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='pd' OR exp_maint_base.expertise_type='pd_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'pd'::document_types
						ELSE NULL
					END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='eng_survey' OR exp_maint_base.expertise_type='pd_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'eng_survey'::document_types
						ELSE NULL
					END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='cost_eval_validity' OR exp_maint_base.expertise_type='cost_eval_validity_pd' OR exp_maint_base.expertise_type='cost_eval_validity_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'cost_eval_validity'::document_types
						ELSE NULL
					END,
					CASE WHEN app.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN app.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		*/		
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
						'experts_list',
						(SELECT
							string_agg(
								coalesce(expert_works.comment_text,'') ||
								'(' || person_init(employees.name,FALSE) || to_char(expert_works.date_time,'DD/MM/YY') || ')'
								,', '
							)
						FROM(
							SELECT
								expert_works.expert_id,
								expert_works.section_id,
								max(expert_works.date_time) AS date_time
							FROM expert_works
							WHERE expert_works.contract_id=t.id AND expert_works.section_id=sec.section_id
							GROUP BY expert_works.expert_id,expert_works.section_id
						) AS ew_last
						LEFT JOIN expert_works ON
							expert_works.date_time=ew_last.date_time
							AND expert_works.expert_id=ew_last.expert_id
							AND expert_works.section_id=ew_last.section_id
						LEFT JOIN employees ON employees.id=expert_works.expert_id	
						)
						
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=app.construction_type_id
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=app.construction_type_id
						AND sec2.create_date<=t.date_time
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
		
		folders.files AS doc_folders,
		
		t.for_all_employees,
		t.in_estim_cost,
		t.in_estim_cost_recommend,
		t.cur_estim_cost,
		t.cur_estim_cost_recommend,
		
		t.result_sign_expert_list,
		
		t.experts_for_notification,
		
		t.contract_return_date_on_sig,
		
		app.exp_cost_eval_validity,
		
		t.main_department_id,
		t.main_expert_id,
		t.permission_ar AS condition_ar,
		
		t.allow_new_file_add,
		t.allow_client_out_documents,
		
		app.customer_auth_letter,
		
		t.service_type,

		CASE
			WHEN app.service_type='modified_documents' THEN
				b_app.expert_maintenance_service_type
			WHEN  app.service_type='expert_maintenance' THEN
				app.expert_maintenance_service_type
			ELSE NULL
		END AS expert_maintenance_service_type,

		CASE
			WHEN app.service_type='modified_documents' THEN
				b_app.expert_maintenance_expertise_type
			WHEN  app.service_type='expert_maintenance' THEN
				app.expert_maintenance_expertise_type
			ELSE NULL
		END AS expert_maintenance_expertise_type,				
		
		CASE WHEN t.service_type='expert_maintenance' THEN
			contracts_ref(exp_main_ct)
		ELSE NULL
		END AS expert_maintenance_base_contracts_ref,
		
		/** Заполняется у контрактов по экспертному сопровождению
		 * вытаскиваем все письма-заключения у всех измененных документаций
		 * связанных с этим контрактом
		 */
		CASE WHEN app.service_type='expert_maintenance' THEN
			(SELECT
				json_agg(
					json_build_object(
						'client_viewed',doc_flow_in_client.viewed,
						'contract',json_build_object(
							'reg_number',mod_doc_out_contr.reg_number,
							'expertise_result',mod_doc_out_contr.expertise_result,
							'expertise_result_date',mod_doc_out_contr.expertise_result_date,
							'expertise_reject_types_ref',expertise_reject_types_ref((SELECT expertise_reject_types FROM expertise_reject_types WHERE id=mod_doc_out_contr.expertise_reject_type_id)),
							'result_sign_expert_list',mod_doc_out_contr.result_sign_expert_list
						),
						'file',json_build_object(
							'file_id',att.file_id,
							'file_name',att.file_name,
							'file_size',att.file_size,
							'file_signed',att.file_signed,
							'file_uploaded','true',
							'file_path',att.file_path,
							'date_time',f_ver.date_time,
							'signatures',
							(WITH sign AS
							(SELECT
								json_agg(files_t.signatures) AS signatures
							FROM
								(SELECT
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
								WHERE f_sig.file_id=f_ver.file_id
								ORDER BY f_sig.sign_date_time
								) AS files_t
							)					
							SELECT
								CASE
									WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
										json_build_array(
											json_build_object(
												'sign_date_time',f_ver.date_time,
												'check_result',f_ver.check_result,
												'error_str',f_ver.error_str
											)
										)
									ELSE (SELECT sign.signatures FROM sign)
								END
							),
							'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id)
						)
					)
				)
			
			FROM doc_flow_out AS mod_doc_out
			LEFT JOIN doc_flow_attachments AS att ON
				att.file_path='Заключение' AND att.doc_type='doc_flow_out' AND att.doc_id=mod_doc_out.id
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
			LEFT JOIN contracts AS mod_doc_out_contr ON mod_doc_out_contr.id=mod_doc_out.to_contract_id
			LEFT JOIN doc_flow_in_client ON doc_flow_in_client.doc_flow_out_id=mod_doc_out.id				
			WHERE mod_doc_out.to_application_id IN
				(SELECT
					mod_app.id
				FROM applications AS mod_app
				WHERE mod_app.base_application_id = t.application_id 
				)
				AND mod_doc_out.doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
			)
		ELSE NULL
		END AS results_on_modified_documents_list,
		
		app.ext_contract
		
	FROM contracts t
	LEFT JOIN applications AS app ON app.id=t.application_id
	LEFT JOIN contracts AS exp_main_ct ON exp_main_ct.application_id=app.expert_maintenance_base_application_id
	LEFT JOIN construction_types ON construction_types.id=app.construction_type_id
	LEFT JOIN build_types ON build_types.id=app.build_type_id
	LEFT JOIN fund_sources AS fund_sources ON fund_sources.id = coalesce(t.fund_source_id,app.fund_source_id)
	LEFT JOIN
		(
		SELECT
			doc_att.application_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			adf_files.application_id,
			adf_files.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(adf_files.files) AS files
		FROM
			(SELECT
				adf.application_id,
				adf.file_path,
				json_build_object(
					'file_id',adf.file_id,
					'file_name',adf.file_name,
					'file_size',adf.file_size,
					'file_signed',adf.file_signed,
					'file_uploaded','true',
					'file_path',adf.file_path,
					'date_time',adf.date_time,
					'signatures',
				
					(WITH
					sign AS (SELECT
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
						WHERE f_sig.file_id=adf.file_id
						ORDER BY f_sig.sign_date_time
						) AS files_t
					)
					SELECT
						CASE
							WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
								json_build_array(
									json_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE (SELECT sign.signatures FROM sign)
						END
					),
					'file_signed_by_client',adf.file_signed_by_client
					--'require_client_sig',app_fd.require_client_sig
				) AS files
			FROM application_document_files adf			
			--LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			--LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
		
			WHERE adf.document_type='documents'			
			ORDER BY adf.application_id,adf.file_path,adf.date_time
			)  AS adf_files
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf_files.file_path
		GROUP BY adf_files.application_id,adf_files.file_path,app_fd.id
		ORDER BY adf_files.application_id,adf_files.file_path
		)  AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=app.id
	
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN expertise_reject_types AS rt ON rt.id=t.expertise_reject_type_id
	LEFT JOIN departments AS dp ON dp.id=t.main_department_id
	LEFT JOIN employees AS exp_empl ON exp_empl.id=t.main_expert_id
	LEFT JOIN contracts AS prim_contr ON prim_contr.id=t.primary_contract_id
	LEFT JOIN contracts AS modif_prim_contr ON modif_prim_contr.id=t.modif_primary_contract_id
	
	LEFT JOIN applications b_app ON b_app.id=app.base_application_id
	--LEFT JOIN applications exp_maint_base ON exp_maint_base.id=exp_maint.expert_maintenance_base_application_id

	--LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;



-- ******************* update 20/08/2020 18:02:17 ******************
﻿-- Function: contracts_expertise_result_number(in_contract_number text,in_contract_date date)

-- DROP FUNCTION contracts_expertise_result_number(in_contract_number text,in_contract_date date);

CREATE OR REPLACE FUNCTION contracts_expertise_result_number(in_contract_number text,in_contract_date date)
  RETURNS text AS
$$
	WITH contr_num AS (
		SELECT regexp_replace(in_contract_number,'[^0-9]+','','g') AS v
	)
	SELECT
		substr('0000',1,4-length( (SELECT v FROM contr_num) ))||
		(SELECT v FROM contr_num)||
		'/'||
		(extract(year FROM in_contract_date)-2000)::text
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contracts_expertise_result_number(in_contract_number text,in_contract_date date) OWNER TO expert72;


-- ******************* update 20/08/2020 18:03:06 ******************
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
	v_service_type service_types;
	v_expertise_type expertise_types;
	v_ext_contract bool;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
			
		END IF;
					
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
			
				--Создание Нового КОНТРАКТА
				IF NEW.application_resolution_state='waiting_for_contract'
					--это для измененной документации
					OR NEW.application_resolution_state='expertise'
				THEN
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
							ELSE  'pd'::document_types
						END,
						app.office_id,
						app.service_type,
						app.expertise_type,
						app.ext_contract						
					
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
						v_office_id,
						v_service_type,
						v_expertise_type,
						v_ext_contract
					
					FROM applications AS app
					LEFT JOIN contracts AS p_contr ON p_contr.application_id=app.primary_application_id
					LEFT JOIN contracts AS mp_contr ON mp_contr.application_id=app.modif_primary_application_id
					WHERE app.id=v_application_id;
				
					--applicant -->> client
					UPDATE clients
					SET
						name		= substr(v_app_applicant->>'name',1,100),
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
						client_type	= 
							CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
							ELSE (v_app_applicant->>'client_type')::client_types
							END,
						base_document_for_contract = v_app_applicant->>'base_document_for_contract',
						person_id_paper	= v_app_applicant->'person_id_paper',
						person_registr_paper = v_app_applicant->'person_registr_paper'
					WHERE (inn=v_app_applicant->>'inn' AND kpp=v_app_applicant->>'kpp')
					--name = v_app_applicant->>'name' OR 
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
							CASE WHEN v_app_applicant->>'name' IS NULL THEN v_app_applicant->>'name_full'
							ELSE v_app_applicant->>'name'
							END,
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
							CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
							ELSE (v_app_applicant->>'client_type')::client_types
							END,
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
						v_new_contract_number = contracts_next_number(v_service_type,now()::date,v_ext_contract);
					END IF;
				
					--Номер экспертного заключения
					--'\D+.*$'
					v_expertise_result_number = contracts_expertise_result_number(v_new_contract_number, now()::date);
					/*
					v_expertise_result_number = regexp_replace(v_new_contract_number,'[^0-9]+','','g');
					v_expertise_result_number = substr('0000',1,4-length(v_expertise_result_number))||
								v_expertise_result_number||
								'/'||(extract(year FROM now())-2000)::text;
					*/			
				
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
					WHERE services.service_type=v_service_type
						AND
						(v_expertise_type IS NULL
						OR services.expertise_type=v_expertise_type
						)
					LIMIT 1
					;
								
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
						user_id,
						service_type)
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
					
						v_app_user_id,
						v_service_type
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
			END IF;					
			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		--статус
		--DELETE FROM doc_flow_in_processes WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
		--задачи
		--DELETE FROM doc_flow_tasks WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_examinations_process() OWNER TO expert72;


-- ******************* update 16/09/2020 16:24:14 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
	
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 16:51:58 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
RAISE EXCEPTION '%',doc_flow_in_next_num((SELECT doc_flow_type_id FROM doc_flow_in WHERE from_application_id = v_application_id),FALSE);	
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
	
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 16:53:24 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
RAISE EXCEPTION '%',(SELECT doc_flow_type_id FROM doc_flow_in WHERE from_application_id = v_application_id);		
RAISE EXCEPTION '%',doc_flow_in_next_num((SELECT doc_flow_type_id FROM doc_flow_in WHERE from_application_id = v_application_id),FALSE);	
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
	
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 16:53:50 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
RAISE EXCEPTION '%',(doc_flow_in_next_num(1,FALSE));		
RAISE EXCEPTION '%',doc_flow_in_next_num((SELECT doc_flow_type_id FROM doc_flow_in WHERE from_application_id = v_application_id),FALSE);	
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
	
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 16:54:12 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
RAISE EXCEPTION '%',(doc_flow_in_next_num(1,TRUE));		
RAISE EXCEPTION '%',doc_flow_in_next_num((SELECT doc_flow_type_id FROM doc_flow_in WHERE from_application_id = v_application_id),FALSE);	
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
	
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 17:10:07 ******************
﻿-- Function: doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool)

-- DROP FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool);

CREATE OR REPLACE FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool)
  RETURNS text AS
$$
	WITH
		pref AS (
			SELECT
				num_prefix||
					CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END
				AS n
			FROM doc_flow_types
			WHERE id = in_doc_flow_type_id
		)
	SELECT
		(SELECT n FROM pref) || (coalesce(
						max(substr(reg_number,length( (SELECT n FROM pref) )+1)::int)
						,0)+1
					)::text
	FROM doc_flow_in
	WHERE substr(reg_number,1,length((SELECT n FROM pref)))=(SELECT n FROM pref)
		AND substr(reg_number,length((SELECT n FROM pref))+1) ~ '^[0-9\.]+$'
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool) OWNER TO expert72;


-- ******************* update 16/09/2020 17:10:46 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
	
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 17:33:31 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
		
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- doc_flow_in_client NEW reg_number
	UPDATE doc_flow_in_client
	SET reg_number = (SELECT reg_number FROM doc_flow_out AS t WHERE t.id=doc_flow_in_client.doc_flow_out_id)
	WHERE application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 17:44:34 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
		
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- doc_flow_in_client NEW reg_number
	UPDATE doc_flow_in_client
	SET reg_number = (SELECT reg_number FROM doc_flow_out AS t WHERE t.id=doc_flow_in_client.doc_flow_out_id)
	WHERE application_id = v_application_id;
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 16/09/2020 17:51:11 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
		
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- doc_flow_in_client NEW reg_number
	UPDATE doc_flow_in_client
	SET reg_number = (SELECT reg_number FROM doc_flow_out AS t WHERE t.id=doc_flow_in_client.doc_flow_out_id)
	WHERE application_id = v_application_id;

	UPDATE doc_flow_out_client
	SET reg_number = (SELECT reg_number FROM doc_flow_in AS t WHERE t.from_doc_flow_out_client_id=doc_flow_out_client.id)
	WHERE application_id = v_application_id;
	
	
	-- Контракт номер
	UPDATE contracts
	SET
		contract_number = contracts_next_number(v_service_type,now()::date,FALSE)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 28/09/2020 09:25:09 ******************

		ALTER TABLE services ADD COLUMN ban_client_responses_day_cnt int;



-- ******************* update 28/09/2020 09:28:47 ******************
UPDATE services
SET ban_client_responses_day_cnt = const_ban_client_responses_day_cnt_val();


-- ******************* update 30/09/2020 14:37:12 ******************

		ALTER TABLE doc_flow_attachments ADD COLUMN require_client_sig bool;



-- ******************* update 30/09/2020 14:38:30 ******************
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
					'signatures',
					(WITH sign AS
					(SELECT
						json_agg(files_t.signatures) AS signatures
					FROM
						(SELECT
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
						WHERE f_sig.file_id=f_ver.file_id
						ORDER BY f_sig.sign_date_time
						) AS files_t
					)					
					SELECT
						CASE
							WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
								json_build_array(
									json_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE (SELECT sign.signatures FROM sign)
						END
					),
					'file_signed_by_client',
						CASE WHEN st.state = 'registered' THEN
							(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id)
							ELSE
							(SELECT t1.require_client_sig FROM doc_flow_attachments t1 WHERE t1.file_id=att.file_id)
						END,
					'require_client_sig',(app_fd.require_client_sig AND att.require_client_sig)
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
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
		expertise_reject_types.id AS expertise_reject_type_id,
		
		employees_ref(employees3) AS to_contract_main_experts_ref
		
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
	LEFT JOIN employees AS employees3 ON employees3.id=contracts.main_expert_id
	
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


-- ******************* update 30/09/2020 14:40:09 ******************
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
					'signatures',
					(WITH sign AS
					(SELECT
						json_agg(files_t.signatures) AS signatures
					FROM
						(SELECT
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
						WHERE f_sig.file_id=f_ver.file_id
						ORDER BY f_sig.sign_date_time
						) AS files_t
					)					
					SELECT
						CASE
							WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
								json_build_array(
									json_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE (SELECT sign.signatures FROM sign)
						END
					),
					'file_signed_by_client',
						CASE WHEN st.state = 'registered' THEN
							(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id)
							ELSE NULL
							--(SELECT t1.require_client_sig FROM doc_flow_attachments t1 WHERE t1.file_id=att.file_id)
						END,
					'require_client_sig',(app_fd.require_client_sig AND att.require_client_sig)
				)
			) AS files
		FROM application_doc_folders AS app_fd
		LEFT JOIN doc_flow_attachments AS att ON
			att.file_path=app_fd.name AND att.doc_type='doc_flow_out' AND att.doc_id=doc_flow_out.id
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
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
		expertise_reject_types.id AS expertise_reject_type_id,
		
		employees_ref(employees3) AS to_contract_main_experts_ref
		
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
	LEFT JOIN employees AS employees3 ON employees3.id=contracts.main_expert_id
	
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




UPDATE doc_flow_attachments
SET require_client_sig = (SELECT t.require_client_sig 
						  FROM application_doc_folders t
						  WHERE t.name=doc_flow_attachments.file_path)

-- ******************* update 30/09/2020 15:30:35 ******************
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
							'signatures',
							(SELECT
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
								WHERE f_sig.file_id = att.file_id
								ORDER BY f_sig.sign_date_time
								) AS sign_t
							)
							,
							'file_signed_by_client',app_f.file_signed_by_client,
							'require_client_sig',att.require_client_sig
						) AS files
					FROM doc_flow_attachments AS att
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
					LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
					WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
					GROUP BY att.file_path,att.file_name,att.file_id,app_f.file_signed_by_client
					ORDER BY att.file_path,att.file_name
					) AS files
				)
			)
		) AS files,
		regs.reg_number AS reg_number_out,
		coalesce(doc_out.allow_new_file_add,FALSE) AS allow_new_file_add,
		doc_out.allow_edit_sections
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	LEFT JOIN doc_flow_out AS doc_out ON doc_out.id = t.doc_flow_out_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;


-- ******************* update 30/09/2020 16:29:51 ******************
-- VIEW: doc_flow_out_client_dialog

--DROP VIEW doc_flow_out_client_dialog;

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
		
		(WITH att AS
		(SELECT
			jsonb_agg(files_t.attachments) AS attachments
		FROM
			(SELECT
				json_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,
					'signatures',
					(SELECT
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
						WHERE f_sig.file_id=out_f.file_id
						ORDER BY f_sig.sign_date_time
						) AS sign_t
					),
					'file_signed_by_client',app_f.file_signed_by_client,
					'require_client_sig',(SELECT t1.require_client_sig FROM doc_flow_attachments As t1 WHERE t1.file_id=out_f.file_id)
				) AS attachments			
			FROM doc_flow_out_client_document_files AS out_f
			LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
			LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
			WHERE app_f.document_id=0
				AND coalesce(folders.require_client_sig,FALSE)=FALSE
				AND out_f.doc_flow_out_client_id = t.id
			ORDER BY app_f.file_path,app_f.file_name
			) AS files_t
		)
		SELECT
			CASE WHEN (SELECT att.attachments FROM att) IS NULL THEN NULL
			ELSE
				jsonb_build_array(
					jsonb_build_object(
						'files',(SELECT att.attachments FROM att)
					)
				)
			END
		)
		AS attachment_files,
		
		(WITH att_only_sigs AS 
		(SELECT
			jsonb_agg(files_t.attachments) AS attachments
		FROM
			(SELECT
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,
					'signatures',
					(SELECT
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
						WHERE f_sig.file_id = out_f.file_id
						ORDER BY f_sig.sign_date_time
						) AS sign_t
					),
					'file_signed_by_client',app_f.file_signed_by_client
				) AS attachments			
			FROM doc_flow_out_client_document_files AS out_f
			LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
			LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
			WHERE
				app_f.document_id=0 AND folders.require_client_sig
				AND out_f.doc_flow_out_client_id = t.id
			ORDER BY app_f.file_path,app_f.file_name
			) AS files_t
		)
		SELECT
			CASE
				WHEN (SELECT att_only_sigs.attachments FROM att_only_sigs) IS NULL AND t.sent THEN NULL
				WHEN t.doc_flow_out_client_type='contr_return' THEN
					jsonb_build_array(
						jsonb_build_object(
							'files',
								CASE
									WHEN t.sent THEN '[]'::jsonb
									WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
									ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
								END
								||
								CASE WHEN (SELECT att_only_sigs.attachments FROM att_only_sigs) IS NULL THEN '[]'::jsonb ELSE (SELECT att_only_sigs.attachments FROM att_only_sigs)
								END
						)
					)
				ELSE NULL
			END
		) AS attachment_files_only_sigs,
		
		-- Если это этветы на замечения, вытягиваем последний зарегистрированный документ - наше письмо,
		-- в ответ на него и делается это письмо клиента
		-- из него берем разрешения
		CASE
			WHEN t.doc_flow_out_client_type='contr_resp' THEN
				doc_flow_out_client_out_attrs(t.application_id)
			ELSE NULL
		END AS doc_flow_out_attrs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id	
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')

	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;


-- ******************* update 30/09/2020 16:30:44 ******************
-- VIEW: doc_flow_out_client_dialog

--DROP VIEW doc_flow_out_client_dialog;

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
		
		(WITH att AS
		(SELECT
			jsonb_agg(files_t.attachments) AS attachments
		FROM
			(SELECT
				json_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,
					'signatures',
					(SELECT
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
						WHERE f_sig.file_id=out_f.file_id
						ORDER BY f_sig.sign_date_time
						) AS sign_t
					),
					'file_signed_by_client',app_f.file_signed_by_client,
					'require_client_sig',(SELECT t1.require_client_sig FROM doc_flow_attachments As t1 WHERE t1.file_id=out_f.file_id)
				) AS attachments			
			FROM doc_flow_out_client_document_files AS out_f
			LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
			LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
			WHERE app_f.document_id=0
				AND coalesce(folders.require_client_sig,FALSE)=FALSE
				AND out_f.doc_flow_out_client_id = t.id
			ORDER BY app_f.file_path,app_f.file_name
			) AS files_t
		)
		SELECT
			CASE WHEN (SELECT att.attachments FROM att) IS NULL THEN NULL
			ELSE
				jsonb_build_array(
					jsonb_build_object(
						'files',(SELECT att.attachments FROM att)
					)
				)
			END
		)
		AS attachment_files,
		
		(WITH att_only_sigs AS 
		(SELECT
			jsonb_agg(files_t.attachments) AS attachments
		FROM
			(SELECT
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,
					'signatures',
					(SELECT
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
						WHERE f_sig.file_id = out_f.file_id
						ORDER BY f_sig.sign_date_time
						) AS sign_t
					),
					'file_signed_by_client',app_f.file_signed_by_client
					,'require_client_sig',(SELECT t1.require_client_sig FROM doc_flow_attachments As t1 WHERE t1.file_id=out_f.file_id)
				) AS attachments			
			FROM doc_flow_out_client_document_files AS out_f
			LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
			LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
			WHERE
				app_f.document_id=0 AND folders.require_client_sig
				AND out_f.doc_flow_out_client_id = t.id
			ORDER BY app_f.file_path,app_f.file_name
			) AS files_t
		)
		SELECT
			CASE
				WHEN (SELECT att_only_sigs.attachments FROM att_only_sigs) IS NULL AND t.sent THEN NULL
				WHEN t.doc_flow_out_client_type='contr_return' THEN
					jsonb_build_array(
						jsonb_build_object(
							'files',
								CASE
									WHEN t.sent THEN '[]'::jsonb
									WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
									ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
								END
								||
								CASE WHEN (SELECT att_only_sigs.attachments FROM att_only_sigs) IS NULL THEN '[]'::jsonb ELSE (SELECT att_only_sigs.attachments FROM att_only_sigs)
								END
						)
					)
				ELSE NULL
			END
		) AS attachment_files_only_sigs,
		
		-- Если это этветы на замечения, вытягиваем последний зарегистрированный документ - наше письмо,
		-- в ответ на него и делается это письмо клиента
		-- из него берем разрешения
		CASE
			WHEN t.doc_flow_out_client_type='contr_resp' THEN
				doc_flow_out_client_out_attrs(t.application_id)
			ELSE NULL
		END AS doc_flow_out_attrs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id	
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')

	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;


-- ******************* update 30/09/2020 16:32:35 ******************
-- VIEW: doc_flow_out_client_dialog

--DROP VIEW doc_flow_out_client_dialog;

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
		
		(WITH att AS
		(SELECT
			jsonb_agg(files_t.attachments) AS attachments
		FROM
			(SELECT
				json_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,
					'signatures',
					(SELECT
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
						WHERE f_sig.file_id=out_f.file_id
						ORDER BY f_sig.sign_date_time
						) AS sign_t
					),
					'file_signed_by_client',app_f.file_signed_by_client
				) AS attachments			
			FROM doc_flow_out_client_document_files AS out_f
			LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
			LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
			WHERE app_f.document_id=0
				AND coalesce(folders.require_client_sig,FALSE)=FALSE
				AND out_f.doc_flow_out_client_id = t.id
			ORDER BY app_f.file_path,app_f.file_name
			) AS files_t
		)
		SELECT
			CASE WHEN (SELECT att.attachments FROM att) IS NULL THEN NULL
			ELSE
				jsonb_build_array(
					jsonb_build_object(
						'files',(SELECT att.attachments FROM att)
					)
				)
			END
		)
		AS attachment_files,
		
		(WITH att_only_sigs AS 
		(SELECT
			jsonb_agg(files_t.attachments) AS attachments
		FROM
			(SELECT
				jsonb_build_object(
					'file_id',app_f.file_id,
					'file_name',app_f.file_name,
					'file_size',app_f.file_size,
					'file_signed',app_f.file_signed,
					'file_uploaded','true',
					'file_path',app_f.file_path,
					'signatures',
					(SELECT
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
						WHERE f_sig.file_id = out_f.file_id
						ORDER BY f_sig.sign_date_time
						) AS sign_t
					),
					'file_signed_by_client',app_f.file_signed_by_client					
				) AS attachments			
			FROM doc_flow_out_client_document_files AS out_f
			LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
			LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
			WHERE
				app_f.document_id=0 AND folders.require_client_sig
				AND out_f.doc_flow_out_client_id = t.id
			ORDER BY app_f.file_path,app_f.file_name
			) AS files_t
		)
		SELECT
			CASE
				WHEN (SELECT att_only_sigs.attachments FROM att_only_sigs) IS NULL AND t.sent THEN NULL
				WHEN t.doc_flow_out_client_type='contr_return' THEN
					jsonb_build_array(
						jsonb_build_object(
							'files',
								CASE
									WHEN t.sent THEN '[]'::jsonb
									WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
									ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
								END
								||
								CASE WHEN (SELECT att_only_sigs.attachments FROM att_only_sigs) IS NULL THEN '[]'::jsonb ELSE (SELECT att_only_sigs.attachments FROM att_only_sigs)
								END
						)
					)
				ELSE NULL
			END
		) AS attachment_files_only_sigs,
		
		-- Если это этветы на замечения, вытягиваем последний зарегистрированный документ - наше письмо,
		-- в ответ на него и делается это письмо клиента
		-- из него берем разрешения
		CASE
			WHEN t.doc_flow_out_client_type='contr_resp' THEN
				doc_flow_out_client_out_attrs(t.application_id)
			ELSE NULL
		END AS doc_flow_out_attrs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id	
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')

	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;


-- ******************* update 30/09/2020 16:33:38 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	SELECT
		jsonb_build_object(
			'files',		
			json_agg(att.attachments)
		) AS attachments
	FROM (
	SELECT
		json_build_object(
			'file_id',app_f.file_id,
			'file_name',app_f.file_name,
			'file_size',app_f.file_size,
			'file_signed',app_f.file_signed,
			'file_uploaded','true',
			'file_path',app_f.file_path,				
			'file_signed_by_client',app_f.file_signed_by_client,
			'signatures',
			--sign.signatures				
			(SELECT
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
				WHERE f_sig.file_id = app_f.file_id
				ORDER BY f_sig.sign_date_time
				) AS sign_t							
			)
			,'require_client_sig',att_f.require_client_sig
		) AS attachments
	FROM application_document_files AS app_f
	LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
	LEFT JOIN doc_flow_attachments AS att_f ON att_f.file_id=app_f.file_id
	WHERE
		app_f.application_id = in_application_id AND app_f.document_type='documents'
		AND NOT coalesce(app_f.file_signed_by_client,FALSE)
		AND NOT coalesce(app_f.deleted,FALSE)
		AND fld.require_client_sig
	ORDER BY app_f.file_name
	) AS att
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;


-- ******************* update 30/09/2020 16:38:49 ******************
-- Function: doc_flow_registrations_process()

-- DROP FUNCTION doc_flow_registrations_process();

CREATE OR REPLACE FUNCTION doc_flow_registrations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_out_id int;
	v_to_application_id int;
	v_doc_flow_type_id int;
	v_date_time timestampTZ;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
	
		v_doc_flow_out_id = (NEW.subject_doc->'keys'->>'id')::int;
		
		IF NOT const_client_lk_val() OR const_debug_val() THEN			
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
				/*
				IF v_doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int THEN
					UPDATE contracts
					SET expertise_result_date = NEW.date_time::date				
					WHERE application_id=v_to_application_id;
				END IF;
				*/
			END IF;		
		END IF;
		
		IF const_client_lk_val() OR const_debug_val() THEN
			--если основание - заявление/контракт = ответное письмо клиенту
			INSERT INTO doc_flow_in_client (
				date_time,
				reg_number,
				application_id,
				user_id,
				subject,
				content,
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
				t.doc_flow_type_id,
				v_doc_flow_out_id
			
			FROM doc_flow_out t
			LEFT JOIN applications ap ON ap.id=t.to_application_id			
			WHERE t.id=v_doc_flow_out_id AND t.to_application_id IS NOT NULL
			;
			
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				--Если есть вложения с папками "в дело" - копируем в application_document_files
				INSERT INTO application_document_files
				(file_id,
				application_id,
				document_id,
				document_type,
				date_time,
				file_name,
				file_path,
				file_signed,
				file_size,
				file_signed_by_client)
				SELECT
					at.file_id,
					out.to_application_id,
					0,
					'documents',
					at.file_date,
					at.file_name,
					at.file_path,
					at.file_signed,
					at.file_size,
					NOT at.require_client_sig
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=(NEW.subject_doc->'keys'->>'id')::int
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=(NEW.subject_doc->'keys'->>'id')::int
					AND at.file_path!='Исходящие'
				--Все кроме исходящих
				;
			END IF;
			
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


-- ******************* update 30/09/2020 16:41:33 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	SELECT
		jsonb_build_object(
			'files',		
			json_agg(att.attachments)
		) AS attachments
	FROM (
	SELECT
		json_build_object(
			'file_id',app_f.file_id,
			'file_name',app_f.file_name,
			'file_size',app_f.file_size,
			'file_signed',app_f.file_signed,
			'file_uploaded','true',
			'file_path',app_f.file_path,				
			'file_signed_by_client',app_f.file_signed_by_client,
			'signatures',
			--sign.signatures				
			(SELECT
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
				WHERE f_sig.file_id = app_f.file_id
				ORDER BY f_sig.sign_date_time
				) AS sign_t							
			)
			,'require_client_sig',att_f.require_client_sig
		) AS attachments
	FROM application_document_files AS app_f
	LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
	LEFT JOIN doc_flow_attachments AS att_f ON att_f.file_id=app_f.file_id
	WHERE
		app_f.application_id = in_application_id AND app_f.document_type='documents'
		AND NOT coalesce(app_f.file_signed_by_client,FALSE)
		AND NOT coalesce(app_f.deleted,FALSE)
		AND att_f.require_client_sig
		--fld.require_client_sig
	ORDER BY app_f.file_name
	) AS att
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;


-- ******************* update 30/09/2020 16:41:55 ******************
﻿-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	SELECT
		jsonb_build_object(
			'files',		
			json_agg(att.attachments)
		) AS attachments
	FROM (
	SELECT
		json_build_object(
			'file_id',app_f.file_id,
			'file_name',app_f.file_name,
			'file_size',app_f.file_size,
			'file_signed',app_f.file_signed,
			'file_uploaded','true',
			'file_path',app_f.file_path,				
			'file_signed_by_client',app_f.file_signed_by_client,
			'signatures',
			--sign.signatures				
			(SELECT
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
				WHERE f_sig.file_id = app_f.file_id
				ORDER BY f_sig.sign_date_time
				) AS sign_t							
			)
			,'require_client_sig',att_f.require_client_sig
		) AS attachments
	FROM application_document_files AS app_f
	--LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
	LEFT JOIN doc_flow_attachments AS att_f ON att_f.file_id=app_f.file_id
	WHERE
		app_f.application_id = in_application_id AND app_f.document_type='documents'
		AND NOT coalesce(app_f.file_signed_by_client,FALSE)
		AND NOT coalesce(app_f.deleted,FALSE)
		AND att_f.require_client_sig
		--fld.require_client_sig
	ORDER BY app_f.file_name
	) AS att
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO expert72;


-- ******************* update 30/09/2020 16:43:50 ******************
-- Function: doc_flow_registrations_process()

-- DROP FUNCTION doc_flow_registrations_process();

CREATE OR REPLACE FUNCTION doc_flow_registrations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_out_id int;
	v_to_application_id int;
	v_doc_flow_type_id int;
	v_date_time timestampTZ;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
	
		v_doc_flow_out_id = (NEW.subject_doc->'keys'->>'id')::int;
		
		IF NOT const_client_lk_val() OR const_debug_val() THEN			
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
				/*
				IF v_doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int THEN
					UPDATE contracts
					SET expertise_result_date = NEW.date_time::date				
					WHERE application_id=v_to_application_id;
				END IF;
				*/
			END IF;		
		END IF;
		
		IF const_client_lk_val() OR const_debug_val() THEN
			--если основание - заявление/контракт = ответное письмо клиенту
			INSERT INTO doc_flow_in_client (
				date_time,
				reg_number,
				application_id,
				user_id,
				subject,
				content,
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
				t.doc_flow_type_id,
				v_doc_flow_out_id
			
			FROM doc_flow_out t
			LEFT JOIN applications ap ON ap.id=t.to_application_id			
			WHERE t.id=v_doc_flow_out_id AND t.to_application_id IS NOT NULL
			;
			
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				--Если есть вложения с папками "в дело" - копируем в application_document_files
				INSERT INTO application_document_files
				(file_id,
				application_id,
				document_id,
				document_type,
				date_time,
				file_name,
				file_path,
				file_signed,
				file_size
				--,file_signed_by_client
				)
				SELECT
					at.file_id,
					out.to_application_id,
					0,
					'documents',
					at.file_date,
					at.file_name,
					at.file_path,
					at.file_signed,
					at.file_size
					--,NOT at.require_client_sig
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=(NEW.subject_doc->'keys'->>'id')::int
				WHERE
					at.doc_type='doc_flow_out'
					AND at.doc_id=(NEW.subject_doc->'keys'->>'id')::int
					AND at.file_path!='Исходящие'
				--Все кроме исходящих
				;
			END IF;
			
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


-- ******************* update 30/09/2020 17:06:49 ******************
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
		applications_ref(app) AS applications_ref,
		applications_client_descr(app.applicant) AS applicant_descr,
		
		CASE WHEN (app.customer->>'customer_is_developer')::bool THEN applications_client_descr(app.developer)
		ELSE applications_client_descr(app.customer)
		END AS customer_descr,
		
		applications_client_descr(app.developer) AS developer_descr,
		
		(SELECT
			json_build_object(
				'id','ContractorList_Model',
				'rows',json_agg(
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
		
		construction_types_ref(construction_types) AS construction_types_ref,
		t.constr_name AS constr_name,
		--kladr_parse_addr(t.constr_address) AS constr_address,
		t.constr_address,
		t.constr_technical_features,
		t.constr_technical_features_in_compound_obj,
		app.total_cost_eval,
		app.limit_cost_eval,
		build_types_ref(build_types) AS build_types_ref,
		app.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
		app.modif_primary_application_reg_number AS modif_primary_contract_reg_number,
		contracts_ref(prim_contr) AS primary_contracts_ref,
		contracts_ref(modif_prim_contr) AS modif_primary_contracts_ref,
		app.cost_eval_validity,
		app.modification,
		app.audit,
		
		--Documents
		app.documents AS documents,
		/*
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(app.create_dt::date) l
			WHERE
				(app.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=app.construction_type_id AND
				l.document_type IN (
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='pd' OR exp_maint_base.expertise_type='pd_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'pd'::document_types
						ELSE NULL
					END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='eng_survey' OR exp_maint_base.expertise_type='pd_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'eng_survey'::document_types
						ELSE NULL
					END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='cost_eval_validity' OR exp_maint_base.expertise_type='cost_eval_validity_pd' OR exp_maint_base.expertise_type='cost_eval_validity_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'cost_eval_validity'::document_types
						ELSE NULL
					END,
					CASE WHEN app.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN app.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		*/		
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
						'experts_list',
						(SELECT
							string_agg(
								coalesce(expert_works.comment_text,'') ||
								'(' || person_init(employees.name,FALSE) || to_char(expert_works.date_time,'DD/MM/YY') || ')'
								,', '
							)
						FROM(
							SELECT
								expert_works.expert_id,
								expert_works.section_id,
								max(expert_works.date_time) AS date_time
							FROM expert_works
							WHERE expert_works.contract_id=t.id AND expert_works.section_id=sec.section_id
							GROUP BY expert_works.expert_id,expert_works.section_id
						) AS ew_last
						LEFT JOIN expert_works ON
							expert_works.date_time=ew_last.date_time
							AND expert_works.expert_id=ew_last.expert_id
							AND expert_works.section_id=ew_last.section_id
						LEFT JOIN employees ON employees.id=expert_works.expert_id	
						)
						
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=app.construction_type_id
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=app.construction_type_id
						AND sec2.create_date<=t.date_time
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
		
		folders.files AS doc_folders,
		
		t.for_all_employees,
		t.in_estim_cost,
		t.in_estim_cost_recommend,
		t.cur_estim_cost,
		t.cur_estim_cost_recommend,
		
		t.result_sign_expert_list,
		
		t.experts_for_notification,
		
		t.contract_return_date_on_sig,
		
		app.exp_cost_eval_validity,
		
		t.main_department_id,
		t.main_expert_id,
		t.permission_ar AS condition_ar,
		
		t.allow_new_file_add,
		t.allow_client_out_documents,
		
		app.customer_auth_letter,
		
		t.service_type,

		CASE
			WHEN app.service_type='modified_documents' THEN
				b_app.expert_maintenance_service_type
			WHEN  app.service_type='expert_maintenance' THEN
				app.expert_maintenance_service_type
			ELSE NULL
		END AS expert_maintenance_service_type,

		CASE
			WHEN app.service_type='modified_documents' THEN
				b_app.expert_maintenance_expertise_type
			WHEN  app.service_type='expert_maintenance' THEN
				app.expert_maintenance_expertise_type
			ELSE NULL
		END AS expert_maintenance_expertise_type,				
		
		CASE WHEN t.service_type='expert_maintenance' THEN
			contracts_ref(exp_main_ct)
		ELSE NULL
		END AS expert_maintenance_base_contracts_ref,
		
		/** Заполняется у контрактов по экспертному сопровождению
		 * вытаскиваем все письма-заключения у всех измененных документаций
		 * связанных с этим контрактом
		 */
		CASE WHEN app.service_type='expert_maintenance' THEN
			(SELECT
				json_agg(
					json_build_object(
						'client_viewed',doc_flow_in_client.viewed,
						'contract',json_build_object(
							'reg_number',mod_doc_out_contr.reg_number,
							'expertise_result',mod_doc_out_contr.expertise_result,
							'expertise_result_date',mod_doc_out_contr.expertise_result_date,
							'expertise_reject_types_ref',expertise_reject_types_ref((SELECT expertise_reject_types FROM expertise_reject_types WHERE id=mod_doc_out_contr.expertise_reject_type_id)),
							'result_sign_expert_list',mod_doc_out_contr.result_sign_expert_list
						),
						'file',json_build_object(
							'file_id',att.file_id,
							'file_name',att.file_name,
							'file_size',att.file_size,
							'file_signed',att.file_signed,
							'file_uploaded','true',
							'file_path',att.file_path,
							'date_time',f_ver.date_time,
							'signatures',
							(WITH sign AS
							(SELECT
								json_agg(files_t.signatures) AS signatures
							FROM
								(SELECT
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
								WHERE f_sig.file_id=f_ver.file_id
								ORDER BY f_sig.sign_date_time
								) AS files_t
							)					
							SELECT
								CASE
									WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
										json_build_array(
											json_build_object(
												'sign_date_time',f_ver.date_time,
												'check_result',f_ver.check_result,
												'error_str',f_ver.error_str
											)
										)
									ELSE (SELECT sign.signatures FROM sign)
								END
							),
							'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id)
						)
					)
				)
			
			FROM doc_flow_out AS mod_doc_out
			LEFT JOIN doc_flow_attachments AS att ON
				att.file_path='Заключение' AND att.doc_type='doc_flow_out' AND att.doc_id=mod_doc_out.id
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
			LEFT JOIN contracts AS mod_doc_out_contr ON mod_doc_out_contr.id=mod_doc_out.to_contract_id
			LEFT JOIN doc_flow_in_client ON doc_flow_in_client.doc_flow_out_id=mod_doc_out.id				
			WHERE mod_doc_out.to_application_id IN
				(SELECT
					mod_app.id
				FROM applications AS mod_app
				WHERE mod_app.base_application_id = t.application_id 
				)
				AND mod_doc_out.doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
			)
		ELSE NULL
		END AS results_on_modified_documents_list,
		
		app.ext_contract
		
	FROM contracts t
	LEFT JOIN applications AS app ON app.id=t.application_id
	LEFT JOIN contracts AS exp_main_ct ON exp_main_ct.application_id=app.expert_maintenance_base_application_id
	LEFT JOIN construction_types ON construction_types.id=app.construction_type_id
	LEFT JOIN build_types ON build_types.id=app.build_type_id
	LEFT JOIN fund_sources AS fund_sources ON fund_sources.id = coalesce(t.fund_source_id,app.fund_source_id)
	LEFT JOIN
		(
		SELECT
			doc_att.application_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			adf_files.application_id,
			adf_files.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(adf_files.files) AS files
		FROM
			(SELECT
				adf.application_id,
				adf.file_path,
				json_build_object(
					'file_id',adf.file_id,
					'file_name',adf.file_name,
					'file_size',adf.file_size,
					'file_signed',adf.file_signed,
					'file_uploaded','true',
					'file_path',adf.file_path,
					'date_time',adf.date_time,
					'signatures',
				
					(WITH
					sign AS (SELECT
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
						WHERE f_sig.file_id=adf.file_id
						ORDER BY f_sig.sign_date_time
						) AS files_t
					)
					SELECT
						CASE
							WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
								json_build_array(
									json_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE (SELECT sign.signatures FROM sign)
						END
					),
					'file_signed_by_client',adf.file_signed_by_client
					--'require_client_sig',app_fd.require_client_sig
				) AS files
			FROM application_document_files adf			
			--LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			--LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
		
			WHERE adf.document_type='documents'			
			ORDER BY adf.application_id,adf.file_path,adf.date_time
			)  AS adf_files
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf_files.file_path
		GROUP BY adf_files.application_id,adf_files.file_path,app_fd.id
		ORDER BY adf_files.application_id,adf_files.file_path
		)  AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=app.id
	
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN expertise_reject_types AS rt ON rt.id=t.expertise_reject_type_id
	LEFT JOIN departments AS dp ON dp.id=t.main_department_id
	LEFT JOIN employees AS exp_empl ON exp_empl.id=t.main_expert_id
	LEFT JOIN contracts AS prim_contr ON prim_contr.id=t.primary_contract_id
	LEFT JOIN contracts AS modif_prim_contr ON modif_prim_contr.id=t.modif_primary_contract_id
	
	LEFT JOIN applications b_app ON b_app.id=app.base_application_id
	--LEFT JOIN applications exp_maint_base ON exp_maint_base.id=exp_maint.expert_maintenance_base_application_id

	--LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;



-- ******************* update 01/10/2020 14:15:00 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактное)' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				-- зависит от типа: enterprise - name, pboul&&person - name_full
				CASE
					WHEN app.applicant->>'client_type'='enterprise' THEN coalesce(coalesce(app.applicant->>'name',app.applicant->>'name_full'),'<без наименования>')
					ELSE coalesce(app.applicant->>'name_full','<без наименования>')
				END||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
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



-- ******************* update 01/10/2020 14:47:23 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактное)' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				-- зависит от типа: enterprise - name, pboul&&person - name_full
				CASE
					WHEN app.applicant->>'client_type'='enterprise' THEN coalesce(coalesce(app.applicant->>'name',app.applicant->>'name_full'),'<без наименования>')
					ELSE coalesce(app.applicant->>'name_full','<без наименования>')
				END||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||coalesce(app.constr_name,'<неизвестный объект>')
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



-- ******************* update 01/10/2020 14:48:53 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактное)' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
					
					ELSE ''
				END||', '||coalesce(app.constr_name,'<неизвестный объект>')
				,
				-- зависит от типа: enterprise - name, pboul&&person - name_full
				CASE
					WHEN app.applicant->>'client_type'='enterprise' THEN coalesce(coalesce(app.applicant->>'name',app.applicant->>'name_full'),'<без наименования>')
					ELSE coalesce(app.applicant->>'name_full','<без наименования>')
				END||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
					ELSE ''
				END||' по объекту '||coalesce(app.constr_name,'<неизвестный объект>')
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



-- ******************* update 01/10/2020 15:05:24 ******************
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
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
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
					', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = enum_doc_flow_out_client_types_val(NEW.doc_flow_out_client_type,'ru')||
					CASE WHEN v_ext_contract THEN ' (внеконтракт)' ELSE '' END;
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
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
				
				-- зависит от типа: enterprise - name, pboul&&person - name_full
				CASE
					WHEN v_applicant->>'client_type'='enterprise' THEN coalesce(coalesce(v_applicant->>'name',v_applicant->>'name_full'),'<без наименования>')
					ELSE coalesce(v_applicant->>'name_full','<без наименования>')
				END,
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
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
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
					WHERE fld.obj->>'dataType'='employees'
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



-- ******************* update 01/10/2020 15:08:24 ******************
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
					WHERE fld.obj->>'dataType'='employees'
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



-- ******************* update 01/10/2020 15:08:53 ******************
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
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
						CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактному) ' ELSE '' END||
					CASE
						WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
						WHEN app.service_type='modified_documents' THEN 'Измененная документация'
						
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
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
				'Новое заявление'||
					CASE WHEN coalesce(app.ext_contract,FALSE) THEN ' (внеконтрактное)' ELSE '' END
					||': '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'Измененная документация'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
					
					ELSE ''
				END||', '||coalesce(app.constr_name,'<неизвестный объект>')
				,
				-- зависит от типа: enterprise - name, pboul&&person - name_full
				coalesce(app.applicant->>'name',app.applicant->>'name_full')
				/*CASE
					WHEN app.applicant->>'client_type'='enterprise' THEN coalesce(coalesce(app.applicant->>'name',app.applicant->>'name_full'),'<без наименования>')
					ELSE coalesce(app.applicant->>'name_full','<без наименования>')
				END*/
				||' просит провести '||
				CASE
					WHEN app.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
					WHEN app.service_type='modified_documents' THEN 'проверку измененной документации'
				
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
					ELSE ''
				END||' по объекту '||coalesce(app.constr_name,'<неизвестный объект>')
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



-- ******************* update 05/10/2020 16:28:58 ******************
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
	v_service_type service_types;
	v_expertise_type expertise_types;
	v_ext_contract bool;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
			
		END IF;
					
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
			
				--Создание Нового КОНТРАКТА
				IF NEW.application_resolution_state='waiting_for_contract'
					--это для измененной документации
					OR NEW.application_resolution_state='expertise'
				THEN
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
							ELSE  'pd'::document_types
						END,
						app.office_id,
						app.service_type,
						app.expertise_type,
						app.ext_contract						
					
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
						v_office_id,
						v_service_type,
						v_expertise_type,
						v_ext_contract
					
					FROM applications AS app
					LEFT JOIN contracts AS p_contr ON p_contr.application_id=app.primary_application_id
					LEFT JOIN contracts AS mp_contr ON mp_contr.application_id=app.modif_primary_application_id
					WHERE app.id=v_application_id;
				
					--applicant -->> client
					UPDATE clients
					SET
						name		= substr(v_app_applicant->>'name',1,100),
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
						client_type	= 
							CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
							ELSE (v_app_applicant->>'client_type')::client_types
							END,
						base_document_for_contract = v_app_applicant->>'base_document_for_contract',
						person_id_paper	= v_app_applicant->'person_id_paper',
						person_registr_paper = v_app_applicant->'person_registr_paper'
					WHERE (inn=v_app_applicant->>'inn' AND kpp=v_app_applicant->>'kpp')
					--name = v_app_applicant->>'name' OR 
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
							CASE WHEN v_app_applicant->>'name' IS NULL THEN v_app_applicant->>'name_full'
							ELSE v_app_applicant->>'name'
							END,
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
							CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
							ELSE (v_app_applicant->>'client_type')::client_types
							END,
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
						v_new_contract_number = contracts_next_number(v_service_type,now()::date,v_ext_contract);
					END IF;
				
					--Номер экспертного заключения
					--'\D+.*$'
					--Если внеконтракт, то тот же номер оставляем
					IF v_ext_contract THEN
						v_expertise_result_number = v_new_contract_number;
					ELSE
						v_expertise_result_number = contracts_expertise_result_number(v_new_contract_number, now()::date);
					END IF;	
				
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
					WHERE services.service_type=v_service_type
						AND
						(v_expertise_type IS NULL
						OR services.expertise_type=v_expertise_type
						)
					LIMIT 1
					;
								
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
						user_id,
						service_type)
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
					
						v_app_user_id,
						v_service_type
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
			END IF;					
			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		--статус
		--DELETE FROM doc_flow_in_processes WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
		--задачи
		--DELETE FROM doc_flow_tasks WHERE (register_doc->>'dataType')::data_types='doc_flow_examinations'::data_types AND (register_doc->'keys'->>'id')::int=NEW.id;
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
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
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_examinations_process() OWNER TO expert72;


-- ******************* update 05/10/2020 16:34:02 ******************
﻿-- Function: contracts_ext_to_contract(in_ext_contract_id int)

-- DROP FUNCTION contracts_ext_to_contract(in_ext_contract_id int);

/**
 * Копирование всех документов из внеконтракта в контракт
 */
CREATE OR REPLACE FUNCTION contracts_ext_to_contract(in_ext_contract_id int)
  RETURNS void AS
$BODY$
DECLARE
	v_application_id int;  
	v_service_type service_types;
	v_contract_number text;
BEGIN
	SELECT		
		application_id
		,service_type
	INTO
		v_application_id
		,v_service_type
	FROM contracts
	WHERE id = in_ext_contract_id;

	-- applications->ext_contract
	UPDATE applications
	SET
		ext_contract = FALSE
	WHERE id = v_application_id;

	-- doc_flow_in->ext_contract
	UPDATE doc_flow_in
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_in_next_num(doc_flow_in.doc_flow_type_id,FALSE)
	WHERE from_application_id = v_application_id;
		
	-- doc_flow_out->ext_contract Исправить номер
	UPDATE doc_flow_out
	SET
		ext_contract = FALSE
		,reg_number = doc_flow_out_next_num(doc_flow_out.doc_flow_type_id,FALSE)
	WHERE to_application_id = v_application_id;
	
	-- doc_flow_in_client NEW reg_number
	UPDATE doc_flow_in_client
	SET reg_number = (SELECT reg_number FROM doc_flow_out AS t WHERE t.id=doc_flow_in_client.doc_flow_out_id)
	WHERE application_id = v_application_id;

	UPDATE doc_flow_out_client
	SET reg_number = (SELECT reg_number FROM doc_flow_in AS t WHERE t.from_doc_flow_out_client_id=doc_flow_out_client.id)
	WHERE application_id = v_application_id;
	
	
	-- Контракт номер и номер экспертного заключения
	v_contract_number = contracts_next_number(v_service_type,now()::date,FALSE);
	UPDATE contracts
	SET
		contract_number = v_contract_number
		,expertise_result_number = contracts_expertise_result_number(v_contract_number,now()::date)
	WHERE id = in_ext_contract_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_ext_to_contract(in_ext_contract_id int) OWNER TO expert72;


-- ******************* update 05/10/2020 16:55:05 ******************
-- VIEW: document_templates_list

DROP VIEW document_templates_list;

CREATE OR REPLACE VIEW document_templates_list AS
	SELECT
		tmpl.id,
		tmpl.document_type,
		tmpl.service_type,
		tmpl.expertise_type,
		tmpl.create_date,
		tmpl.construction_type_id,
		construction_types_ref(ct) AS construction_types_ref,		
		tmpl.comment_text		
		
	FROM document_templates AS tmpl
	LEFT JOIN construction_types AS ct ON ct.id=tmpl.construction_type_id
	ORDER BY
		tmpl.document_type,
		tmpl.service_type,
		ct.id,
		tmpl.create_date DESC
	;
	
ALTER VIEW document_templates_list OWNER TO expert72;

