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
ALTER FUNCTION application_processes_process() OWNER TO ;

