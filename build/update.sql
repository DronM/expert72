
-- ******************* update 31/07/2018 06:36:33 ******************

		CREATE TABLE file_verification
		(file_id  varchar(36),date_time timestampTZ,subject_cert text,issuer_cert text,check_time text,check_result  numeric(15,4),CONSTRAINT file_verification_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verification OWNER TO expert72;
		
-- ******************* update 31/07/2018 06:57:20 ******************
Drop Table file_verification;
		CREATE TABLE file_verification
		(file_id  varchar(36),date_time timestampTZ,subject_cert text,issuer_cert text,
		check_result bool,check_time  numeric(15,4),CONSTRAINT file_verification_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verification OWNER TO expert72;
		

-- ******************* update 31/07/2018 07:01:44 ******************
Drop Table file_verification;
		CREATE TABLE file_verification
		(file_id  varchar(36),date_time timestampTZ,
		date_from date, date_to date,
		subject_cert text,issuer_cert text,
		check_result bool,check_time  numeric(15,4),CONSTRAINT file_verification_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verification OWNER TO expert72;
		

-- ******************* update 31/07/2018 07:11:49 ******************
Drop Table file_verification;
		CREATE TABLE file_verification
		(file_id  varchar(36),date_time timestampTZ,
		date_from date, date_to date,
		subject_cert jsonb,issuer_cert jsonb,
		check_result bool,check_time  numeric(15,4),CONSTRAINT file_verification_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verification OWNER TO expert72;
		

-- ******************* update 31/07/2018 07:12:07 ******************
Drop Table file_verification;
		CREATE TABLE file_verification
		(file_id  varchar(36),date_time timestampTZ,
		date_from date, date_to date,
		subject_cert jsonb,issuer_cert jsonb,
		check_result bool,check_time  numeric(15,4),CONSTRAINT file_verification_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verification OWNER TO expert72;
		

-- ******************* update 31/07/2018 07:17:00 ******************
Drop Table file_verification;
		CREATE TABLE file_verification
		(file_id  varchar(36),date_time timestampTZ,
		date_from date, date_to date,
		subject_cert jsonb,issuer_cert jsonb,
		check_result bool,check_time  numeric(15,4),
		error_str text,
		CONSTRAINT file_verification_pkey PRIMARY KEY (file_id)
		);
		ALTER TABLE file_verification OWNER TO expert72;
		

-- ******************* update 01/08/2018 06:47:08 ******************
-- Function: application_document_files_process()

-- DROP FUNCTION application_document_files_process();

CREATE OR REPLACE FUNCTION application_document_files_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_verification WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_document_files_process() OWNER TO expert72;


-- ******************* update 01/08/2018 06:47:12 ******************
-- Trigger: application_document_files_trigger on application_document_files

-- DROP TRIGGER application_document_files_before_trigger ON application_document_files;

CREATE TRIGGER application_document_files_before_trigger
  BEFORE DELETE
  ON application_document_files
  FOR EACH ROW
  EXECUTE PROCEDURE application_document_files_process();


-- ******************* update 01/08/2018 08:38:54 ******************
-- VIEW: office_bank_acc_list

--DROP VIEW office_bank_acc_list;

CREATE OR REPLACE VIEW office_bank_acc_list AS
	SELECT
		off.acc->>'acc_number' AS acc_number,
		off.acc->>'bank_descr' AS bank_descr
	FROM (
	SELECT
		jsonb_array_elements(clients.bank_accounts->'rows')->'fields' AS acc
	FROM clients WHERE clients.id IN (SELECT o.client_id FROM offices o)
	) AS off
	;
	
ALTER VIEW office_bank_acc_list OWNER TO expert72;

-- ******************* update 01/08/2018 08:40:33 ******************
-- VIEW: offices_bank_acc_list

DROP VIEW office_bank_acc_list;

CREATE OR REPLACE VIEW offices_bank_acc_list AS
	SELECT
		off.acc->>'acc_number' AS acc_number,
		off.acc->>'bank_descr' AS bank_descr
	FROM (
	SELECT
		jsonb_array_elements(clients.bank_accounts->'rows')->'fields' AS acc
	FROM clients WHERE clients.id IN (SELECT o.client_id FROM offices o)
	) AS off
	;
	
ALTER VIEW offices_bank_acc_list OWNER TO expert72;

-- ******************* update 01/08/2018 11:43:29 ******************
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
						CASE WHEN v_app_applicant->>'client_type' IS NULL THEN 'enterprise'
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
						(v_app_applicant->>'client_type')::client_types,
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

-- ******************* update 01/08/2018 11:46:50 ******************
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
						CASE WHEN v_app_applicant->>'client_type' IS NULL THEN 'enterprise'
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

-- ******************* update 01/08/2018 15:33:28 ******************

		ALTER TABLE contracts ADD COLUMN primary_contract_reg_number  varchar(20);


-- ******************* update 01/08/2018 15:35:24 ******************
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

-- ******************* update 01/08/2018 16:35:47 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
		(
			(SELECT
				adf.application_id,
				adf.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',adf.file_id,
						'file_name',adf.file_name,
						'file_size',adf.file_size,
						'file_signed',adf.file_signed,
						'file_uploaded','true',
						'file_path',adf.file_path,
						'date_time',adf.date_time,
						'out_file_id',adf_att.file_id
					)
				) AS files
			FROM application_document_files adf
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
			LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			WHERE adf.document_type='documents'
			GROUP BY adf.application_id,adf.file_path,app_fd.id
			ORDER BY app_fd.id)
			UNION ALL
			(SELECT
				d_out.to_application_id AS application_id,
				att.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',att.file_date,
						'out_file_id',att.file_id
					)
				) AS files
			FROM doc_flow_out AS d_out
			LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
			ORDER BY att.file_path,att.file_name)
			
		) AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 01/08/2018 16:35:55 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
		(
			(SELECT
				adf.application_id,
				adf.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',adf.file_id,
						'file_name',adf.file_name,
						'file_size',adf.file_size,
						'file_signed',adf.file_signed,
						'file_uploaded','true',
						'file_path',adf.file_path,
						'date_time',adf.date_time,
						'out_file_id',adf_att.file_id
					)
				) AS files
			FROM application_document_files adf
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
			LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			WHERE adf.document_type='documents'
			GROUP BY adf.application_id,adf.file_path,app_fd.id
			ORDER BY app_fd.id)
			UNION ALL
			(SELECT
				d_out.to_application_id AS application_id,
				att.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',att.file_date,
						'out_file_id',att.file_id
					)
				) AS files
			FROM doc_flow_out AS d_out
			LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
			ORDER BY att.file_path,att.file_name)
			
		) AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 01/08/2018 16:36:56 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
		(
			(SELECT
				adf.application_id,
				adf.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',adf.file_id,
						'file_name',adf.file_name,
						'file_size',adf.file_size,
						'file_signed',adf.file_signed,
						'file_uploaded','true',
						'file_path',adf.file_path,
						'date_time',adf.date_time,
						'out_file_id',adf_att.file_id
					)
				) AS files
			FROM application_document_files adf
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
			LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			WHERE adf.document_type='documents'
			GROUP BY adf.application_id,adf.file_path,app_fd.id
			ORDER BY app_fd.id)
			UNION ALL
			(SELECT
				d_out.to_application_id AS application_id,
				att.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',att.file_date,
						'out_file_id',att.file_id
					)
				) AS files
			FROM doc_flow_out AS d_out
			LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
			GROUP BY d_out.to_application_id,att.file_path,app_fd.id
			ORDER BY att.file_path,att.file_name)
			
		) AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 01/08/2018 16:37:17 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
		(
			(SELECT
				adf.application_id,
				adf.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',adf.file_id,
						'file_name',adf.file_name,
						'file_size',adf.file_size,
						'file_signed',adf.file_signed,
						'file_uploaded','true',
						'file_path',adf.file_path,
						'date_time',adf.date_time,
						'out_file_id',adf_att.file_id
					)
				) AS files
			FROM application_document_files adf
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
			LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			WHERE adf.document_type='documents'
			GROUP BY adf.application_id,adf.file_path,app_fd.id
			ORDER BY app_fd.id)
			UNION ALL
			(SELECT
				d_out.to_application_id AS application_id,
				att.file_path AS folder_descr,
				app_fd.id AS folder_id,
				json_agg(
					json_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'date_time',att.file_date,
						'out_file_id',att.file_id
					)
				) AS files
			FROM doc_flow_out AS d_out
			LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
			LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
			GROUP BY d_out.to_application_id,att.file_path,app_fd.id,att.file_name
			ORDER BY att.file_path,att.file_name)
			
		) AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 01/08/2018 16:46:40 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
		(
			SELECT
				docums.application_id,docums.folder_descr,docums.folder_id,json_agg(docums.fl) AS files
			FROM (
				(SELECT
					adf.application_id,
					adf.file_path AS folder_descr,
					app_fd.id AS folder_id,
					--json_agg(
						json_build_object(
							'file_id',adf.file_id,
							'file_name',adf.file_name,
							'file_size',adf.file_size,
							'file_signed',adf.file_signed,
							'file_uploaded','true',
							'file_path',adf.file_path,
							'date_time',adf.date_time,
							'out_file_id',adf_att.file_id
						) AS fl
					--) AS files
				FROM application_document_files adf
				LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
				LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
				LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
				WHERE adf.document_type='documents'
				--GROUP BY adf.application_id,adf.file_path,app_fd.id
				ORDER BY app_fd.id)
				UNION ALL
				(SELECT
					d_out.to_application_id AS application_id,
					att.file_path AS folder_descr,
					app_fd.id AS folder_id,
					--json_agg(
						json_build_object(
							'file_id',att.file_id,
							'file_name',att.file_name,
							'file_size',att.file_size,
							'file_signed',att.file_signed,
							'file_uploaded','true',
							'file_path',att.file_path,
							'date_time',att.file_date,
							'out_file_id',att.file_id
						) AS fl
					--) AS files
				FROM doc_flow_out AS d_out
				LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
				LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
				--GROUP BY d_out.to_application_id,att.file_path,app_fd.id,att.file_name
				ORDER BY app_fd.id,att.file_name)
			) AS docums			
			GROUP BY docums.application_id,docums.folder_descr,docums.folder_id
		) AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 01/08/2018 16:55:40 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
			adf.application_id,
			adf.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',adf.file_id,
					'file_name',adf.file_name,
					'file_size',adf.file_size,
					'file_signed',adf.file_signed,
					'file_uploaded','true',
					'file_path',adf.file_path,
					'date_time',adf.date_time,
					'out_file_id',adf_att.file_id
				)
			) AS files
		FROM application_document_files adf
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
		LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
		LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
		WHERE adf.document_type='documents'
		GROUP BY adf.application_id,adf.file_path,app_fd.id
		ORDER BY app_fd.id)	
		
		/*
		(
			SELECT
				docums.application_id,docums.folder_descr,docums.folder_id,json_agg(docums.fl) AS files
			FROM (
				(SELECT
					adf.application_id,
					adf.file_path AS folder_descr,
					app_fd.id AS folder_id,
					--json_agg(
						json_build_object(
							'file_id',adf.file_id,
							'file_name',adf.file_name,
							'file_size',adf.file_size,
							'file_signed',adf.file_signed,
							'file_uploaded','true',
							'file_path',adf.file_path,
							'date_time',adf.date_time,
							'out_file_id',adf_att.file_id
						) AS fl
					--) AS files
				FROM application_document_files adf
				LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
				LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
				LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
				WHERE adf.document_type='documents'
				--GROUP BY adf.application_id,adf.file_path,app_fd.id
				ORDER BY app_fd.id)
				UNION ALL
				(SELECT
					d_out.to_application_id AS application_id,
					att.file_path AS folder_descr,
					app_fd.id AS folder_id,
					--json_agg(
						json_build_object(
							'file_id',att.file_id,
							'file_name',att.file_name,
							'file_size',att.file_size,
							'file_signed',att.file_signed,
							'file_uploaded','true',
							'file_path',att.file_path,
							'date_time',att.file_date,
							'out_file_id',att.file_id
						) AS fl
					--) AS files
				FROM doc_flow_out AS d_out
				LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
				LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
				--GROUP BY d_out.to_application_id,att.file_path,app_fd.id,att.file_name
				ORDER BY app_fd.id,att.file_name)
			) AS docums			
			GROUP BY docums.application_id,docums.folder_descr,docums.folder_id
		) AS doc_att
		*/
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 01/08/2018 16:56:08 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

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
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
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
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
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
			adf.application_id,
			adf.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',adf.file_id,
					'file_name',adf.file_name,
					'file_size',adf.file_size,
					'file_signed',adf.file_signed,
					'file_uploaded','true',
					'file_path',adf.file_path,
					'date_time',adf.date_time,
					'out_file_id',adf_att.file_id
				)
			) AS files
		FROM application_document_files adf
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
		LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
		LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
		WHERE adf.document_type='documents'
		GROUP BY adf.application_id,adf.file_path,app_fd.id
		ORDER BY app_fd.id)  AS doc_att	
		
		/*
		(
			SELECT
				docums.application_id,docums.folder_descr,docums.folder_id,json_agg(docums.fl) AS files
			FROM (
				(SELECT
					adf.application_id,
					adf.file_path AS folder_descr,
					app_fd.id AS folder_id,
					--json_agg(
						json_build_object(
							'file_id',adf.file_id,
							'file_name',adf.file_name,
							'file_size',adf.file_size,
							'file_signed',adf.file_signed,
							'file_uploaded','true',
							'file_path',adf.file_path,
							'date_time',adf.date_time,
							'out_file_id',adf_att.file_id
						) AS fl
					--) AS files
				FROM application_document_files adf
				LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
				LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
				LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
				WHERE adf.document_type='documents'
				--GROUP BY adf.application_id,adf.file_path,app_fd.id
				ORDER BY app_fd.id)
				UNION ALL
				(SELECT
					d_out.to_application_id AS application_id,
					att.file_path AS folder_descr,
					app_fd.id AS folder_id,
					--json_agg(
						json_build_object(
							'file_id',att.file_id,
							'file_name',att.file_name,
							'file_size',att.file_size,
							'file_signed',att.file_signed,
							'file_uploaded','true',
							'file_path',att.file_path,
							'date_time',att.file_date,
							'out_file_id',att.file_id
						) AS fl
					--) AS files
				FROM doc_flow_out AS d_out
				LEFT JOIN doc_flow_attachments AS att ON att.doc_id=d_out.id AND att.doc_type='doc_flow_out'
				LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
				--GROUP BY d_out.to_application_id,att.file_path,app_fd.id,att.file_name
				ORDER BY app_fd.id,att.file_name)
			) AS docums			
			GROUP BY docums.application_id,docums.folder_descr,docums.folder_id
		) AS doc_att
		*/
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 02/08/2018 07:40:24 ******************
-- Function: doc_flow_attachments_process()

-- DROP FUNCTION contracts_process();

CREATE OR REPLACE FUNCTION doc_flow_attachments_process()
  RETURNS trigger AS
$BODY$
DECLARE
	FOLDER_OUT text;
	FOLDER_DOCS text;
	FOLDER_RES text;
	v_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF const_client_lk_val() OR const_debug_val() AND NEW.doc_type='doc_flow_out' THEN
			FOLDER_OUT = 'Исходящие';
			FOLDER_DOCS = 'Договорные документы';
			FOLDER_RES = 'Заключение';
		
			SELECT t.to_application_id INTO v_application_id FROM doc_flow_out t WHERE t.id=NEW.doc_id;
			
			IF v_application_id IS NOT NULL THEN
				IF (OLD.file_path=FOLDER_DOCS OR OLD.file_path=FOLDER_RES) AND NEW.file_path=FOLDER_OUT THEN
					DELETE FROM application_document_files WHERE file_id=NEW.file_id;
				
				ELSIF (NEW.file_path=FOLDER_DOCS OR NEW.file_path=FOLDER_RES) AND OLD.file_path=FOLDER_OUT THEN
					INSERT INTO application_document_files
					(
					file_id,
					application_id,
					document_id,
					document_type,
					date_time,
					file_name,
					file_path,
					file_signed,
					file_size
					)
					VALUES (
					NEW.file_id,
					v_application_id,
					0,
					'documents',
					NEW.file_date,
					NEW.file_name,
					NEW.file_path,
					NEW.file_signed,
					NEW.file_size
					);
				ELSIF (OLD.file_path=FOLDER_DOCS OR OLD.file_path=FOLDER_RES) AND (NEW.file_path=FOLDER_DOCS OR NEW.file_path=FOLDER_RES) THEN
					UPDATE application_document_files
						SET file_path=NEW.file_path
					WHERE file_id=NEW.file_id;
					
				END IF;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_attachments_process() OWNER TO expert72;

-- ******************* update 02/08/2018 07:40:28 ******************
-- Trigger: doc_flow_attachments_after_trigger on doc_flow_attachments

-- DROP TRIGGER doc_flow_attachments_after_trigger ON doc_flow_attachments;

 CREATE TRIGGER doc_flow_attachments_after
  AFTER UPDATE
  ON doc_flow_attachments
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_attachments_process();
