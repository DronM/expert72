
-- ******************* update 25/06/2018 14:44:44 ******************

		UPDATE views SET
			c='ExpertiseRejectType_Controller',
			f='get_list',
			t='ExpertiseRejectTypeList',
			section='Справочники',
			descr='Виды отрицательных заключений',
			limited=FALSE
		WHERE id='10024';
	
-- ******************* update 25/06/2018 16:41:25 ******************
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
ALTER FUNCTION client_payments_process() OWNER TO expert72;


-- ******************* update 25/06/2018 16:42:47 ******************
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
ALTER FUNCTION client_payments_process() OWNER TO expert72;


-- ******************* update 25/06/2018 17:17:53 ******************

		ALTER TABLE contracts ADD COLUMN in_estim_cost  numeric(15,2),ADD COLUMN in_estim_cost_recommend  numeric(15,2),ADD COLUMN cur_estim_cost  numeric(15,2),ADD COLUMN cur_estim_cost_recommend  numeric(15,2);


-- ******************* update 25/06/2018 17:19:20 ******************
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
		t.cur_estim_cost_recommend
		
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
