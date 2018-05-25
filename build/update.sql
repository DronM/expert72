
-- ******************* update 23/05/2018 10:34:53 ******************

			CREATE TYPE cost_eval_validity_pd_orders AS ENUM (
				'no_pd'			
			,
				'simult_with_pd'			
			,
				'after_pd'			
			);
			ALTER TYPE cost_eval_validity_pd_orders OWNER TO expert72;
	/* function */
	CREATE OR REPLACE FUNCTION enum_cost_eval_validity_pd_orders_val(cost_eval_validity_pd_orders,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='no_pd'::cost_eval_validity_pd_orders AND $2='ru'::locales THEN 'ПД не подлежит'
		WHEN $1='simult_with_pd'::cost_eval_validity_pd_orders AND $2='ru'::locales THEN 'Одновременно с ПД'
		WHEN $1='after_pd'::cost_eval_validity_pd_orders AND $2='ru'::locales THEN 'После ПД'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_cost_eval_validity_pd_orders_val(cost_eval_validity_pd_orders,locales) OWNER TO expert72;		
		ALTER TABLE contracts ADD COLUMN cost_eval_validity_pd_order cost_eval_validity_pd_orders;


-- ******************* update 23/05/2018 10:35:37 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
		app.construction_types_ref,
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		
		t.cost_eval_validity_pd_order
		
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

-- ******************* update 23/05/2018 10:44:54 ******************
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
	v_primary_contract_id int;
	v_modif_primary_contract_id int;	
	v_app_process_dt timestampTZ;
	v_linked_app int;
	v_cost_eval_validity_simult bool;
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
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(NEW.subject_doc->'keys'->>'id')::int;
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
					NEW.end_date_time
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
					p_contr.id,
					mp_contr.id,
					coalesce(app.base_application_id,app.derived_application_id),
					app.cost_eval_validity_simult
				INTO
					v_app_expertise_type,
					v_app_cost_eval_validity,
					v_app_modification,
					v_app_audit,
					v_app_user_id,
					v_app_applicant,
					v_primary_contract_id,
					v_modif_primary_contract_id,
					v_linked_app,
					v_cost_eval_validity_simult
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
				
				
				--Контракт
				INSERT INTO contracts (
					date_time,
					application_id,
					client_id,
					employee_id,
					document_type,
					expertise_type,
					primary_contract_id,
					modif_primary_contract_id,
					cost_eval_validity_pd_order,
					user_id)
				VALUES (
					now(),
					v_application_id,
					v_app_client_id,
					NEW.close_employee_id,
					CASE
						WHEN v_app_expertise_type IS NOT NULL THEN 'pd'::document_types
						WHEN v_app_cost_eval_validity THEN 'cost_eval_validity'::document_types
						WHEN v_app_modification THEN 'modification'::document_types
						WHEN v_app_audit THEN 'audit'::document_types						
					END,
					v_app_expertise_type,
					v_primary_contract_id,
					v_modif_primary_contract_id,
					CASE
						WHEN v_app_cost_eval_validity THEN
							CASE
								WHEN v_cost_eval_validity_simult THEN 'simult_with_pd'::cost_eval_validity_pd_orders
								WHEN v_linked_app IS NOT NULL THEN 'after_pd'::cost_eval_validity_pd_orders
								ELSE 'no_pd'::cost_eval_validity_pd_orders
							END
						ELSE NULL
					END,
					v_app_user_id
				);
				
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

-- ******************* update 23/05/2018 14:09:06 ******************
-- Function: bank_day_next(date,int)

-- DROP FUNCTION bank_day_next(date);

CREATE OR REPLACE FUNCTION bank_day_next(date, int)
  RETURNS date AS
$BODY$
	SELECT
		d::date
	FROM generate_series(
		CASE
			WHEN $2<0 THEN $1-'1 month'::interval
			ELSE $1
		END,
	
		CASE
			WHEN $2>0 THEN $1+'1 month'::interval
			ELSE $1
		END,
		'1 day'::interval
	) AS d
	WHERE
		extract(dow from d::date)>0 AND extract(dow from d::date)<6
		AND d::date NOT IN (SELECT h.date FROM holidays h)
	ORDER BY
		CASE WHEN $2<0 THEN d END DESC,
		CASE WHEN $2>0 THEN d END ASC
	OFFSET abs($2) LIMIT 1
	;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION bank_day_next(date,int) OWNER TO expert72;


-- ******************* update 24/05/2018 09:59:18 ******************

			CREATE TYPE date_types AS ENUM (
				'calendar'			
			,
				'bank'			
			);
			ALTER TYPE date_types OWNER TO expert72;
	/* function */
	CREATE OR REPLACE FUNCTION enum_date_types_val(date_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='calendar'::date_types AND $2='ru'::locales THEN 'Календарные'
		WHEN $1='bank'::date_types AND $2='ru'::locales THEN 'Рабочие'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_date_types_val(date_types,locales) OWNER TO expert72;		
		ALTER TABLE contracts
		ADD COLUMN date_type date_types,
		ADD COLUMN argument_document text,
		ADD COLUMN order_document text,
		ADD COLUMN auth_letter text;


-- ******************* update 24/05/2018 10:04:51 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
		app.construction_types_ref,
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 11:39:55 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
				'id','Contractor_Model',
				'rows',json_build_array(
					json_build_object(
						'fields',
						json_build_object('name',sub.contractors->>'name')
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:30:36 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
							CASE sub.contractors->>'inn' IS NOT NULL THEN ' '||sub.contractors->>'inn'
							ELSE ''
							END||
							CASE sub.contractors->>'kpp' IS NOT NULL THEN '/'||sub.contractors->>'kpp'
							ELSE ''
							END
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:30:54 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
							CASE WHEN sub.contractors->>'inn' IS NOT NULL THEN ' '||sub.contractors->>'inn'
							ELSE ''
							END||
							CASE WHEN sub.contractors->>'kpp' IS NOT NULL THEN '/'||sub.contractors->>'kpp'
							ELSE ''
							END
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:31:27 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
							CASE WHEN sub.contractors->>'inn' IS NOT NULL THEN ' '||sub.contractors->>'inn'
							ELSE ''
							END||
							CASE WHEN sub.contractors->>'kpp' IS NOT NULL THEN '/'||sub.contractors->>'kpp'
							ELSE ''
							END
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:32:13 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
							CASE WHEN sub.contractors->>'inn' IS NOT NULL THEN ' '||sub.contractors->>'inn'
							ELSE ''
							END||
							CASE WHEN sub.contractors->>'kpp' IS NOT NULL THEN '/'||sub.contractors->>'kpp'
							ELSE ''
							END
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:34:32 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
							coalesce(' '||sub.contractors->>'inn','')
							/*
							CASE WHEN sub.contractors->>'inn' IS NOT NULL THEN ' '||sub.contractors->>'inn'
							ELSE ''
							END||
							
							CASE WHEN sub.contractors->>'kpp' IS NOT NULL THEN '/'||sub.contractors->>'kpp'
							ELSE ''
							END
							*/
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:34:48 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
							coalesce(' '||(sub.contractors->>'inn')::text,'')
							/*
							CASE WHEN sub.contractors->>'inn' IS NOT NULL THEN ' '||sub.contractors->>'inn'
							ELSE ''
							END||
							
							CASE WHEN sub.contractors->>'kpp' IS NOT NULL THEN '/'||sub.contractors->>'kpp'
							ELSE ''
							END
							*/
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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 12:35:05 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
		app.constr_name AS constr_name,
		kladr_parse_addr(app.constr_address) AS constr_address,
		app.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 24/05/2018 17:26:33 ******************

		CREATE TABLE doc_flow_out_client_reg_numbers
		(doc_flow_out_client_id int,application_id int,reg_number  varchar(15) NOT NULL,CONSTRAINT doc_flow_out_client_reg_number_pkey PRIMARY KEY (doc_flow_out_client_id,application_id)
		);
		ALTER TABLE doc_flow_out_client_reg_numbers OWNER TO expert72;
		

-- ******************* update 24/05/2018 17:31:57 ******************

		ALTER TABLE doc_flow_in ADD COLUMN from_doc_flow_out_client_id int;


-- ******************* update 24/05/2018 17:41:35 ******************
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
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT OLD.sent) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--main programm
			--application head
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			WHERE app.id = NEW.application_id;
			
			--RAISE EXCEPTION 'v_contract_id=%',v_contract_id;
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			
			--Входящее письмо НАШЕ отделу приема
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id, doc_flow_type_id,
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
				NEW.application_id, pdfn_doc_flow_types_app(),
				v_end_date_time,
				NEW.subject,
				NEW.content,
				departments_ref((SELECT departments FROM departments WHERE id=(SELECT const_app_recipient_department_val()->'keys'->>'id')::int)),
				NEW.id,
				TRUE
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			
			--Рег номер наш - клиенту
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			
--RAISE EXCEPTION 'v_main_expert_id=%',v_main_expert_id;			
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
					(SELECT
						employees.id
					FROM employees
					WHERE 
						department_id = (const_app_recipient_department_val()->'keys'->>'id')::int
						AND post_id=(pdfn_posts_dep_boss()->'keys'->>'id')::int
					),
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					v_recipient				
				);
						
				--reminder boss о новых заявлениях
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
					--employees.department_id=(SELECT const_app_recipient_department_val()->'keys'->>'id')::int
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF v_main_expert_id IS NOT NULL THEN
				--ЕСТь Контракт - Передача на рассмотрение в основной отдел контракта
				/*
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
					v_from_date_time,
					NEW.subject,
					NEW.content,
					(pdfn_doc_flow_importance_types_common()->'keys'->>'id')::int,
					v_end_date_time,
					v_main_expert_id,
					doc_flow_in_ref( (SELECT doc_flow_in FROM doc_flow_in WHERE id=v_doc_flow_in_id) ),
					departments_ref( (SELECT departments FROM departments WHERE id=v_main_department_id) )
				);
				*/
				--сообщение главному эксперту
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				VALUES(
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					v_main_expert_id,
					NEW.subject,
					doc_flow_in_ref((SELECT doc_flow_in
								FROM doc_flow_in
								WHERE id = v_doc_flow_in_id
					))					
				);
			END IF;
						
			--email to admin(ВСЕГДА!!!) && boss(ТОЛЬКО НОВЫЕ)
			IF v_contract_id IS NOT NULL THEN
				v_email_type = 'app_change';
			ELSE
				v_email_type = 'new_app';
			END IF;
			
			
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
				SELECT t.template AS v,t.mes_subject AS s
				FROM email_templates t
				WHERE t.email_type=v_email_type
				)
			SELECT
			users.email,
			employees.name,
			sms_templates_text(
				ARRAY[
					ROW('applicant', (v_applicant->>'name')::text)::template_value,
					ROW('constr_name',v_constr_name)::template_value,
					ROW('id',NEW.application_id)::template_value
				],
				(SELECT v FROM templ)
			) AS mes_body,		
			NEW.subject||' от ' || (v_applicant->>'name')::text,
			v_email_type
			FROM employees
			LEFT JOIN users ON users.id=employees.user_id
			WHERE
				(
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin' OR (role_id='boss' AND v_email_type = 'new_app'))
				)
				AND users.email IS NOT NULL
				--AND users.email_confirmed					
			);				
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 24/05/2018 17:44:38 ******************
-- VIEW: doc_flow_out_client_list

--DROP VIEW doc_flow_out_client_list;

CREATE OR REPLACE VIEW doc_flow_out_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO expert72;

-- ******************* update 24/05/2018 17:45:11 ******************
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
		cl_in_regs.reg_number AS reg_number_in
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 24/05/2018 17:53:53 ******************

		ALTER TABLE doc_flow_out_client ADD COLUMN reg_number_out  varchar(15);


-- ******************* update 24/05/2018 17:59:39 ******************

		CREATE TABLE doc_flow_in_client_reg_numbers
		(doc_flow_in_client_id int,application_id int,reg_number  varchar(30) NOT NULL,CONSTRAINT doc_flow_in_client_reg_numbers_pkey PRIMARY KEY (doc_flow_in_client_id,application_id)
		);
		ALTER TABLE doc_flow_in_client_reg_numbers OWNER TO expert72;
		
-- ******************* update 24/05/2018 18:02:29 ******************
-- VIEW: doc_flow_out_client_list

DROP VIEW doc_flow_out_client_list;

CREATE OR REPLACE VIEW doc_flow_out_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.sent,
		cl_in_regs.reg_number AS reg_number_out
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO expert72;

-- ******************* update 24/05/2018 18:02:50 ******************
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
		cl_in_regs.reg_number AS reg_number_out
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 24/05/2018 18:02:56 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

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
		cl_in_regs.reg_number AS reg_number_out
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 24/05/2018 18:03:32 ******************
-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

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
		cl_in_regs.reg_number AS reg_number_in
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO expert72;

-- ******************* update 24/05/2018 18:03:50 ******************
-- VIEW: doc_flow_out_client_list

DROP VIEW doc_flow_out_client_list;

CREATE OR REPLACE VIEW doc_flow_out_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO expert72;

-- ******************* update 25/05/2018 06:20:36 ******************

		ALTER TABLE contracts ADD COLUMN constr_name text,ADD COLUMN constr_address jsonb,ADD COLUMN constr_technical_features jsonb;


-- ******************* update 25/05/2018 06:22:10 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
		kladr_parse_addr(t.constr_address) AS constr_address,
		t.constr_technical_features,
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
		t.auth_letter		
		
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

-- ******************* update 25/05/2018 06:30:06 ******************
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
	v_primary_contract_id int;
	v_modif_primary_contract_id int;	
	v_app_process_dt timestampTZ;
	v_linked_app int;
	v_cost_eval_validity_simult bool;
	v_constr_name text;
	v_constr_address jsonb;
	v_constr_technical_features jsonb;
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
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(NEW.subject_doc->'keys'->>'id')::int;
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
					NEW.end_date_time
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
					p_contr.id,
					mp_contr.id,
					coalesce(app.base_application_id,app.derived_application_id),
					app.cost_eval_validity_simult,
					app.constr_name,
					app.constr_address,
					app.constr_technical_features					
				INTO
					v_app_expertise_type,
					v_app_cost_eval_validity,
					v_app_modification,
					v_app_audit,
					v_app_user_id,
					v_app_applicant,
					v_primary_contract_id,
					v_modif_primary_contract_id,
					v_linked_app,
					v_cost_eval_validity_simult,
					v_constr_name,
					v_constr_address,
					v_constr_technical_features					
					
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
				
				
				--Контракт
				INSERT INTO contracts (
					date_time,
					application_id,
					client_id,
					employee_id,
					document_type,
					expertise_type,
					primary_contract_id,
					modif_primary_contract_id,
					cost_eval_validity_pd_order,
					constr_name,
					constr_address,
					constr_technical_features,
					user_id)
				VALUES (
					now(),
					v_application_id,
					v_app_client_id,
					NEW.close_employee_id,
					CASE
						WHEN v_app_expertise_type IS NOT NULL THEN 'pd'::document_types
						WHEN v_app_cost_eval_validity THEN 'cost_eval_validity'::document_types
						WHEN v_app_modification THEN 'modification'::document_types
						WHEN v_app_audit THEN 'audit'::document_types						
					END,
					v_app_expertise_type,
					v_primary_contract_id,
					v_modif_primary_contract_id,
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
					v_app_user_id
				);
				
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

-- ******************* update 25/05/2018 06:37:29 ******************
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
	v_primary_contract_id int;
	v_modif_primary_contract_id int;	
	v_app_process_dt timestampTZ;
	v_linked_app int;
	v_cost_eval_validity_simult bool;
	v_constr_name text;
	v_constr_address jsonb;
	v_constr_technical_features jsonb;
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
			SELECT from_application_id INTO v_application_id FROM doc_flow_in WHERE id=(NEW.subject_doc->'keys'->>'id')::int;
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
					NEW.end_date_time
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
					p_contr.id,
					mp_contr.id,
					coalesce(app.base_application_id,app.derived_application_id),
					app.cost_eval_validity_simult,
					app.constr_name,
					app.constr_address,
					app.constr_technical_features					
				INTO
					v_app_expertise_type,
					v_app_cost_eval_validity,
					v_app_modification,
					v_app_audit,
					v_app_user_id,
					v_app_applicant,
					v_primary_contract_id,
					v_modif_primary_contract_id,
					v_linked_app,
					v_cost_eval_validity_simult,
					v_constr_name,
					v_constr_address,
					v_constr_technical_features					
					
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
				
				
				--Контракт
				INSERT INTO contracts (
					date_time,
					application_id,
					client_id,
					employee_id,
					document_type,
					expertise_type,
					primary_contract_id,
					modif_primary_contract_id,
					cost_eval_validity_pd_order,
					constr_name,
					constr_address,
					constr_technical_features,
					user_id)
				VALUES (
					now(),
					v_application_id,
					v_app_client_id,
					NEW.close_employee_id,
					CASE
						WHEN v_app_expertise_type IS NOT NULL THEN 'pd'::document_types
						WHEN v_app_cost_eval_validity THEN 'cost_eval_validity'::document_types
						WHEN v_app_modification THEN 'modification'::document_types
						WHEN v_app_audit THEN 'audit'::document_types						
					END,
					v_app_expertise_type,
					v_primary_contract_id,
					v_modif_primary_contract_id,
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
					v_app_user_id
				);
				
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

-- ******************* update 25/05/2018 06:54:39 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
		t.auth_letter		
		
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

-- ******************* update 25/05/2018 07:40:17 ******************
-- VIEW: applications_dialog

DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
	SELECT
		d.id,
		d.create_dt,
		d.user_id,
		d.expertise_type,
		
		--Для контроллера
		( (d.expertise_type IS NOT NULL OR NOT d.cost_eval_validity OR NOT d.modification OR NOT d.audit) AND d.construction_type_id IS NOT NULL) AS document_exists,
		
		coalesce(d.cost_eval_validity,FALSE) AS cost_eval_validity,
		d.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		construction_types_ref(construction_types) AS construction_types_ref,
		d.applicant,
		d.customer,
		d.contractors,
		d.developer,
		coalesce(contr.constr_name,d.constr_name) AS constr_name,
		coalesce(contr.constr_address,d.constr_address) AS constr_address,
		coalesce(contr.constr_technical_features,d.constr_technical_features) As constr_technical_features,
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN d.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		
		applications_ref(d)->>'descr' AS select_descr,
		
		d.app_print_expertise,
		d.app_print_cost_eval,
		d.app_print_modification,
		d.app_print_audit,
		
		applications_ref(b_app) AS base_applications_ref,
		applications_ref(d_app) AS derived_applications_ref,
		
		applications_ref(d) AS applications_ref,
		d.primary_application_id,
		d.primary_application_reg_number,
		d.modif_primary_application_id,
		d.modif_primary_application_reg_number
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=d.id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN build_types ON build_types.id=d.build_type_id
	LEFT JOIN applications AS b_app ON b_app.id=d.base_application_id
	LEFT JOIN applications AS d_app ON d_app.id=d.derived_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=d.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 25/05/2018 07:40:23 ******************
-- VIEW: applications_dialog

DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
	SELECT
		d.id,
		d.create_dt,
		d.user_id,
		d.expertise_type,
		
		--Для контроллера
		( (d.expertise_type IS NOT NULL OR NOT d.cost_eval_validity OR NOT d.modification OR NOT d.audit) AND d.construction_type_id IS NOT NULL) AS document_exists,
		
		coalesce(d.cost_eval_validity,FALSE) AS cost_eval_validity,
		d.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		construction_types_ref(construction_types) AS construction_types_ref,
		d.applicant,
		d.customer,
		d.contractors,
		d.developer,
		coalesce(contr.constr_name,d.constr_name) AS constr_name,
		coalesce(contr.constr_address,d.constr_address) AS constr_address,
		coalesce(contr.constr_technical_features,d.constr_technical_features) As constr_technical_features,
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN d.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		
		applications_ref(d)->>'descr' AS select_descr,
		
		d.app_print_expertise,
		d.app_print_cost_eval,
		d.app_print_modification,
		d.app_print_audit,
		
		applications_ref(b_app) AS base_applications_ref,
		applications_ref(d_app) AS derived_applications_ref,
		
		applications_ref(d) AS applications_ref,
		d.primary_application_id,
		d.primary_application_reg_number,
		d.modif_primary_application_id,
		d.modif_primary_application_reg_number
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=d.id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN build_types ON build_types.id=d.build_type_id
	LEFT JOIN applications AS b_app ON b_app.id=d.base_application_id
	LEFT JOIN applications AS d_app ON d_app.id=d.derived_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=d.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 25/05/2018 07:41:33 ******************
-- VIEW: applications_dialog

DROP contracts_dialog;
DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
	SELECT
		d.id,
		d.create_dt,
		d.user_id,
		d.expertise_type,
		
		--Для контроллера
		( (d.expertise_type IS NOT NULL OR NOT d.cost_eval_validity OR NOT d.modification OR NOT d.audit) AND d.construction_type_id IS NOT NULL) AS document_exists,
		
		coalesce(d.cost_eval_validity,FALSE) AS cost_eval_validity,
		d.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		construction_types_ref(construction_types) AS construction_types_ref,
		d.applicant,
		d.customer,
		d.contractors,
		d.developer,
		coalesce(contr.constr_name,d.constr_name) AS constr_name,
		coalesce(contr.constr_address,d.constr_address) AS constr_address,
		coalesce(contr.constr_technical_features,d.constr_technical_features) As constr_technical_features,
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN d.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		
		applications_ref(d)->>'descr' AS select_descr,
		
		d.app_print_expertise,
		d.app_print_cost_eval,
		d.app_print_modification,
		d.app_print_audit,
		
		applications_ref(b_app) AS base_applications_ref,
		applications_ref(d_app) AS derived_applications_ref,
		
		applications_ref(d) AS applications_ref,
		d.primary_application_id,
		d.primary_application_reg_number,
		d.modif_primary_application_id,
		d.modif_primary_application_reg_number
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=d.id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN build_types ON build_types.id=d.build_type_id
	LEFT JOIN applications AS b_app ON b_app.id=d.base_application_id
	LEFT JOIN applications AS d_app ON d_app.id=d.derived_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=d.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 25/05/2018 07:41:44 ******************
-- VIEW: applications_dialog

DROP VIEW contracts_dialog;
DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
	SELECT
		d.id,
		d.create_dt,
		d.user_id,
		d.expertise_type,
		
		--Для контроллера
		( (d.expertise_type IS NOT NULL OR NOT d.cost_eval_validity OR NOT d.modification OR NOT d.audit) AND d.construction_type_id IS NOT NULL) AS document_exists,
		
		coalesce(d.cost_eval_validity,FALSE) AS cost_eval_validity,
		d.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		construction_types_ref(construction_types) AS construction_types_ref,
		d.applicant,
		d.customer,
		d.contractors,
		d.developer,
		coalesce(contr.constr_name,d.constr_name) AS constr_name,
		coalesce(contr.constr_address,d.constr_address) AS constr_address,
		coalesce(contr.constr_technical_features,d.constr_technical_features) As constr_technical_features,
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN d.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		
		applications_ref(d)->>'descr' AS select_descr,
		
		d.app_print_expertise,
		d.app_print_cost_eval,
		d.app_print_modification,
		d.app_print_audit,
		
		applications_ref(b_app) AS base_applications_ref,
		applications_ref(d_app) AS derived_applications_ref,
		
		applications_ref(d) AS applications_ref,
		d.primary_application_id,
		d.primary_application_reg_number,
		d.modif_primary_application_id,
		d.modif_primary_application_reg_number
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=d.id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN build_types ON build_types.id=d.build_type_id
	LEFT JOIN applications AS b_app ON b_app.id=d.base_application_id
	LEFT JOIN applications AS d_app ON d_app.id=d.derived_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=d.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 25/05/2018 07:41:57 ******************
-- VIEW: contracts_dialog

DROP VIEW contracts_dialog;

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
		t.auth_letter		
		
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

-- ******************* update 25/05/2018 08:00:39 ******************
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
				'files',t.files
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers as regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 25/05/2018 08:01:01 ******************
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
				'files',t.files
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;

-- ******************* update 25/05/2018 08:01:39 ******************
-- VIEW: doc_flow_in_client_list

--DROP VIEW doc_flow_in_client_list;

CREATE OR REPLACE VIEW doc_flow_in_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.viewed_dt,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO expert72;

-- ******************* update 25/05/2018 08:12:20 ******************
﻿-- Function: doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text)

-- DROP FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text);

CREATE OR REPLACE FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text)
  RETURNS void AS
$$
    UPDATE doc_flow_in_client_reg_numbers
    SET
    	reg_number = in_reg_number_out
    WHERE doc_flow_in_client_id = in_doc_flow_in_client_id;
    IF FOUND THEN
        RETURN;
    END IF;
    BEGIN
        INSERT INTO doc_flow_in_client_reg_numbers (doc_flow_in_client_id,reg_number) VALUES (in_doc_flow_in_client_id,in_reg_number_out);
    EXCEPTION WHEN OTHERS THEN
	    UPDATE doc_flow_in_client_reg_numbers
	    SET
	    	reg_number = in_reg_number_out
	    WHERE doc_flow_in_client_id = in_doc_flow_in_client_id;
    END;
    RETURN;

$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text) OWNER TO expert72;

-- ******************* update 25/05/2018 08:12:41 ******************
﻿-- Function: doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text)

-- DROP FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text);

CREATE OR REPLACE FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text)
  RETURNS void AS
$$
BEGIN
    UPDATE doc_flow_in_client_reg_numbers
    SET
    	reg_number = in_reg_number_out
    WHERE doc_flow_in_client_id = in_doc_flow_in_client_id;
    IF FOUND THEN
        RETURN;
    END IF;
    BEGIN
        INSERT INTO doc_flow_in_client_reg_numbers (doc_flow_in_client_id,reg_number) VALUES (in_doc_flow_in_client_id,in_reg_number_out);
    EXCEPTION WHEN OTHERS THEN
	    UPDATE doc_flow_in_client_reg_numbers
	    SET
	    	reg_number = in_reg_number_out
	    WHERE doc_flow_in_client_id = in_doc_flow_in_client_id;
    END;
    RETURN;
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_client_reg_numbers_insert(in_doc_flow_in_client_id int,in_reg_number_out text) OWNER TO expert72;

-- ******************* update 25/05/2018 09:34:02 ******************
-- VIEW: doc_flow_in_client_list

--DROP VIEW doc_flow_in_client_list;

CREATE OR REPLACE VIEW doc_flow_in_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.viewed_dt,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO expert72;

-- ******************* update 25/05/2018 09:34:09 ******************
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
				'files',t.files
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;
