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
			
				--НОВЫЙ КОНТРАКТ
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
						END,
						app.office_id,
						app.service_type,
						app.expertise_type						
					
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
						v_expertise_type
					
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
ALTER FUNCTION doc_flow_examinations_process() OWNER TO ;
