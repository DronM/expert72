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
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
	
		IF NEW.state='sent' THEN
		
			IF NOT const_client_lk_val() OR const_debug_val() THEN
				--main programm
				--application head
				SELECT
					applicant,
					customer,
					contractors
				INTO
					v_applicant,
					v_customer,
					v_contractors
				FROM applications
				WHERE id = NEW.application_id;
		
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
			
			END IF;
			
			IF const_client_lk_val() OR const_debug_val() THEN			
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
				);
				
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
ALTER FUNCTION application_processes_process() OWNER TO ;

