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
	v_app_state application_states;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			-- ОБРАБАТЫВАЕТ ТОЛЬКО ПРИ ПЕРВОЙ ОПЛАТЕ И ТОЛЬКО если статус = Ожидание оплаты, Ожидание контракта
			-- УСТАНОВИМ ДАТУ ДАЧАЛА/ОКОНЧАНИЯ РАБОТ и сменим статус 
			-- С 2020 года по финансированию бюджет, статус меняется при подписании контракта!!!
			
			SELECT count(*) INTO v_pay_cnt FROM client_payments WHERE contract_id=NEW.contract_id;

			IF v_pay_cnt = 1 THEN
				SELECT pr.state
				FROM application_processes AS pr
				INTO v_app_state
				WHERE pr.application_id = (SELECT ct.application_id FROM contracts ct WHERE ct.id=NEW.contract_id) 
				ORDER BY pr.date_time DESC
				LIMIT 1;
			
				IF v_app_state='waiting_for_contract'
				OR v_app_state='waiting_for_pay' THEN
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
						VALUES (v_application_id, (NEW.pay_date+'23:59:59'::interval)::timestampTZ, 'expertise'::application_states, v_user_id, v_work_end_date);
							
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
				
						--А если уже есть статусы после оплаты (вернулся контракт)
						DELETE FROM application_processes
						WHERE date_time>NEW.pay_date AND application_id=v_application_id AND state='waiting_for_pay';
					END IF;	
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

