-- Function: client_payments_process()

-- DROP FUNCTION client_payments_process();

CREATE OR REPLACE FUNCTION client_payments_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_pay_cnt int;
	v_work_end_date timestampTZ;
	v_expert_work_end_date timestampTZ;
	v_application_id int;
	v_user_id int;
	v_simult_contr_id int;
	v_simult_contr_work_end_date timestampTZ;
	v_simult_app_id int;
	v_cost_eval_simult bool;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		
		--ПРИ ПЕРВОЙ ОПЛАТЕ УСТАНОВИМ ДАТУ ДАЧАЛА/ОКОНЧАНИЯ РАБОТ
		SELECT count(*) INTO v_pay_cnt FROM client_payments WHERE contract_id=NEW.contract_id;

		IF v_pay_cnt = 1 THEN
			SELECT
				t.application_id,
				contracts_work_end_date(applications.office_id, t.date_type, NEW.pay_date::timestampTZ, t.expertise_day_count),
				contracts_work_end_date(applications.office_id, t.date_type, NEW.pay_date::timestampTZ, t.expert_work_day_count),
				simult_contr.id,
				CASE WHEN simult_contr.id IS NOT NULL THEN
					contracts_work_end_date(cost_eval_app.office_id, simult_contr.date_type, NEW.pay_date::timestampTZ, simult_contr.expertise_day_count)
				ELSE NULL
				END,
				cost_eval_app.id,
				(t.document_type='cost_eval_validity' AND applications.cost_eval_validity_simult)
			INTO
				v_application_id,
				v_work_end_date,
				v_expert_work_end_date,
				v_simult_contr_id,
				v_simult_contr_work_end_date,
				v_simult_app_id,
				v_cost_eval_simult
			FROM contracts t
			LEFT JOIN applications ON applications.id=t.application_id
			LEFT JOIN applications AS cost_eval_app ON
				cost_eval_app.id=applications.derived_application_id AND coalesce(cost_eval_app.cost_eval_validity_simult,FALSE)
			LEFT JOIN contracts AS simult_contr ON simult_contr.application_id=cost_eval_app.id
			WHERE t.id=NEW.contract_id;
			
			--ВСЕ кроме достоверености, которая вместе с ПД, там все через достоверность
			IF coalesce(v_cost_eval_simult,FALSE)=FALSE THEN
				UPDATE contracts
				SET
					work_start_date = NEW.pay_date,
					work_end_date = v_work_end_date,
					expert_work_end_date = v_expert_work_end_date
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
				VALUES (v_application_id, NEW.pay_date::timestampTZ, 'expertise'::application_states, v_user_id, v_work_end_date);
			
				--А если это ПД и есть связная достоверность ОДНОВРЕМЕННО - сменить там тоже
				IF v_simult_contr_id IS NOT NULL THEN
					UPDATE contracts
					SET
						work_start_date = NEW.pay_date,
						work_end_date = v_simult_contr_work_end_date,
						expert_work_end_date = v_expert_work_end_date
					WHERE id=v_simult_contr_id;
				
					INSERT INTO application_processes
					(application_id, date_time, state, user_id, end_date_time)
					VALUES (v_simult_app_id, NEW.pay_date::timestampTZ, 'expertise'::application_states, v_user_id, v_work_end_date);
				
				END IF;
			END IF;	
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION client_payments_process() OWNER TO ;

