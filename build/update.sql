


-- ******************* update 09/10/2019 10:58:16 ******************
-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_type_id int;
	v_id int;
	v_reg_number text;
	v_auto_reg boolean;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
			--статус
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				INSERT INTO doc_flow_out_processes (
					doc_flow_out_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_out_states ELSE 'approving'::doc_flow_out_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);
			ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
				INSERT INTO doc_flow_inside_processes (
					doc_flow_inside_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_inside_states ELSE 'approving'::doc_flow_inside_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);			
			END IF;	
			
			PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--state
			IF NEW.date_time<>OLD.date_time
				OR NEW.end_date_time<>OLD.end_date_time
				OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
				OR NEW.subject_doc<>OLD.subject_doc
				OR NEW.subject<>OLD.subject
			THEN
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					UPDATE doc_flow_out_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					UPDATE doc_flow_inside_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_inside_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				
				END IF;
			END IF;

			IF NEW.close_date_time IS NOT NULL AND OLD.close_date_time IS NULL THEN
				--Все закрыли - задачу ответственному
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				VALUES (
					doc_flow_approvements_ref(NEW),
					now(),NEW.end_date_time,
					NEW.doc_flow_importance_type_id,
					NEW.employee_id,
					employees_ref((SELECT e FROM employees e WHERE e.id=NEW.employee_id)),
					'Ознакомиться с результатом согласования'
				);
			
				--сменим статус при закрытии			
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					INSERT INTO doc_flow_out_processes (
						doc_flow_out_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_out_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
			
					--Если это исх.письмо по контракту (замечания) - сразу зарегистрируем
					--Добавлено 08/06/19: или заключение экспертизы - сразу зарегистрируем
					IF ((NEW.close_result)::text)::doc_flow_out_states='approved'::doc_flow_out_states
					AND NEW.subject_doc->>'dataType'='doc_flow_out'
					THEN
						SELECT
							t.doc_flow_type_id,
							t.reg_number,
							t.id,
							
							-- 08/06/19 + contr_close (09/10/19 Только достоверность!)
							(							
								(
								t.doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
								AND
								app.cost_eval_validity
								)
							OR
							-- contr Ответы на замечания все всегда!!!
							t.doc_flow_type_id=(pdfn_doc_flow_types_contr()->'keys'->>'id')::int
							)
						INTO 
							v_doc_flow_type_id,
							v_reg_number,
							v_id,
							v_auto_reg
						FROM doc_flow_out t
						LEFT JOIN applications AS app ON app.id=t.to_application_id				
						WHERE t.id = (NEW.subject_doc->'keys'->>'id')::int;
				
						
						IF v_auto_reg THEN
							IF v_reg_number IS NULL THEN
								UPDATE doc_flow_out
								SET reg_number=doc_flow_out_next_num(v_doc_flow_type_id)
								WHERE id=v_id;
							END IF;
					
							INSERT INTO doc_flow_registrations
							(date_time,subject_doc,employee_id,comment_text)
							VALUES (
							now()+'1 second'::interval,NEW.subject_doc,NEW.employee_id,'Создано автоматически'
							);
						END IF;
					END IF;
				
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					INSERT INTO doc_flow_inside_processes (
						doc_flow_inside_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_inside_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
				
				END IF;
			END IF;
		END IF;
									
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--setting step count
			SELECT max(steps.step)
			INTO NEW.step_count
			FROM (
				SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
			) steps;
		
			IF TG_OP='INSERT' AND NEW.step_count>0 THEN
				NEW.current_step = 1;
			END IF;
		END IF;
												
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--статус
			IF OLD.subject_doc->>'dataType'='doc_flow_out' THEN
				DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			ELSIF OLD.subject_doc->>'dataType'='doc_flow_inside' THEN
				DELETE FROM doc_flow_inside_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			END IF;
		
			--задачи
			DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO expert72;


-- ******************* update 09/10/2019 10:59:02 ******************
-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_type_id int;
	v_id int;
	v_reg_number text;
	v_auto_reg boolean;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
			--статус
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				INSERT INTO doc_flow_out_processes (
					doc_flow_out_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_out_states ELSE 'approving'::doc_flow_out_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);
			ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
				INSERT INTO doc_flow_inside_processes (
					doc_flow_inside_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_inside_states ELSE 'approving'::doc_flow_inside_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);			
			END IF;	
			
			PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--state
			IF NEW.date_time<>OLD.date_time
				OR NEW.end_date_time<>OLD.end_date_time
				OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
				OR NEW.subject_doc<>OLD.subject_doc
				OR NEW.subject<>OLD.subject
			THEN
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					UPDATE doc_flow_out_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					UPDATE doc_flow_inside_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_inside_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				
				END IF;
			END IF;

			IF NEW.close_date_time IS NOT NULL AND OLD.close_date_time IS NULL THEN
				--Все закрыли - задачу ответственному
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				VALUES (
					doc_flow_approvements_ref(NEW),
					now(),NEW.end_date_time,
					NEW.doc_flow_importance_type_id,
					NEW.employee_id,
					employees_ref((SELECT e FROM employees e WHERE e.id=NEW.employee_id)),
					'Ознакомиться с результатом согласования'
				);
			
				--сменим статус при закрытии			
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					INSERT INTO doc_flow_out_processes (
						doc_flow_out_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_out_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
			
					--Если это исх.письмо по контракту (замечания) - сразу зарегистрируем
					--Добавлено 08/06/19: или заключение экспертизы - сразу зарегистрируем
					--Добавлено 09/10/19: Заключение только по Достоверности
					IF ((NEW.close_result)::text)::doc_flow_out_states='approved'::doc_flow_out_states
					AND NEW.subject_doc->>'dataType'='doc_flow_out'
					THEN
						SELECT
							t.doc_flow_type_id,
							t.reg_number,
							t.id,
							
							-- 08/06/19 + contr_close (09/10/19 Только достоверность!)
							(							
								(
								t.doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
								AND
								app.cost_eval_validity
								)
							OR
							-- contr Ответы на замечания все всегда!!!
							t.doc_flow_type_id=(pdfn_doc_flow_types_contr()->'keys'->>'id')::int
							)
						INTO 
							v_doc_flow_type_id,
							v_reg_number,
							v_id,
							v_auto_reg
						FROM doc_flow_out t
						LEFT JOIN applications AS app ON app.id=t.to_application_id				
						WHERE t.id = (NEW.subject_doc->'keys'->>'id')::int;
				
						
						IF v_auto_reg THEN
							IF v_reg_number IS NULL THEN
								UPDATE doc_flow_out
								SET reg_number=doc_flow_out_next_num(v_doc_flow_type_id)
								WHERE id=v_id;
							END IF;
					
							INSERT INTO doc_flow_registrations
							(date_time,subject_doc,employee_id,comment_text)
							VALUES (
							now()+'1 second'::interval,NEW.subject_doc,NEW.employee_id,'Создано автоматически'
							);
						END IF;
					END IF;
				
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					INSERT INTO doc_flow_inside_processes (
						doc_flow_inside_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_inside_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
				
				END IF;
			END IF;
		END IF;
									
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--setting step count
			SELECT max(steps.step)
			INTO NEW.step_count
			FROM (
				SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
			) steps;
		
			IF TG_OP='INSERT' AND NEW.step_count>0 THEN
				NEW.current_step = 1;
			END IF;
		END IF;
												
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--статус
			IF OLD.subject_doc->>'dataType'='doc_flow_out' THEN
				DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			ELSIF OLD.subject_doc->>'dataType'='doc_flow_inside' THEN
				DELETE FROM doc_flow_inside_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			END IF;
		
			--задачи
			DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO expert72;


-- ******************* update 09/10/2019 11:27:56 ******************
-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_type_id int;
	v_id int;
	v_reg_number text;
	v_auto_reg boolean;
	v_examination_id int;
	v_to_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
			--статус
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				INSERT INTO doc_flow_out_processes (
					doc_flow_out_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_out_states ELSE 'approving'::doc_flow_out_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);
			ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
				INSERT INTO doc_flow_inside_processes (
					doc_flow_inside_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_inside_states ELSE 'approving'::doc_flow_inside_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);			
			END IF;	
			
			PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--state
			IF NEW.date_time<>OLD.date_time
				OR NEW.end_date_time<>OLD.end_date_time
				OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
				OR NEW.subject_doc<>OLD.subject_doc
				OR NEW.subject<>OLD.subject
			THEN
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					UPDATE doc_flow_out_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					UPDATE doc_flow_inside_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_inside_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				
				END IF;
			END IF;

			IF NEW.close_date_time IS NOT NULL AND OLD.close_date_time IS NULL THEN
				--Все закрыли - задачу ответственному
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				VALUES (
					doc_flow_approvements_ref(NEW),
					now(),NEW.end_date_time,
					NEW.doc_flow_importance_type_id,
					NEW.employee_id,
					employees_ref((SELECT e FROM employees e WHERE e.id=NEW.employee_id)),
					'Ознакомиться с результатом согласования'
				);
			
				--сменим статус при закрытии			
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					INSERT INTO doc_flow_out_processes (
						doc_flow_out_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_out_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
			
					--Если это исх.письмо по контракту (замечания) - сразу зарегистрируем
					--Добавлено 08/06/19: или заключение экспертизы - сразу зарегистрируем
					--Добавлено 09/10/19: Заключение только по Достоверности
					IF ((NEW.close_result)::text)::doc_flow_out_states='approved'::doc_flow_out_states
					AND NEW.subject_doc->>'dataType'='doc_flow_out'
					THEN
						SELECT
							t.doc_flow_type_id,
							t.reg_number,
							t.id,
							
							-- 08/06/19 + contr_close (09/10/19 Только достоверность!)
							(							
								(
								t.doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
								AND
								app.cost_eval_validity
								)
							OR
							-- contr Ответы на замечания все всегда!!!
							t.doc_flow_type_id=(pdfn_doc_flow_types_contr()->'keys'->>'id')::int
							),
							exam.id,
							t.to_application_id
						INTO 
							v_doc_flow_type_id,
							v_reg_number,
							v_id,
							v_auto_reg,
							v_examination_id,
							v_to_application_id
						FROM doc_flow_out t
						LEFT JOIN applications AS app ON app.id=t.to_application_id
						LEFT JOIN doc_flow_in ON doc_flow_in.id=t.doc_flow_in_id
						LEFT JOIN doc_flow_examinations AS exam ON doc_flow_in.id=(exam.subject_doc->'keys'->>'id')::int AND exam.subject_doc->>'dataType'='doc_flow_in'						
						WHERE t.id = (NEW.subject_doc->'keys'->>'id')::int;
				
						
						IF v_auto_reg THEN
							IF v_reg_number IS NULL THEN
								UPDATE doc_flow_out
								SET reg_number=doc_flow_out_next_num(v_doc_flow_type_id)
								WHERE id=v_id;
							END IF;
					
							INSERT INTO doc_flow_registrations
							(date_time,subject_doc,employee_id,comment_text)
							VALUES (
							now()+'1 second'::interval,NEW.subject_doc,NEW.employee_id,'Создано автоматически'
							);
							
							--09/10/19 смена статуса заявления, полностью повторяет DocFlowRegistration_Controller
							IF v_examination_id iS NOT NULL THEN
								--Есть рассмотрение DocFlowExamination_Controller->setResolved
								UPDATE doc_flow_examinations
								SET
									resolution=NULL,
									close_date_time=now()+'1 second'::interval,
									application_resolution_state='closed'::application_states,
									close_employee_id=NEW.employee_id,
									closed=TRUE
								WHERE id=v_examination_id;
							ELSE
								--Нет рассмотрения(?) а может вообще такое быть???
								INSERT INTO application_processes (
									application_id,
									date_time,
									state,
									user_id,
									end_date_time
								)
								VALUES (
									v_to_application_id,
									now()+'1 second'::interval,
									'closed',
									(SELECT user_id FROM employees WHERE id=NEW.employee_id),
									NULL
								);								
							END IF;
						END IF;
					END IF;
				
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					INSERT INTO doc_flow_inside_processes (
						doc_flow_inside_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_inside_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
				
				END IF;
			END IF;
		END IF;
									
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--setting step count
			SELECT max(steps.step)
			INTO NEW.step_count
			FROM (
				SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
			) steps;
		
			IF TG_OP='INSERT' AND NEW.step_count>0 THEN
				NEW.current_step = 1;
			END IF;
		END IF;
												
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--статус
			IF OLD.subject_doc->>'dataType'='doc_flow_out' THEN
				DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			ELSIF OLD.subject_doc->>'dataType'='doc_flow_inside' THEN
				DELETE FROM doc_flow_inside_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			END IF;
		
			--задачи
			DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO expert72;


-- ******************* update 09/10/2019 11:31:09 ******************
-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_type_id int;
	v_id int;
	v_reg_number text;
	v_auto_reg boolean;
	v_examination_id int;
	v_to_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
			--статус
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				INSERT INTO doc_flow_out_processes (
					doc_flow_out_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_out_states ELSE 'approving'::doc_flow_out_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);
			ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
				INSERT INTO doc_flow_inside_processes (
					doc_flow_inside_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_inside_states ELSE 'approving'::doc_flow_inside_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);			
			END IF;	
			
			PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--state
			IF NEW.date_time<>OLD.date_time
				OR NEW.end_date_time<>OLD.end_date_time
				OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
				OR NEW.subject_doc<>OLD.subject_doc
				OR NEW.subject<>OLD.subject
			THEN
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					UPDATE doc_flow_out_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					UPDATE doc_flow_inside_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_inside_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				
				END IF;
			END IF;

			IF NEW.close_date_time IS NOT NULL AND OLD.close_date_time IS NULL THEN
				--Все закрыли - задачу ответственному
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				VALUES (
					doc_flow_approvements_ref(NEW),
					now(),NEW.end_date_time,
					NEW.doc_flow_importance_type_id,
					NEW.employee_id,
					employees_ref((SELECT e FROM employees e WHERE e.id=NEW.employee_id)),
					'Ознакомиться с результатом согласования'
				);
			
				--сменим статус при закрытии			
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					INSERT INTO doc_flow_out_processes (
						doc_flow_out_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_out_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
			
					--Если это исх.письмо по контракту (замечания) - сразу зарегистрируем
					--Добавлено 08/06/19: или заключение экспертизы - сразу зарегистрируем
					--Добавлено 09/10/19: Заключение только по Достоверности
					IF ((NEW.close_result)::text)::doc_flow_out_states='approved'::doc_flow_out_states
					AND NEW.subject_doc->>'dataType'='doc_flow_out'
					THEN
						SELECT
							t.doc_flow_type_id,
							t.reg_number,
							t.id,
							
							-- 08/06/19 + contr_close (09/10/19 Только достоверность!)
							(							
								(
								t.doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
								AND
								app.cost_eval_validity
								)
							OR
							-- contr Ответы на замечания все всегда!!!
							t.doc_flow_type_id=(pdfn_doc_flow_types_contr()->'keys'->>'id')::int
							),
							exam.id,
							t.to_application_id
						INTO 
							v_doc_flow_type_id,
							v_reg_number,
							v_id,
							v_auto_reg,
							v_examination_id,
							v_to_application_id
						FROM doc_flow_out t
						LEFT JOIN applications AS app ON app.id=t.to_application_id
						LEFT JOIN doc_flow_in ON doc_flow_in.id=t.doc_flow_in_id
						LEFT JOIN doc_flow_examinations AS exam ON doc_flow_in.id=(exam.subject_doc->'keys'->>'id')::int AND exam.subject_doc->>'dataType'='doc_flow_in'						
						WHERE t.id = (NEW.subject_doc->'keys'->>'id')::int;
				
						
						IF v_auto_reg THEN
							IF v_reg_number IS NULL THEN
								UPDATE doc_flow_out
								SET reg_number=doc_flow_out_next_num(v_doc_flow_type_id)
								WHERE id=v_id;
							END IF;
					
							INSERT INTO doc_flow_registrations
							(date_time,subject_doc,employee_id,comment_text)
							VALUES (
							now()+'1 second'::interval,NEW.subject_doc,NEW.employee_id,'Создано автоматически'
							);
							
							--09/10/19 смена статуса заявления, полностью повторяет DocFlowRegistration_Controller
							/*
							IF v_examination_id iS NOT NULL THEN
								--Есть рассмотрение DocFlowExamination_Controller->setResolved
								UPDATE doc_flow_examinations
								SET
									resolution=NULL,
									close_date_time=now()+'1 second'::interval,
									application_resolution_state='closed'::application_states,
									close_employee_id=NEW.employee_id,
									closed=TRUE
								WHERE id=v_examination_id;
							ELSE
								--Нет рассмотрения(?) а может вообще такое быть???
								INSERT INTO application_processes (
									application_id,
									date_time,
									state,
									user_id,
									end_date_time
								)
								VALUES (
									v_to_application_id,
									now()+'1 second'::interval,
									'closed',
									(SELECT user_id FROM employees WHERE id=NEW.employee_id),
									NULL
								);								
							END IF;
							*/
						END IF;
					END IF;
				
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					INSERT INTO doc_flow_inside_processes (
						doc_flow_inside_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_inside_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
				
				END IF;
			END IF;
		END IF;
									
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--setting step count
			SELECT max(steps.step)
			INTO NEW.step_count
			FROM (
				SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
			) steps;
		
			IF TG_OP='INSERT' AND NEW.step_count>0 THEN
				NEW.current_step = 1;
			END IF;
		END IF;
												
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--статус
			IF OLD.subject_doc->>'dataType'='doc_flow_out' THEN
				DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			ELSIF OLD.subject_doc->>'dataType'='doc_flow_inside' THEN
				DELETE FROM doc_flow_inside_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			END IF;
		
			--задачи
			DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO expert72;


-- ******************* update 09/10/2019 11:34:07 ******************
-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_type_id int;
	v_id int;
	v_reg_number text;
	v_auto_reg boolean;
	v_examination_id int;
	v_to_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
			--статус
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				INSERT INTO doc_flow_out_processes (
					doc_flow_out_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_out_states ELSE 'approving'::doc_flow_out_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);
			ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
				INSERT INTO doc_flow_inside_processes (
					doc_flow_inside_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_inside_states ELSE 'approving'::doc_flow_inside_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);			
			END IF;	
			
			PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--state
			IF NEW.date_time<>OLD.date_time
				OR NEW.end_date_time<>OLD.end_date_time
				OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
				OR NEW.subject_doc<>OLD.subject_doc
				OR NEW.subject<>OLD.subject
			THEN
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					UPDATE doc_flow_out_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					UPDATE doc_flow_inside_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_inside_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				
				END IF;
			END IF;

			IF NEW.close_date_time IS NOT NULL AND OLD.close_date_time IS NULL THEN
				--Все закрыли - задачу ответственному
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				VALUES (
					doc_flow_approvements_ref(NEW),
					now(),NEW.end_date_time,
					NEW.doc_flow_importance_type_id,
					NEW.employee_id,
					employees_ref((SELECT e FROM employees e WHERE e.id=NEW.employee_id)),
					'Ознакомиться с результатом согласования'
				);
			
				--сменим статус при закрытии			
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					INSERT INTO doc_flow_out_processes (
						doc_flow_out_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_out_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
			
					--Если это исх.письмо по контракту (замечания) - сразу зарегистрируем
					--Добавлено 08/06/19: или заключение экспертизы - сразу зарегистрируем
					--Добавлено 09/10/19: Заключение только по Достоверности
					IF ((NEW.close_result)::text)::doc_flow_out_states='approved'::doc_flow_out_states
					AND NEW.subject_doc->>'dataType'='doc_flow_out'
					THEN
						SELECT
							t.doc_flow_type_id,
							t.reg_number,
							t.id,
							
							-- 08/06/19 + contr_close (09/10/19 Только достоверность!)
							(							
								(
								t.doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
								AND
								app.cost_eval_validity
								)
							OR
							-- contr Ответы на замечания все всегда!!!
							t.doc_flow_type_id=(pdfn_doc_flow_types_contr()->'keys'->>'id')::int
							),
							exam.id,
							t.to_application_id
						INTO 
							v_doc_flow_type_id,
							v_reg_number,
							v_id,
							v_auto_reg,
							v_examination_id,
							v_to_application_id
						FROM doc_flow_out t
						LEFT JOIN applications AS app ON app.id=t.to_application_id
						LEFT JOIN doc_flow_in ON doc_flow_in.id=t.doc_flow_in_id
						LEFT JOIN doc_flow_examinations AS exam ON doc_flow_in.id=(exam.subject_doc->'keys'->>'id')::int AND exam.subject_doc->>'dataType'='doc_flow_in'						
						WHERE t.id = (NEW.subject_doc->'keys'->>'id')::int;
				
						
						IF v_auto_reg THEN
							IF v_reg_number IS NULL THEN
								UPDATE doc_flow_out
								SET reg_number=doc_flow_out_next_num(v_doc_flow_type_id)
								WHERE id=v_id;
							END IF;
					
							INSERT INTO doc_flow_registrations
							(date_time,subject_doc,employee_id,comment_text)
							VALUES (
							now()+'1 second'::interval,NEW.subject_doc,NEW.employee_id,'Создано автоматически'
							);
							
							--09/10/19 смена статуса заявления, полностью повторяет DocFlowRegistration_Controller
							IF v_examination_id iS NOT NULL THEN
								--Есть рассмотрение(?) а может вообще такое быть???
								--DocFlowExamination_Controller->setResolved
								UPDATE doc_flow_examinations
								SET
									resolution=NULL,
									close_date_time=now()+'1 second'::interval,
									application_resolution_state='closed'::application_states,
									close_employee_id=NEW.employee_id,
									closed=TRUE
								WHERE id=v_examination_id;
							ELSE
								--Нет рассмотрения - обычный случай
								INSERT INTO application_processes (
									application_id,
									date_time,
									state,
									user_id,
									end_date_time
								)
								VALUES (
									v_to_application_id,
									now()+'1 second'::interval,
									'closed',
									(SELECT user_id FROM employees WHERE id=NEW.employee_id),
									NULL
								);								
							END IF;
						END IF;
					END IF;
				
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					INSERT INTO doc_flow_inside_processes (
						doc_flow_inside_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_inside_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
				
				END IF;
			END IF;
		END IF;
									
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--setting step count
			SELECT max(steps.step)
			INTO NEW.step_count
			FROM (
				SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
			) steps;
		
			IF TG_OP='INSERT' AND NEW.step_count>0 THEN
				NEW.current_step = 1;
			END IF;
		END IF;
												
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--статус
			IF OLD.subject_doc->>'dataType'='doc_flow_out' THEN
				DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			ELSIF OLD.subject_doc->>'dataType'='doc_flow_inside' THEN
				DELETE FROM doc_flow_inside_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			END IF;
		
			--задачи
			DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO expert72;


-- ******************* update 11/10/2019 10:08:56 ******************
-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_doc_flow_type_id int;
	v_id int;
	v_reg_number text;
	v_auto_reg boolean;
	v_examination_id int;
	v_to_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
			--статус
		
			IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
				INSERT INTO doc_flow_out_processes (
					doc_flow_out_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_out_states ELSE 'approving'::doc_flow_out_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);
			ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
				INSERT INTO doc_flow_inside_processes (
					doc_flow_inside_id, date_time,
					state,
					register_doc,
					doc_flow_importance_type_id,
					description,
					end_date_time
				)
				VALUES (
					(NEW.subject_doc->'keys'->>'id')::int,NEW.date_time,
					CASE WHEN NEW.closed THEN 'approved'::doc_flow_inside_states ELSE 'approving'::doc_flow_inside_states END,
					doc_flow_approvements_ref(NEW),
					NEW.doc_flow_importance_type_id,
					NEW.subject,
					NEW.end_date_time
				);			
			END IF;	
			
			PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--state
			IF NEW.date_time<>OLD.date_time
				OR NEW.end_date_time<>OLD.end_date_time
				OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
				OR NEW.subject_doc<>OLD.subject_doc
				OR NEW.subject<>OLD.subject
			THEN
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					UPDATE doc_flow_out_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					UPDATE doc_flow_inside_processes
					SET
						date_time			= NEW.date_time,
						doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
						doc_flow_inside_id			= (NEW.subject_doc->'keys'->>'id')::int,
						description			= NEW.subject,
						end_date_time			= NEW.end_date_time
					WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
				
				END IF;
			END IF;

			IF NEW.close_date_time IS NOT NULL AND OLD.close_date_time IS NULL THEN
				--Все закрыли - задачу ответственному
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				VALUES (
					doc_flow_approvements_ref(NEW),
					now(),NEW.end_date_time,
					NEW.doc_flow_importance_type_id,
					NEW.employee_id,
					employees_ref((SELECT e FROM employees e WHERE e.id=NEW.employee_id)),
					'Ознакомиться с результатом согласования'
				);
			
				--сменим статус при закрытии			
				IF NEW.subject_doc->>'dataType'='doc_flow_out' THEN
					INSERT INTO doc_flow_out_processes (
						doc_flow_out_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_out_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
			
					--Если это исх.письмо по контракту (замечания) - сразу зарегистрируем
					--Добавлено 08/06/19: или заключение экспертизы - сразу зарегистрируем
					--Добавлено 09/10/19: Заключение только по Достоверности
					IF ((NEW.close_result)::text)::doc_flow_out_states='approved'::doc_flow_out_states
					AND NEW.subject_doc->>'dataType'='doc_flow_out'
					THEN
						SELECT
							t.doc_flow_type_id,
							t.reg_number,
							t.id,
							
							-- 08/06/19 + contr_close (09/10/19 Только достоверность!)
							(							
								(
								t.doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
								AND
								app.cost_eval_validity
								)
							OR
							-- contr Ответы на замечания все всегда!!!
							t.doc_flow_type_id=(pdfn_doc_flow_types_contr()->'keys'->>'id')::int
							),
							exam.id,
							t.to_application_id
						INTO 
							v_doc_flow_type_id,
							v_reg_number,
							v_id,
							v_auto_reg,
							v_examination_id,
							v_to_application_id
						FROM doc_flow_out t
						LEFT JOIN applications AS app ON app.id=t.to_application_id
						LEFT JOIN doc_flow_in ON doc_flow_in.id=t.doc_flow_in_id
						LEFT JOIN doc_flow_examinations AS exam ON doc_flow_in.id=(exam.subject_doc->'keys'->>'id')::int AND exam.subject_doc->>'dataType'='doc_flow_in'						
						WHERE t.id = (NEW.subject_doc->'keys'->>'id')::int;
				
						
						IF v_auto_reg THEN
							IF v_reg_number IS NULL THEN
								UPDATE doc_flow_out
								SET reg_number=doc_flow_out_next_num(v_doc_flow_type_id)
								WHERE id=v_id;
							END IF;
					
							INSERT INTO doc_flow_registrations
							(date_time,subject_doc,employee_id,comment_text)
							VALUES (
							now()+'1 second'::interval,NEW.subject_doc,NEW.employee_id,'Создано автоматически'
							);
							
							--09/10/19 смена статуса заявления, полностью повторяет DocFlowRegistration_Controller
							IF v_doc_flow_type_id=(pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int THEN
								IF v_examination_id iS NOT NULL THEN
									--Есть рассмотрение(?) а может вообще такое быть???
									--DocFlowExamination_Controller->setResolved
									UPDATE doc_flow_examinations
									SET
										resolution=NULL,
										close_date_time=now()+'1 second'::interval,
										application_resolution_state='closed'::application_states,
										close_employee_id=NEW.employee_id,
										closed=TRUE
									WHERE id=v_examination_id;
								ELSE
									--Нет рассмотрения - обычный случай
									INSERT INTO application_processes (
										application_id,
										date_time,
										state,
										user_id,
										end_date_time
									)
									VALUES (
										v_to_application_id,
										now()+'1 second'::interval,
										'closed',
										(SELECT user_id FROM employees WHERE id=NEW.employee_id),
										NULL
									);								
								END IF;
							END IF;	
						END IF;
					END IF;
				
				ELSIF NEW.subject_doc->>'dataType'='doc_flow_inside' THEN
					INSERT INTO doc_flow_inside_processes (
						doc_flow_inside_id,
						date_time,
						state,
						register_doc,
						doc_flow_importance_type_id,
						end_date_time
					)
					VALUES (
						(NEW.subject_doc->'keys'->>'id')::int,
						now(),
						((NEW.close_result)::text)::doc_flow_inside_states,
						doc_flow_approvements_ref(NEW),
						NEW.doc_flow_importance_type_id,
						NEW.end_date_time
					);
				
				END IF;
			END IF;
		END IF;
									
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--setting step count
			SELECT max(steps.step)
			INTO NEW.step_count
			FROM (
				SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
			) steps;
		
			IF TG_OP='INSERT' AND NEW.step_count>0 THEN
				NEW.current_step = 1;
			END IF;
		END IF;
												
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			--статус
			IF OLD.subject_doc->>'dataType'='doc_flow_out' THEN
				DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			ELSIF OLD.subject_doc->>'dataType'='doc_flow_inside' THEN
				DELETE FROM doc_flow_inside_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
			END IF;
		
			--задачи
			DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		END IF;
													
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO expert72;


-- ******************* update 17/10/2019 09:38:26 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
	v_corrected_files_t text;
	v_doc_flow_in doc_flow_in;
	v_server_for_href text;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
		
			v_server_for_href = 'http://192.168.1.134/expert72/';
		
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--	4) Продление срока
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='contr_other'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='date_prolongate'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='app_contr_revoke'::doc_flow_out_client_types)
			THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания, свернуто
				SELECT
					string_agg(paths.file_path,','),
					jsonb_agg(paths.section_o)
				INTO
					v_corrected_sections_t,
					v_corrected_sections_o
				FROM
				(
					SELECT 
					app_f.file_path,
					jsonb_build_object(
						'name',app_f.file_path,
						'deleted',sum(CASE WHEN doc_f.is_new THEN 0 ELSE 1 END),
						'added',sum(CASE WHEN doc_f.is_new THEN 1 ELSE 0 END)
					) AS section_o
					FROM doc_flow_out_client_document_files AS doc_f
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
					GROUP BY app_f.file_path
					ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = enum_doc_flow_out_client_types_val(NEW.doc_flow_out_client_type,'ru');
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_other'::doc_flow_out_client_types THEN
						5--Просто письмо входящее
					WHEN NEW.doc_flow_out_client_type='date_prolongate'::doc_flow_out_client_types THEN
						16--Продление срока
					WHEN NEW.doc_flow_out_client_type='app_contr_revoke'::doc_flow_out_client_types AND v_contract_id IS NULL THEN
						13--Отзыв
					
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			IF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Файлы развернуто со ссылками
				SELECT
					string_agg(fl.f_descr,E'\n\n')
				INTO
					v_corrected_files_t
				FROM(	
					SELECT 
						CASE WHEN app_f.information_list THEN 'Удостоверяющий лист ' ELSE '' END||
						app_f.file_path||'/'||app_f.file_name||
						format(E'\n%s?c=DocFlowOut_Controller&f=get_file&v=ViewXML&file_id=%s&doc_id=%s',
						v_server_for_href,app_f.file_id,v_doc_flow_in_id)
						AS f_descr
					FROM doc_flow_out_client_document_files AS doc_f
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
					WHERE
						doc_f.doc_flow_out_client_id=NEW.id
						AND app_f.document_id<>0
						AND doc_f.is_new
					ORDER BY app_f.information_list,app_f.file_path,app_f.file_name
				) AS fl				
				;
			END IF;
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			--************** all rows ********************************************
			SELECT INTO v_doc_flow_in * FROM doc_flow_in WHERE id=v_doc_flow_in_id;
			--********************************************************************
			
			IF v_contract_id IS NULL THEN --AND NEW.doc_flow_out_client_type='app'::doc_flow_out_client_types THEN
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref(v_doc_flow_in),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
				INSERT INTO reminders
				(register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					employees.id,
					NEW.subject,
					doc_flow_in_ref(v_doc_flow_in)
				FROM employees
				WHERE
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref(v_doc_flow_in)					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref(v_doc_flow_in)					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
						doc_flow_in_ref(v_doc_flow_in)
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value,
						ROW('files',v_corrected_files_t)::template_value,
						ROW('server',v_server_for_href)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				doc_flow_in_ref(v_doc_flow_in)
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		ELSIF
		(TG_OP='UPDATE' AND NEW.sent=FALSE AND coalesce(OLD.sent,FALSE)=TRUE)
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--отмена отправки
			DELETE FROM doc_flow_out_client_reg_numbers WHERE application_id=NEW.application_id AND doc_flow_out_client_id=NEW.id;
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;



-- ******************* update 17/10/2019 09:39:58 ******************
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
	v_dep_email text;
	v_recip_department_id int;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
	v_contract_number text;
	v_doc_flow_subject text;
	v_contract_employee_id int;
	v_contract_return_date timestampTZ;
	v_corrected_sections_t text;
	v_corrected_sections_o jsonb;
	v_corrected_files_t text;
	v_doc_flow_in doc_flow_in;
	v_server_for_href text;
BEGIN
	IF TG_WHEN='BEFORE' AND ( TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		IF (const_client_lk_val() OR const_debug_val())
		AND (NEW.sent AND (TG_OP='INSERT' OR coalesce(OLD.sent,FALSE)=FALSE ))
		THEN
			NEW.date_time = now();			
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN	
		IF (const_client_lk_val() OR const_debug_val())	THEN
			DELETE FROM doc_flow_out_client_document_files WHERE doc_flow_out_client_id=OLD.id;
		END IF;
		
		RETURN OLD;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN			
		IF
		( (TG_OP='INSERT' AND NEW.sent) OR (TG_OP='UPDATE' AND NEW.sent AND NOT coalesce(OLD.sent,FALSE)) )
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
		
			v_server_for_href = 'http://192.168.1.134/expert72/';
		
			--main programm
			--*********** Исходные данные *************************
			SELECT
				app.applicant,
				app.constr_name::text,
				app.office_id,
				contracts.id,
				contracts.main_department_id,
				contracts.main_expert_id,
				dep.email,
				st.state,
				st.date_time,
				contracts.contract_number,
				contracts.employee_id
			INTO
				v_applicant,
				v_constr_name,
				v_office_id,
				v_contract_id,
				v_main_department_id,
				v_main_expert_id,
				v_dep_email,
				v_application_state,
				v_application_state_dt,
				v_contract_number,
				v_contract_employee_id
			FROM applications AS app
			LEFT JOIN contracts ON contracts.application_id=app.id
				AND (
					(contracts.expertise_type IS NOT NULL AND contracts.expertise_type = app.expertise_type)
					OR (contracts.document_type='cost_eval_validity'::document_types AND app.cost_eval_validity)
					OR (contracts.document_type='modification'::document_types AND app.modification)
					OR (contracts.document_type='audit'::document_types AND app.audit)
				)
			LEFT JOIN departments As dep ON dep.id=contracts.main_department_id
			--тек.статус
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=app.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
			
			WHERE app.id = NEW.application_id;
			
			SELECT
				d_from,d_to
			INTO v_from_date_time,v_end_date_time
			FROM applications_check_period(v_office_id,now(),const_application_check_days_val()) AS (d_from timestampTZ,d_to timestampTZ);
			--*******************************************************************
			
			
			--Исходящее письмо клиента может быть:
			--	1) По новому заявлению, контракта нет
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			Создать рассмотрение на отдел приема
			--			Напоминание&&email боссу
			--			Напоминание&&email admin
			
			--	2) По замечаниям, когда уже есть контракт
			--		Действия:
			--			Создать входящее письмо на главный отдел контракта			
			--			Напоминание&&email главному эксперту
			--			email на главный отдел
			--			Напоминание&&email admin
			
			--	3) Возврат контракта
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			--			Отметить возврат контракта в контракте
			--			Перевести статус контракта в ожидание оплаты, только тек.статус=ожидание контракта
			
			--	4) Продление срока
			--		Действия:
			--			Создать входящее письмо на отдел приема
			--			email на отдел приема
			--			Напоминание&&email admin
			
			--************* Входящее письмо НАШЕ ***********************************
			--Либо отделу приема
			--Либо главному отделу контракта
			IF (v_main_department_id IS NULL)
			OR (NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='contr_other'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='date_prolongate'::doc_flow_out_client_types)
			OR (NEW.doc_flow_out_client_type='app_contr_revoke'::doc_flow_out_client_types)
			THEN
				v_recip_department_id = (SELECT const_app_recipient_department_val()->'keys'->>'id')::int;				
			ELSE
				v_recip_department_id = v_main_department_id;
			END IF;
			
			--Расширенная тема с доп.атрибутами
			IF NEW.doc_flow_out_client_type='contr_return' THEN
				v_doc_flow_subject = NEW.subject||' №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Разделы с изменениями для ответов на замечания, свернуто
				SELECT
					string_agg(paths.file_path,','),
					jsonb_agg(paths.section_o)
				INTO
					v_corrected_sections_t,
					v_corrected_sections_o
				FROM
				(
					SELECT 
					app_f.file_path,
					jsonb_build_object(
						'name',app_f.file_path,
						'deleted',sum(CASE WHEN doc_f.is_new THEN 0 ELSE 1 END),
						'added',sum(CASE WHEN doc_f.is_new THEN 1 ELSE 0 END)
					) AS section_o
					FROM doc_flow_out_client_document_files AS doc_f
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
					GROUP BY app_f.file_path
					ORDER BY app_f.file_path
				) AS paths;
				
				v_doc_flow_subject = NEW.subject||', контракт №'||v_contract_number||', '||(v_applicant->>'name')::text;
			ELSE
				v_doc_flow_subject = enum_doc_flow_out_client_types_val(NEW.doc_flow_out_client_type,'ru');
				IF v_contract_number IS NOT NULL THEN
					v_doc_flow_subject = v_doc_flow_subject ||', контракт №'||v_contract_number;
				END IF;
				v_doc_flow_subject = v_doc_flow_subject ||', '||(v_applicant->>'name')::text;
			END IF;
			
			--Новое входяее письмо всегда						
			INSERT INTO doc_flow_in (
				date_time,
				from_user_id,
				from_addr_name,from_client_signed_by,from_client_date,
				from_application_id,
				doc_flow_type_id,
				end_date_time,
				subject,content,
				recipient,
				from_doc_flow_out_client_id,
				from_client_app,
				corrected_sections
			)
			VALUES (
				v_from_date_time,
				NEW.user_id,
				v_applicant->>'name', (v_applicant->>'responsable_person_head')::json->>'name',now()::date,
				NEW.application_id,
				
				CASE
					WHEN NEW.doc_flow_out_client_type='contr_return'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_paper_return()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_resp'::doc_flow_out_client_types THEN
						(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int
					WHEN NEW.doc_flow_out_client_type='contr_other'::doc_flow_out_client_types THEN
						5--Просто письмо входящее
					WHEN NEW.doc_flow_out_client_type='date_prolongate'::doc_flow_out_client_types THEN
						16--Продление срока
					WHEN NEW.doc_flow_out_client_type='app_contr_revoke'::doc_flow_out_client_types AND v_contract_id IS NULL THEN
						13--Отзыв
					
					ELSE (pdfn_doc_flow_types_app()->'keys'->>'id')::int
				END,
				
				v_end_date_time,
				v_doc_flow_subject,
				NEW.content,
				(SELECT departments_ref(departments) FROM departments WHERE id=v_recip_department_id),
				NEW.id,
				TRUE,
				v_corrected_sections_o
			)
			RETURNING id,recipient,reg_number
			INTO v_doc_flow_in_id,v_recipient,v_reg_number;
			--**********************************************************
			
			IF NEW.doc_flow_out_client_type='contr_resp' THEN
				--Файлы развернуто со ссылками
				SELECT
					string_agg(fl.f_descr,E'\n\n')
				INTO
					v_corrected_files_t
				FROM(	
					SELECT 
						CASE WHEN app_f.information_list THEN 'Удостоверяющий лист ' ELSE '' END||
						app_f.file_path||'/'||app_f.file_name||
						format(E'\n%s?c=DocFlowOut_Controller&f=get_file&v=ViewXML&file_id=%s&doc_id=%s',
						v_server_for_href,app_f.file_id,v_doc_flow_in_id)
						AS f_descr
					FROM doc_flow_out_client_document_files AS doc_f
					LEFT JOIN application_document_files AS app_f ON app_f.file_id=doc_f.file_id
					WHERE
						doc_f.doc_flow_out_client_id=NEW.id
						AND app_f.document_id<>0
						AND doc_f.is_new
					ORDER BY app_f.information_list,app_f.file_path,app_f.file_name
				) AS fl				
				;
			END IF;
			
			--************** Рег номер наш - клиенту ******************************
			INSERT INTO doc_flow_out_client_reg_numbers
			(doc_flow_out_client_id,application_id,reg_number)
			VALUES (NEW.id,NEW.application_id,v_reg_number);
			--*********************************************************************
			
			--************** all rows ********************************************
			SELECT INTO v_doc_flow_in * FROM doc_flow_in WHERE id=v_doc_flow_in_id;
			--********************************************************************
			
			IF v_contract_id IS NULL THEN --AND NEW.doc_flow_out_client_type='app'::doc_flow_out_client_types THEN
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
					(SELECT boss_employee_id
					FROM departments
					WHERE id=(const_app_recipient_department_val()->'keys'->>'id')::int
					),
					doc_flow_in_ref(v_doc_flow_in),
					v_recipient				
				);
						
				--reminder&&email boss о новых заявлениях
				INSERT INTO reminders
				(register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					employees.id,
					NEW.subject,
					doc_flow_in_ref(v_doc_flow_in)
				FROM employees
				WHERE
					employees.user_id IN (SELECT id FROM users WHERE role_id='boss')
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_resp' THEN
				--ответы на замечания
				IF v_main_expert_id IS NOT NULL THEN			
					--напоминание&&email Гл.эксперту 
					INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
					VALUES(
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						v_main_expert_id,
						v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
						doc_flow_in_ref(v_doc_flow_in)					
					);
				END IF;
				
				--Напоминание всем экспертам из списка
				INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
				(SELECT
					applications_ref((SELECT applications
								FROM applications
								WHERE id = NEW.application_id
					)),
					(sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int AS expert_id,
					v_doc_flow_subject||' Разделы:'||v_corrected_sections_t,
					doc_flow_in_ref(v_doc_flow_in)					
					
				FROM (
					SELECT jsonb_array_elements(experts_for_notification->'rows') AS expert_fields
					FROM contracts
					WHERE contracts.id=v_contract_id
				) AS sub
				WHERE (v_main_expert_id IS NULL) OR ((sub.expert_fields->'fields'->'expert'->'keys'->>'id')::int<>v_main_expert_id)
				);
				
			ELSIF NEW.doc_flow_out_client_type='contr_return' THEN	
				--Возврат подписанных документов
				--Мыло отделу приема
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='contr_return'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('number', v_contract_number)::template_value,
						ROW('doc_in_id',v_doc_flow_in_id)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				'contr_return'
				FROM departments
				WHERE
					departments.id = v_recip_department_id
					AND departments.email IS NOT NULL
				);								
				
				--напоминание автору контракта из отдела приема
				IF v_contract_employee_id IS NOT NULL THEN
					INSERT INTO reminders
					(register_docs_ref,recipient_employee_id,content,docs_ref)
					(SELECT
						applications_ref((SELECT applications
									FROM applications
									WHERE id = NEW.application_id
						)),
						employees.id,
						v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
						doc_flow_in_ref(v_doc_flow_in)
					FROM employees
					LEFT JOIN users ON users.id=employees.user_id
					WHERE employees.id=v_contract_employee_id AND users.email IS NOT NULL
					);				
				END IF;
				
				--Отметка даты возврата контракта && смена статуса
				SELECT doc_flow_contract_ret_date(NEW.id) INTO v_contract_return_date;
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL)
				WHERE id=v_contract_id AND contract_return_date IS NULL;
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%',v_application_state;
				
				IF v_application_state='waiting_for_contract'
				OR v_application_state='closed' THEN
					INSERT INTO application_processes (
						application_id,
						date_time,
						state,
						user_id,
						end_date_time
					)
					VALUES (
						NEW.application_id,
						greatest(NEW.date_time,v_application_state_dt+'1 second'::interval),
						CASE
							WHEN v_application_state='waiting_for_contract' THEN 'waiting_for_pay'::application_states
							ELSE 'archive'::application_states
						END,
						NEW.user_id,
						NULL
					);			
				END IF;
				
			END IF;
			
			
			--Email главному отделу
			IF v_main_department_id IS NOT NULL AND NEW.doc_flow_out_client_type='contr_resp' THEN
				INSERT INTO mail_for_sending
				(to_addr,to_name,body,subject,email_type)
				(WITH 
					templ AS (
					SELECT t.template AS v,t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type='app_change'
					)
				SELECT
				departments.email,
				departments.name,
				sms_templates_text(
					ARRAY[
						ROW('applicant', (v_applicant->>'name')::text)::template_value,
						ROW('constr_name',v_constr_name)::template_value,
						ROW('application_id',NEW.application_id)::template_value,
						ROW('contract_id',v_contract_id)::template_value,						
						ROW('sections',v_corrected_sections_t)::template_value,
						ROW('files',v_corrected_files_t)::template_value,
						ROW('server',v_server_for_href)::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				'app_change'
				FROM departments
				WHERE
					departments.id = v_main_department_id
					AND departments.email IS NOT NULL
				);								
			END IF;
						
			--Напоминание&&email админу - всегда
			-- ну и всему списку сотрудников, указанных в доступности (permissions)
			INSERT INTO reminders
			(register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				applications_ref((SELECT applications
							FROM applications
							WHERE id = NEW.application_id
				)),
				employees.id,
				v_doc_flow_subject||', Рег.№'||v_doc_flow_in.reg_number,
				doc_flow_in_ref(v_doc_flow_in)
			FROM employees
			WHERE
				employees.user_id IN (SELECT id FROM users WHERE role_id='admin')
				OR
				(NEW.doc_flow_out_client_type='contr_resp'
				AND
				employees.id IN (
					SELECT (fld.obj->'keys'->>'id')::int
					FROM (
						SELECT jsonb_array_elements(contracts.permissions->'rows')->'fields'->'obj' AS obj
						FROM contracts
						WHERE contracts.id=v_contract_id
					) AS fld
					WHERE fld.obj->>'dataType'='employees'
					)
				)
			);
		
		ELSIF
		(TG_OP='UPDATE' AND NEW.sent=FALSE AND OLD.sent=TRUE)
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--отмена отправки
			DELETE FROM doc_flow_out_client_reg_numbers WHERE application_id=NEW.application_id AND doc_flow_out_client_id=NEW.id;
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;



-- ******************* update 18/10/2019 09:24:28 ******************

		CREATE TABLE doc_flow_out_client_original_files
		(doc_flow_out_client_id int NOT NULL REFERENCES doc_flow_out_client(id),original_file_id  varchar(36) NOT NULL,CONSTRAINT doc_flow_out_client_original_files_pkey PRIMARY KEY (doc_flow_out_client_id,original_file_id)
		);
		ALTER TABLE doc_flow_out_client_original_files OWNER TO expert72;



-- ******************* update 19/11/2019 08:59:53 ******************
-- Function: public.contracts_process()

-- DROP FUNCTION public.contracts_process();

CREATE OR REPLACE FUNCTION public.contracts_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF
		((TG_OP='INSERT')
		OR (TG_OP='UPDATE' AND NEW.permissions<>OLD.permissions))
		AND (NOT const_client_lk_val() OR const_debug_val())
		THEN
			/*
			-- Проверка на пустых!!!
			IF NEW.permissions IS NOT NULL THEN
				SELECT
					sub.employees_ref
				FROM
				(SELECT
					jsonb_array_elements(NEW.permissions->'rows') AS employees_ref
				) AS sub
				WHERE employees_ref->'fields'->'obj'->'keys'->>'id'='null';
				IF FOUND THEN
					RAISE EXCEPTION 'В списке прав доступа есть пустой сотрудник!';
				END IF;
			END IF;
			*/
			SELECT
				array_agg( ((sub.obj->'fields'->>'obj')::json->>'dataType')||((sub.obj->'fields'->>'obj')::json->'keys'->>'id') )
			INTO NEW.permission_ar
			FROM (
				SELECT jsonb_array_elements(NEW.permissions->'rows') AS obj
			) AS sub		
			;
		END IF;
		/*
		IF (TG_OP='UPDATE' AND NEW.experts_for_notification<>OLD.experts_for_notification) THEN
			SELECT
				array_agg( ((sub.obj->'fields'->>'expert')::json->'keys'->>'id')::int )
			INTO NEW.experts_for_notification_ar
			FROM (
				SELECT jsonb_array_elements(NEW.experts_for_notification->'rows') AS obj
			) AS sub		
			;
		END IF;
		*/
		/*
		IF TG_OP='UPDATE' THEN
			RAISE EXCEPTION 'Updating contracts linked_contracts=%',NEW.linked_contracts;
		END IF;
		*/
		/*		
		--ГЕНЕРАЦИЯ НОМЕРА ЭКСПЕРТНОГО ЗАКЛЮЧЕНИЯ
		IF TG_OP='INSERT' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			SELECT
				coalesce(max(regexp_replace(ct.expertise_result_number,'\D+.*$','')::int),0)+1,
				coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1
			INTO NEW.expertise_result_number,NEW.contract_number
			FROM contracts AS ct
			WHERE
				ct.document_type=NEW.document_type
				AND extract(year FROM NEW.date_time)=extract(year FROM now())
			;
			NEW.expertise_result_number = substr('0000',1,4-length(NEW.expertise_result_number)) || NEW.expertise_result_number
				|| '/'||(extract(year FROM now())-2000)::text;
			NEW.contract_number = 
				CASE
					WHEN NEW.document_type='pd' THEN NEW.contract_number
					WHEN NEW.document_type='cost_eval_validity' THEN NEW.contract_number||'/'||'Д'
					WHEN NEW.document_type='modification' THEN NEW.contract_number||'/'||'М'
					WHEN NEW.document_type='audit' THEN NEW.contract_number||'/'||'А'
					ELSE ''
				END
				;
			NEW.contract_date = now()::date;
		END IF;
		*/
		
		RETURN NEW;
		
	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		IF (NOT const_client_lk_val() OR const_debug_val()) THEN
			DELETE FROM client_payments WHERE contract_id = OLD.id;
			DELETE FROM expert_works WHERE contract_id = OLD.id;
			DELETE FROM doc_flow_out WHERE to_contract_id = OLD.id;
			DELETE FROM doc_flow_inside WHERE contract_id = OLD.id;
		END IF;		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.contracts_process()
  OWNER TO expert72;



-- ******************* update 20/11/2019 12:49:30 ******************
﻿-- Function: doc_flow_out_client_out_attrs(in_pplication_id int)

-- DROP FUNCTION doc_flow_out_client_out_attrs(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_out_attrs(in_application_id int)
  RETURNS jsonb AS
$$
	WITH last_doc AS (
		SELECT
		
			coalesce(df_out.allow_new_file_add,FALSE) AS allow_new_file_add,
			(SELECT
				array_agg(checked_sections.section_id)
			FROM
			(	(SELECT
					(sec.sections->'fields'->>'id')::int AS section_id
				FROM (
				SELECT
					jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
				) AS sec
				WHERE (sec.sections->'fields'->>'checked')::bool
				)
				UNION ALL
				(SELECT
					(subsec.sections->'fields'->>'id')::int AS section_id
				FROM
				(	SELECT
						jsonb_array_elements(sec.sections->'items') sections
					FROM (
						SELECT
							jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
					) AS sec
					WHERE sec.sections->'items' IS NOT NULL
				) AS subsec
				WHERE (subsec.sections->'fields'->>'checked')::bool
				)
			) AS checked_sections						
			) AS allow_edit_sections
		FROM doc_flow_out AS df_out
		WHERE
			df_out.to_application_id=$1
			AND (SELECT pr.state
				FROM doc_flow_out_processes pr
				WHERE pr.doc_flow_out_id=df_out.id
				ORDER BY pr.date_time DESC
				LIMIT 1
			)='registered'
			--!!!Только замечания экспертизы!!!
			AND df_out.doc_flow_type_id = (pdfn_doc_flow_types_contr()->'keys'->>'id')::int
		ORDER BY df_out.date_time DESC
		LIMIT 1
	)
	SELECT
		jsonb_build_object(
			'allow_new_file_add',(SELECT last_doc.allow_new_file_add FROM last_doc),
			'allow_edit_sections',(SELECT last_doc.allow_edit_sections FROM last_doc)						
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_out_attrs(in_application_id int) OWNER TO expert72;


-- ******************* update 21/11/2019 10:45:00 ******************

		ALTER TABLE contracts ADD COLUMN allow_new_file_add bool
			DEFAULT FALSE;
	


-- ******************* update 21/11/2019 10:46:40 ******************
-- VIEW: contracts_list

--DROP VIEW contracts_list;

CREATE OR REPLACE VIEW contracts_list AS
	SELECT
		t.id,
		t.date_time,
		t.application_id,
		applications_ref(applications) AS applications_ref,
		
		t.client_id,
		clients.name AS client_descr,
		--clients_ref(clients) AS clients_ref,
		coalesce(t.constr_name,applications.constr_name) AS constr_name,
		
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,

		t.employee_id,
		employees_ref(employees) AS employees_ref,
		
		t.reg_number,
		t.expertise_type,
		t.document_type,
		
		contracts_ref(t) AS self_ref,
		
		t.main_expert_id,
		t.main_department_id,
		m_exp.name AS main_expert_descr,
		--employees_ref(m_exp) AS main_experts_ref,
		
		t.contract_number,
		t.contract_date,
		t.expertise_result_number,
		
		t.comment_text,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_date,
		
		t.for_all_employees,
		CASE
			WHEN (coalesce(pm.cnt,0)=0) THEN 'no_pay'
			WHEN st.state='returned' OR st.state='closed_no_expertise' THEN 'returned'
			WHEN t.expertise_result IS NULL AND t.expertise_result_date<=now()::date THEN 'no_result'
			ELSE NULL
		END AS state_for_color,
		
		applications.exp_cost_eval_validity,
		
		t.permission_ar AS condition_ar,
		
		t.allow_new_file_add
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=t.application_id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	LEFT JOIN (
		SELECT
			client_payments.contract_id,
			count(*) AS cnt
		FROM client_payments
		GROUP BY client_payments.contract_id
	) AS pm ON pm.contract_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW contracts_list OWNER TO expert72;


-- ******************* update 21/11/2019 10:47:31 ******************
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
		applications_ref(app) AS applications_ref,
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
		
		construction_types_ref(construction_types) AS construction_types_ref,
		t.constr_name AS constr_name,
		--kladr_parse_addr(t.constr_address) AS constr_address,
		t.constr_address,
		t.constr_technical_features,
		t.constr_technical_features_in_compound_obj,
		app.total_cost_eval,
		app.limit_cost_eval,
		build_types_ref(build_types) AS build_types_ref,
		app.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
		app.modif_primary_application_reg_number AS modif_primary_contract_reg_number,
		contracts_ref(prim_contr) AS primary_contracts_ref,
		contracts_ref(modif_prim_contr) AS modif_primary_contracts_ref,
		app.cost_eval_validity,
		app.modification,
		app.audit,
		
		--Documents
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(app.create_dt::date) l
			WHERE
				(app.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=app.construction_type_id AND
				l.document_type IN (
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN app.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN app.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,		
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
						(SELECT
							string_agg(
								coalesce(expert_works.comment_text,'') ||
								'(' || person_init(employees.name,FALSE) || to_char(expert_works.date_time,'DD/MM/YY') || ')'
								,', '
							)
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
				WHERE sec.document_type=t.document_type AND construction_type_id=app.construction_type_id
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=app.construction_type_id
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
		
		folders.files AS doc_folders,
		
		t.for_all_employees,
		t.in_estim_cost,
		t.in_estim_cost_recommend,
		t.cur_estim_cost,
		t.cur_estim_cost_recommend,
		
		t.result_sign_expert_list,
		
		t.experts_for_notification,
		
		t.contract_return_date_on_sig,
		
		app.exp_cost_eval_validity,
		
		t.main_department_id,
		t.main_expert_id,
		t.permission_ar AS condition_ar,
		
		t.allow_new_file_add
		
	FROM contracts t
	LEFT JOIN applications AS app ON app.id=t.application_id
	LEFT JOIN construction_types ON construction_types.id=app.construction_type_id
	LEFT JOIN build_types ON build_types.id=app.build_type_id
	LEFT JOIN fund_sources AS fund_sources ON fund_sources.id = coalesce(t.fund_source_id,app.fund_source_id)
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
			adf_files.application_id,
			adf_files.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(adf_files.files) AS files
		FROM
			(SELECT
				adf.application_id,
				adf.file_path,
				json_build_object(
					'file_id',adf.file_id,
					'file_name',adf.file_name,
					'file_size',adf.file_size,
					'file_signed',adf.file_signed,
					'file_uploaded','true',
					'file_path',adf.file_path,
					'date_time',adf.date_time,
					'signatures',
				
					(WITH
					sign AS (SELECT
						json_agg(files_t.signatures) AS signatures
					FROM
						(SELECT
							f_sig.file_id,
							json_build_object(
								'owner',u_certs.subject_cert,
								'cert_from',u_certs.date_time_from,
								'cert_to',u_certs.date_time_to,
								'sign_date_time',f_sig.sign_date_time,
								'check_result',ver.check_result,
								'check_time',ver.check_time,
								'error_str',ver.error_str
							) AS signatures
						FROM file_signatures AS f_sig
						LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
						LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
						WHERE f_sig.file_id=adf.file_id
						ORDER BY f_sig.sign_date_time
						) AS files_t
					)
					SELECT
						CASE
							WHEN (SELECT sign.signatures FROM sign) IS NULL AND f_ver.file_id IS NOT NULL THEN
								json_build_array(
									json_build_object(
										'sign_date_time',f_ver.date_time,
										'check_result',f_ver.check_result,
										'error_str',f_ver.error_str
									)
								)
							ELSE (SELECT sign.signatures FROM sign)
						END
					),
					'file_signed_by_client',adf.file_signed_by_client
					--'require_client_sig',app_fd.require_client_sig
				) AS files
			FROM application_document_files adf			
			--LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			--LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
		
			WHERE adf.document_type='documents'			
			ORDER BY adf.application_id,adf.file_path,adf.date_time
			)  AS adf_files
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf_files.file_path
		GROUP BY adf_files.application_id,adf_files.file_path,app_fd.id
		ORDER BY adf_files.application_id,adf_files.file_path
		)  AS doc_att
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=app.id
	
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN expertise_reject_types AS rt ON rt.id=t.expertise_reject_type_id
	LEFT JOIN departments AS dp ON dp.id=t.main_department_id
	LEFT JOIN employees AS exp_empl ON exp_empl.id=t.main_expert_id
	LEFT JOIN contracts AS prim_contr ON prim_contr.id=t.primary_contract_id
	LEFT JOIN contracts AS modif_prim_contr ON modif_prim_contr.id=t.modif_primary_contract_id
	--LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;



-- ******************* update 21/11/2019 10:54:16 ******************
﻿-- Function: doc_flow_out_client_out_attrs(in_pplication_id int)

-- DROP FUNCTION doc_flow_out_client_out_attrs(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_out_attrs(in_application_id int)
  RETURNS jsonb AS
$$
	WITH last_doc AS (
		SELECT
		
			coalesce(df_out.allow_new_file_add,FALSE) AS allow_new_file_add,
			(SELECT
				array_agg(checked_sections.section_id)
			FROM
			(	(SELECT
					(sec.sections->'fields'->>'id')::int AS section_id
				FROM (
				SELECT
					jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
				) AS sec
				WHERE (sec.sections->'fields'->>'checked')::bool
				)
				UNION ALL
				(SELECT
					(subsec.sections->'fields'->>'id')::int AS section_id
				FROM
				(	SELECT
						jsonb_array_elements(sec.sections->'items') sections
					FROM (
						SELECT
							jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
					) AS sec
					WHERE sec.sections->'items' IS NOT NULL
				) AS subsec
				WHERE (subsec.sections->'fields'->>'checked')::bool
				)
			) AS checked_sections						
			) AS allow_edit_sections
		FROM doc_flow_out AS df_out
		WHERE
			df_out.to_application_id=$1
			AND (SELECT pr.state
				FROM doc_flow_out_processes pr
				WHERE pr.doc_flow_out_id=df_out.id
				ORDER BY pr.date_time DESC
				LIMIT 1
			)='registered'
			--!!!Только замечания экспертизы!!!
			AND df_out.doc_flow_type_id = (pdfn_doc_flow_types_contr()->'keys'->>'id')::int
		ORDER BY df_out.date_time DESC
		LIMIT 1
	)
	SELECT
		jsonb_build_object(
			'allow_new_file_add',
				CASE
				WHEN (SELECT ct.allow_new_file_add FROM contracts ct WHERE ct.application_id=in_application_id LIMIT 1) THEN TRUE
				ELSE (SELECT last_doc.allow_new_file_add FROM last_doc)
				END,
			'allow_edit_sections',
				(SELECT last_doc.allow_edit_sections FROM last_doc)						
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_out_attrs(in_application_id int) OWNER TO expert72;


-- ******************* update 21/11/2019 10:56:04 ******************
﻿-- Function: doc_flow_out_client_out_attrs(in_pplication_id int)

-- DROP FUNCTION doc_flow_out_client_out_attrs(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_out_attrs(in_application_id int)
  RETURNS jsonb AS
$$
	WITH last_doc AS (
		SELECT
		
			coalesce(df_out.allow_new_file_add,FALSE) AS allow_new_file_add,
			(SELECT
				array_agg(checked_sections.section_id)
			FROM
			(	(SELECT
					(sec.sections->'fields'->>'id')::int AS section_id
				FROM (
				SELECT
					jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
				) AS sec
				WHERE (sec.sections->'fields'->>'checked')::bool
				)
				UNION ALL
				(SELECT
					(subsec.sections->'fields'->>'id')::int AS section_id
				FROM
				(	SELECT
						jsonb_array_elements(sec.sections->'items') sections
					FROM (
						SELECT
							jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
					) AS sec
					WHERE sec.sections->'items' IS NOT NULL
				) AS subsec
				WHERE (subsec.sections->'fields'->>'checked')::bool
				)
			) AS checked_sections						
			) AS allow_edit_sections
		FROM doc_flow_out AS df_out
		WHERE
			df_out.to_application_id=$1
			AND (SELECT pr.state
				FROM doc_flow_out_processes pr
				WHERE pr.doc_flow_out_id=df_out.id
				ORDER BY pr.date_time DESC
				LIMIT 1
			)='registered'
			--!!!Только замечания экспертизы!!!
			AND df_out.doc_flow_type_id = (pdfn_doc_flow_types_contr()->'keys'->>'id')::int
		ORDER BY df_out.date_time DESC
		LIMIT 1
	)
	SELECT
		jsonb_build_object(
			'allow_new_file_add',
				CASE
				WHEN (SELECT ct.allow_new_file_add FROM contracts ct WHERE ct.application_id=in_application_id LIMIT 1) THEN TRUE
				ELSE (SELECT last_doc.allow_new_file_add FROM last_doc)
				END,
			'allow_edit_sections',
				(SELECT last_doc.allow_edit_sections FROM last_doc)						
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_out_attrs(in_application_id int) OWNER TO expert72;


-- ******************* update 29/11/2019 08:56:50 ******************
-- Function: doc_flow_in_process()

-- DROP FUNCTION doc_flow_in_process();

CREATE OR REPLACE FUNCTION doc_flow_in_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF
			(NOT const_client_lk_val() OR const_debug_val())
			AND NEW.reg_number IS NULL
			AND (
				--ЛЮБОЕ ОТ КЛИЕНТА
				--doc_flow_type_id=1 OR NEW.doc_flow_type_id=3
				NEW.from_application_id IS NOT NULL
			)
		THEN
			--назначим номер
			NEW.reg_number = doc_flow_in_next_num(NEW.doc_flow_type_id);
		END IF;
		
		RETURN NEW;

	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		IF (NOT const_client_lk_val() OR const_debug_val()) THEN
			DELETE FROM doc_flow_in_processes WHERE doc_flow_in_id = OLD.id;
			DELETE FROM doc_flow_out WHERE doc_flow_in_id = OLD.id;
			DELETE FROM doc_flow_attachments WHERE doc_type='doc_flow_in' AND doc_id = OLD.id;
		END IF;

		IF (const_client_lk_val() OR const_debug_val()) THEN
			DELETE FROM doc_flow_out_client WHERE id = OLD.from_doc_flow_out_client_id;
		END IF;
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_process() OWNER TO expert72;



-- ******************* update 29/11/2019 09:07:34 ******************
-- Function: doc_flow_in_process()

-- DROP FUNCTION doc_flow_in_process();

CREATE OR REPLACE FUNCTION doc_flow_in_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF
			(NOT const_client_lk_val() OR const_debug_val())
			AND NEW.reg_number IS NULL
			AND (
				--ЛЮБОЕ ОТ КЛИЕНТА
				--doc_flow_type_id=1 OR NEW.doc_flow_type_id=3
				NEW.from_application_id IS NOT NULL
			)
		THEN
			--назначим номер
			NEW.reg_number = doc_flow_in_next_num(NEW.doc_flow_type_id);
		END IF;
		
		RETURN NEW;

	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		IF (NOT const_client_lk_val() OR const_debug_val()) THEN
			DELETE FROM doc_flow_in_processes WHERE doc_flow_in_id = OLD.id;
			DELETE FROM doc_flow_out WHERE doc_flow_in_id = OLD.id;
			DELETE FROM doc_flow_attachments WHERE doc_type='doc_flow_in' AND doc_id = OLD.id;
		END IF;

		IF (const_client_lk_val() OR const_debug_val()) THEN
			UPDATE doc_flow_out_client
			SET sent = FALSE
			WHERE id = OLD.from_doc_flow_out_client_id;

		END IF;
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_process() OWNER TO expert72;



-- ******************* update 03/12/2019 11:03:31 ******************
-- VIEW: doc_flow_in_dialog

--DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',
						(SELECT
							json_agg(files_t.attachments) AS attachments
						FROM
							(SELECT
								t.doc_flow_out_client_id,
								json_build_object(
									'file_id',app_f.file_id,
									'file_name',app_f.file_name,
									'file_size',app_f.file_size,
									'file_signed',app_f.file_signed,
									'file_uploaded','true',
									'file_path',app_f.file_path,
									'is_switched',(clorg_f.new_file_id IS NOT NULL)
									,'signatures',
									(SELECT
										json_agg(sub.signatures) AS signatures
									FROM (
										SELECT 
											jsonb_build_object(
												'owner',u_certs.subject_cert,
												'cert_from',u_certs.date_time_from,
												'cert_to',u_certs.date_time_to,
												'sign_date_time',f_sig.sign_date_time,
												'check_result',ver.check_result,
												'check_time',ver.check_time,
												'error_str',ver.error_str
											) AS signatures
										FROM file_signatures AS f_sig
										LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
										LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
										WHERE f_sig.file_id=t.file_id
										ORDER BY f_sig.sign_date_time
									) AS sub
									)
								) AS attachments
							FROM doc_flow_out_client_document_files AS t
							LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
							LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
							LEFT JOIN doc_flow_out_client_original_files AS clorg_f ON clorg_f.doc_flow_out_client_id=t.doc_flow_out_client_id AND clorg_f.new_file_id=t.file_id
							WHERE
								coalesce(app_f.deleted,FALSE)=FALSE
								AND t.doc_flow_out_client_id=doc_flow_in.from_doc_flow_out_client_id
							ORDER BY app_f.file_path,app_f.file_name
							) AS files_t
						)
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',
						(SELECT
							json_agg(
								json_build_object(
									'file_id',t.file_id,
									'file_name',t.file_name,
									'file_size',t.file_size,
									'file_signed',t.file_signed,
									'file_uploaded','true'
								)
							) AS attachments			
						FROM doc_flow_attachments AS t
						WHERE t.doc_type='doc_flow_in'::data_types AND t.doc_id=doc_flow_in.id
						)		
						
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;

