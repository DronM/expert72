-- Function: client_payments_process()

-- DROP FUNCTION client_payments_process();

CREATE OR REPLACE FUNCTION client_payments_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_pay_cnt int;
	v_work_end_date timestampTZ;
	v_application_id int;
	v_user_id int;
	v_document_type document_types;
	v_linked_app int;
	v_linked_contract int;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		
		--ПРИ ПЕРВОЙ ОПЛАТЕ УСТАНОВИМ ДАТУ ДАЧАЛА/ОКОНЧАНИЯ РАБОТ
		SELECT count(*) INTO v_pay_cnt FROM client_payments WHERE contract_id=NEW.contract_id;

		IF v_pay_cnt = 1 THEN
			SELECT
				t.application_id,
				contracts_work_end_date(applications.office_id, t.date_type, now(), t.expertise_day_count),
				t.document_type,
				coalesce(applications.base_application_id,applications.derived_application_id)
			INTO
				v_application_id,
				v_work_end_date,
				v_document_type,
				v_linked_app
			FROM contracts t
			LEFT JOIN applications ON applications.id=t.application_id
			WHERE t.id=NEW.contract_id;
			
			UPDATE contracts AS contr_main
			SET
				work_start_date = now(),
				work_end_date = v_work_end_date
			WHERE id=NEW.contract_id;
			
			IF NEW.employee_id IS NOT NULL THEN
				SELECT user_id INTO v_user_id FROM employees WHERE id=NEW.employee_id;
			END IF;
			
			IF v_user_id IS NULL THEN
				SELECT id INTO v_user_id FROM users WHERE role_id='admin' LIMIT 1;
			END IF;
			
			--Начало работ - статус
			--Устанавливается автоматически из загрузки оплат
			INSERT INTO application_processes
			(application_id, date_time, state, user_id, end_date_time)
			VALUES (v_application_id, now(), 'expertise'::application_states, v_user_id, v_work_end_date);
			
			--А если это ПД и есть связная достоверность - сменить там тоже
			IF v_document_type='pd'::document_types AND v_linked_app IS NOT NULL THEN
				SELECT
					t.id,
					contracts_work_end_date(applications.office_id, t.date_type, now(), t.expertise_day_count)
				INTO
					v_linked_contract,
					v_work_end_date
				FROM contracts t
				LEFT JOIN applications ON applications.id=t.application_id
				WHERE t.application_id=v_linked_app;
				
				UPDATE contracts
				SET
					work_start_date = now(),
					work_end_date = v_work_end_date
				WHERE id=v_linked_contract;
				
				INSERT INTO application_processes
				(application_id, date_time, state, user_id, end_date_time)
				VALUES (v_linked_app, now(), 'expertise'::application_states, v_user_id, v_work_end_date);
				
			END IF;
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION client_payments_process() OWNER TO ;

