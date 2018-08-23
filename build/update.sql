
-- ******************* update 07/08/2018 15:41:54 ******************
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
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION client_payments_process() OWNER TO expert72;


-- ******************* update 08/08/2018 11:34:36 ******************
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
		contracts_ref(contracts) AS from_contracts_ref,
		doc_flow_in.from_application_id AS from_application_id,
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
		END AS sender_construction_name				
		
		
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

-- ******************* update 08/08/2018 11:36:05 ******************
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
		END AS sender_construction_name				
		
		
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

-- ******************* update 08/08/2018 12:15:47 ******************
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
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
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
								')'||') '||sub.comment_text
							,',')
							FROM (
							SELECT
								person_init(employees.name,FALSE) AS name,
								max(expert_works.date_time)::date AS d,
								expert_works.comment_text
							FROM expert_works
							LEFT JOIN employees ON employees.id=expert_works.expert_id
							WHERE contract_id=t.id AND section_id=sec.section_id
							GROUP BY employees.name,expert_works.comment_text
							) AS sub	
						)
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
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

-- ******************* update 08/08/2018 13:05:17 ******************
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
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
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
						'experts_list',
						(
							SELECT string_agg(person_init(employees.name,FALSE)||'('||
								CASE WHEN EXTRACT(DAY FROM expert_works.date_time)<10 THEN '0'||EXTRACT(DAY FROM expert_works.date_time)::text ELSE EXTRACT(DAY FROM expert_works.date_time)::text END ||
								'/'||
								CASE WHEN EXTRACT(MONTH FROM expert_works.date_time)<10 THEN '0'||EXTRACT(MONTH FROM expert_works.date_time)::text ELSE EXTRACT(MONTH FROM expert_works.date_time)::text END ||	
								')'||') '||expert_works.comment_text
							,',')
						FROM 
						(
							SELECT
								t.expert_id,
								t.section_id,
								max(t.date_time) AS d
							FROM expert_works AS t
							WHERE t.contract_id=t.id
							GROUP BY t.expert_id,t.section_id
						) AS ew_last
						LEFT JOIN expert_works ON
							expert_works.date_time=ew_last.d
							AND expert_works.expert_id=ew_last.expert_id
							AND expert_works.section_id=ew_last.section_id
						LEFT JOIN employees ON employees.id=expert_works.expert_id
						)
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
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

-- ******************* update 08/08/2018 13:52:44 ******************
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
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
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
								')'||') '||sub.comment_text
							,',')
							FROM (
							SELECT
								person_init(employees.name,FALSE) AS name,
								max(expert_works.date_time)::date AS d,
								expert_works.comment_text
							FROM expert_works
							LEFT JOIN employees ON employees.id=expert_works.expert_id
							WHERE contract_id=t.id AND section_id=sec.section_id
							GROUP BY employees.name,expert_works.comment_text
							) AS sub	
						)
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
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

-- ******************* update 08/08/2018 13:54:45 ******************
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
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
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
						'experts_list',
						/*
						(
							SELECT string_agg(sub.name||'('||
								CASE WHEN EXTRACT(DAY FROM sub.d)<10 THEN '0'||EXTRACT(DAY FROM sub.d)::text ELSE EXTRACT(DAY FROM sub.d)::text END ||
								'/'||
								CASE WHEN EXTRACT(MONTH FROM sub.d)<10 THEN '0'||EXTRACT(MONTH FROM sub.d)::text ELSE EXTRACT(MONTH FROM sub.d)::text END ||	
								')'||') '||sub.comment_text
							,',')
							FROM (
							SELECT
								person_init(employees.name,FALSE) AS name,
								max(expert_works.date_time)::date AS d,
								expert_works.comment_text
							FROM expert_works
							LEFT JOIN employees ON employees.id=expert_works.expert_id
							WHERE contract_id=t.id AND section_id=sec.section_id
							GROUP BY employees.name,expert_works.comment_text
							) AS sub	
						)
						*/
						(SELECT
							string_agg(expert_works.comment_text||'('||person_init(employees.name,FALSE)||to_char(expert_works.date_time,'DD/MM/YY')||')',', ')
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
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
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

-- ******************* update 08/08/2018 16:14:06 ******************
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
					client_type	= 
						CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
						ELSE (v_app_applicant->>'client_type')::client_types
						END,
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
						CASE WHEN v_app_applicant->>'client_type' IS NULL THEN 'enterprise'
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

-- ******************* update 08/08/2018 16:17:16 ******************
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
					client_type	= 
						CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
						ELSE (v_app_applicant->>'client_type')::client_types
						END,
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

-- ******************* update 08/08/2018 16:20:56 ******************
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
					client_type	= 
						CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
						ELSE (v_app_applicant->>'client_type')::client_types
						END,
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
						CASE WHEN v_app_applicant->>'name' IS NULL v_app_applicant->>'name_full'
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

-- ******************* update 08/08/2018 16:21:14 ******************
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
					client_type	= 
						CASE WHEN v_app_applicant->>'client_type' IS NULL OR v_app_applicant->>'client_type'='on' THEN 'enterprise'
						ELSE (v_app_applicant->>'client_type')::client_types
						END,
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

-- ******************* update 08/08/2018 16:40:54 ******************
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
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
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
						'experts_list',
						/*
						(
							SELECT string_agg(sub.name||'('||
								CASE WHEN EXTRACT(DAY FROM sub.d)<10 THEN '0'||EXTRACT(DAY FROM sub.d)::text ELSE EXTRACT(DAY FROM sub.d)::text END ||
								'/'||
								CASE WHEN EXTRACT(MONTH FROM sub.d)<10 THEN '0'||EXTRACT(MONTH FROM sub.d)::text ELSE EXTRACT(MONTH FROM sub.d)::text END ||	
								')'||') '||sub.comment_text
							,',')
							FROM (
							SELECT
								person_init(employees.name,FALSE) AS name,
								max(expert_works.date_time)::date AS d,
								expert_works.comment_text
							FROM expert_works
							LEFT JOIN employees ON employees.id=expert_works.expert_id
							WHERE contract_id=t.id AND section_id=sec.section_id
							GROUP BY employees.name,expert_works.comment_text
							) AS sub	
						)
						*/
						(SELECT
							string_agg(expert_works.comment_text||'('||person_init(employees.name,FALSE)||to_char(expert_works.date_time,'DD/MM/YY')||')',', ')
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
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
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
	--LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;

-- ******************* update 16/08/2018 09:05:47 ******************

		CREATE TABLE user_certificates
		(user_id int REFERENCES users(id),fingerprint  varchar(40),CONSTRAINT user_certificates_pkey PRIMARY KEY (user_id,fingerprint)
		);
		ALTER TABLE user_certificates OWNER TO expert72;

-- ******************* update 16/08/2018 09:08:03 ******************
﻿-- Function: user_certificate_insert(in_user_id int, in_fingerprint varchar(40))

-- DROP FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40));

CREATE OR REPLACE FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40))
  RETURNS void AS
$$
	INSERT INTO user_certificates VALUES (in_user_id, in_fingerprint)
	ON CONFLICT (user_id,fingerprint) DO NOTHING;
	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40)) OWNER TO expert72;

-- ******************* update 16/08/2018 10:06:22 ******************

		CREATE TABLE user_certificates
		(fingerprint  varchar(40),user_id int REFERENCES users(id),date_time timestampTZ NOT NULL,CONSTRAINT user_certificates_pkey PRIMARY KEY (fingerprint,user_id)
		);
		ALTER TABLE user_certificates OWNER TO expert72;


-- ******************* update 16/08/2018 10:08:35 ******************
﻿-- Function: user_certificate_insert(in_user_id int, in_fingerprint varchar(40))

-- DROP FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40));

CREATE OR REPLACE FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40))
  RETURNS void AS
$$
	INSERT INTO user_certificates VALUES (in_fingerprint,in_user_id,now())
	ON CONFLICT (fingerprint,user_id) DO
	UPDATE user_certificates SET date_time=now()
	WHERE fingerprint=in_fingerprint AND user_id=in_user_id;
	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40)) OWNER TO expert72;

-- ******************* update 16/08/2018 10:09:13 ******************
﻿-- Function: user_certificate_insert(in_user_id int, in_fingerprint varchar(40))

-- DROP FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40));

CREATE OR REPLACE FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40))
  RETURNS void AS
$$
	INSERT INTO user_certificates VALUES (in_fingerprint,in_user_id,now())
	ON CONFLICT (fingerprint,user_id) DO UPDATE
		SET date_time=now()
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40)) OWNER TO expert72;

-- ******************* update 16/08/2018 12:11:47 ******************

		CREATE TABLE user_certificates
		(id serial,fingerprint  varchar(40) NOT NULL,user_id int NOT NULL REFERENCES users(id),date_time timestampTZ NOT NULL,date_time_from timestampTZ NOT NULL,date_time_to timestampTZ NOT NULL,subject_cert jsonb,issuer_cert jsonb,CONSTRAINT user_certificates_pkey PRIMARY KEY (id)
		);
	DROP INDEX IF EXISTS user_certificates_fingerprint_user_idx;
	CREATE UNIQUE INDEX user_certificates_fingerprint_user_idx
	ON user_certificates(fingerprint,user_id);
		ALTER TABLE user_certificates OWNER TO expert72;


-- ******************* update 16/08/2018 12:12:41 ******************

		ALTER TABLE file_verification ADD COLUMN sign_date_time timestampTZ,ADD COLUMN user_certificate_id int REFERENCES user_certificates(id);
--Refrerece type
CREATE OR REPLACE FUNCTION user_certificates_ref(user_certificates)
  RETURNS json AS
$$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.fingerprint,
		'dataType','user_certificates'
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION user_certificates_ref(user_certificates) OWNER TO expert72;	
	
-- ******************* update 16/08/2018 12:15:41 ******************
﻿-- Function: user_certificate_insert(in_user_id int, in_fingerprint varchar(40))

 DROP FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40));
/*
CREATE OR REPLACE FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40))
  RETURNS void AS
$$
	INSERT INTO user_certificates VALUES (in_fingerprint,in_user_id,now())
	ON CONFLICT (fingerprint,user_id) DO UPDATE
		SET date_time=now()
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION user_certificate_insert(in_user_id int, in_fingerprint varchar(40)) OWNER TO expert72;
*/

-- ******************* update 16/08/2018 18:09:25 ******************
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
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_approvements_list OWNER TO expert72;

-- ******************* update 20/08/2018 15:37:10 ******************

		CREATE TABLE file_verifications
		(id serial,file_id  varchar(36) NOT NULL,date_time timestampTZ,check_result bool,check_time  numeric(15,4),error_str text,CONSTRAINT file_verifications_pkey PRIMARY KEY (id)
		);
		ALTER TABLE file_verifications OWNER TO expert72;
		CREATE TABLE file_signatures
		(id serial,file_verification_id int REFERENCES file_verifications(id),signature_file_id  varchar(36) NOT NULL,sign_date_time timestampTZ,user_certificate_id int REFERENCES user_certificates(id),CONSTRAINT file_signatures_pkey PRIMARY KEY (id)
		);
		ALTER TABLE file_signatures OWNER TO expert72;

-- ******************* update 20/08/2018 15:42:13 ******************

		CREATE TABLE file_verifications
		(file_id  varchar(36),date_time timestampTZ,check_result bool,check_time  numeric(15,4),error_str text,CONSTRAINT file_verifications_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verifications OWNER TO expert72;
		CREATE TABLE file_signatures
		(file_id  varchar(36),signature_file_id  varchar(36),sign_date_time timestampTZ,user_certificate_id int REFERENCES user_certificates(id),CONSTRAINT file_signatures_pkey PRIMARY KEY (file_id,signature_file_id)
		);
		ALTER TABLE file_signatures OWNER TO expert72;


-- ******************* update 22/08/2018 12:59:33 ******************
-- Function: application_document_files_process()

-- DROP FUNCTION application_document_files_process();

CREATE OR REPLACE FUNCTION application_document_files_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_verifications WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_document_files_process() OWNER TO expert72;


-- ******************* update 22/08/2018 13:06:41 ******************
-- Function: file_verifications_process()

-- DROP FUNCTION file_verifications_process();

CREATE OR REPLACE FUNCTION file_verifications_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_signatures WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION file_verifications_process() OWNER TO expert72;


-- ******************* update 22/08/2018 13:07:47 ******************
-- Trigger: file_verifications_trigger on file_verifications

-- DROP TRIGGER file_verifications_before_trigger ON file_verifications;

CREATE TRIGGER file_verifications_before_trigger
  BEFORE DELETE
  ON file_verifications
  FOR EACH ROW
  EXECUTE PROCEDURE file_verifications_process();


-- ******************* update 22/08/2018 13:13:28 ******************
-- Trigger: file_verifications_trigger on file_verifications

-- DROP TRIGGER file_verifications_before_trigger ON file_verifications;

CREATE TRIGGER file_verifications_before_trigger
  BEFORE DELETE
  ON file_verifications
  FOR EACH ROW
  EXECUTE PROCEDURE file_verifications_process();

