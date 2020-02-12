


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


-- ******************* update 13/12/2019 14:59:27 ******************
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
ALTER FUNCTION doc_flow_examinations_process() OWNER TO expert72;


-- ******************* update 16/01/2020 17:30:43 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20015',
		'Contract_Controller',
		'get_pd_cost_valid_eval_list',
		'ContractPdCostValidEvalList',
		'Документы',
		'Контракты ПД и достоверность (с 17/01/20)',
		FALSE
		);
	

-- ******************* update 18/01/2020 08:18:09 ******************

					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity';
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity_pd';
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity_eng_survey';
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity_pd_eng_survey';
	/* function */
	CREATE OR REPLACE FUNCTION enum_expertise_types_val(expertise_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='pd'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации'
		WHEN $1='eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза результатов инженерных изысканий'
		WHEN $1='pd_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации и Государственная экспертиза результатов инженерных изысканий'
		WHEN $1='cost_eval_validity'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза достоверности сметной стоимости'
		WHEN $1='cost_eval_validity_pd'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации и Государственная экспертиза достоверности сметной стоимости'
		WHEN $1='cost_eval_validity_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза результатов инженерных изысканий и Государственная экспертиза достоверности сметной стоимости'
		WHEN $1='cost_eval_validity_pd_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации, Государственная экспертиза результатов инженерных изысканий, Государственная экспертиза достоверности сметной стоимости'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_expertise_types_val(expertise_types,locales) OWNER TO expert72;		
		

-- ******************* update 18/01/2020 08:59:17 ******************
-- VIEW: applications_list

--DROP VIEW applications_list;

CREATE OR REPLACE VIEW applications_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		/*
		CASE
			WHEN st.state='sent' THEN
				bank_day_next(st.date_time::date,(SELECT const_application_check_days_val()))
			ELSE NULL
		END AS application_state_end_date,
		*/
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE WHEN l.expertise_type IS NOT NULL THEN
				CASE WHEN l.expertise_type='pd' THEN 'ПД'
				WHEN l.expertise_type='eng_survey' THEN 'РИИ'
				WHEN l.expertise_type='pd_eng_survey' THEN 'ПД и РИИ'
				WHEN l.expertise_type='cost_eval_validity' THEN 'Достоверность'
				WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД и Достоверность'
				WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ и Достоверность'
				ELSE 'ПД, РИИ, Достоверность'
				END||
				CASE WHEN l.exp_cost_eval_validity THEN ', Достоверность' ELSE '' END
			ELSE ''
			END||
			CASE WHEN l.cost_eval_validity THEN
				CASE WHEN l.expertise_type IS NOT NULL THEN ',' ELSE '' END || 'Достоверность'
			ELSE ''
			END||
			CASE WHEN l.modification THEN
				CASE WHEN l.expertise_type IS NOT NULL OR l.cost_eval_validity THEN ',' ELSE '' END|| 'Модификация'
			ELSE ''
			END||
			CASE WHEN l.audit THEN
				CASE WHEN l.expertise_type IS NOT NULL OR l.cost_eval_validity OR l.modification THEN ',' ELSE '' END|| 'Аудит'
			ELSE ''
			END
		) AS service_list,
		
		(
		SELECT json_agg(doc_flow_in_client_ref(in_docs))
		FROM doc_flow_in_client AS in_docs
		WHERE in_docs.application_id=l.id AND NOT coalesce(in_docs.viewed,FALSE)
		) AS unviewed_in_docs,
		
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date
				
	FROM applications AS l
	LEFT JOIN offices_list AS off ON off.id=l.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=l.id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=l.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
		
	ORDER BY l.user_id,l.create_dt DESC
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 18/01/2020 09:50:33 ******************
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
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				doc_flow_out_client_type,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				'app',
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
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
ALTER FUNCTION application_processes_process() OWNER TO expert72;



-- ******************* update 18/01/2020 10:06:28 ******************
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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

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
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='cost_eval_validity' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity OR d.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		d.filled_percent,
		d.exp_cost_eval_validity,
		
		d.fund_percent
		
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
	) AS folders ON folders.application_id=d.id
	--ORDER BY d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;



-- ******************* update 18/01/2020 10:47:21 ******************
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
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
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
		
			-- Если отправка из статуса correcting то уведомление отделу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						
						--17/01/2020
						WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
						
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				doc_flow_out_client_type,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'

					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'ПД, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'ПД, РИИ, Достоверность'
					
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					
					--17/01/2020
					WHEN app.expertise_type='cost_eval_validity'::expertise_types THEN 'экспертизу проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd'::expertise_types THEN 'экспертизу проектной документации и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий и проверки достоверености сметной стоимости'
					WHEN app.expertise_type='cost_eval_validity_pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации, результатов инженерных изысканий и проверки достоверености сметной стоимости'
					
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				'app',
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
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
ALTER FUNCTION application_processes_process() OWNER TO expert72;



-- ******************* update 20/01/2020 09:44:14 ******************
-- VIEW: applications_dialog_lk

--DROP VIEW contracts_dialog_lk;
--DROP VIEW applications_dialog_lk;

CREATE OR REPLACE VIEW applications_dialog_lk AS
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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		greatest(st.state,st_lk.state) AS application_state,
		greatest(st.date_time,st_lk.date_time) AS application_state_dt,
		greatest(st.end_date_time,st_lk.end_date_time) AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='cost_eval_validity' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity OR d.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
	--*****
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes_lk t
		GROUP BY t.application_id
	) AS h_max_lk ON h_max_lk.application_id=d.id
	LEFT JOIN application_processes_lk st_lk
		ON st_lk.application_id=h_max_lk.application_id AND st_lk.date_time = h_max_lk.date_time	
	--*****
		
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
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							json_build_array(
								json_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',adf.file_signed_by_client,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_document_files adf
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
		LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
		--LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
		LEFT JOIN file_verifications_lk AS f_ver ON f_ver.file_id=adf.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
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
			FROM file_signatures_lk AS f_sig
			LEFT JOIN file_verifications_lk AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates_lk AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE adf.document_type='documents'
		GROUP BY adf.application_id,adf.file_path,app_fd.id
		ORDER BY app_fd.id)  AS doc_att	
		
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog_lk OWNER TO expert72;



-- ******************* update 20/01/2020 13:05:42 ******************
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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

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
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='cost_eval_validity' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity OR d.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		d.filled_percent,
		d.exp_cost_eval_validity,
		
		d.fund_percent,
		
		d.update_dt
		
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
	) AS folders ON folders.application_id=d.id
	--ORDER BY d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;



-- ******************* update 20/01/2020 13:24:53 ******************

		CREATE TABLE applications_returned_files_removed
		(application_id int NOT NULL REFERENCES applications(id),date_time timestampTZ
			DEFAULT CURRENT_TIMESTAMP NOT NULL,CONSTRAINT applications_returned_files_removed_pkey PRIMARY KEY (application_id)
		);
		ALTER TABLE applications_returned_files_removed OWNER TO expert72;
		

-- ******************* update 20/01/2020 13:37:23 ******************
delete FROM views where id='20015';
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20015',
		'ApplicationReturnedFilesRemoved_Controller',
		'get_list',
		'ApplicationReturnedFilesRemovedList',
		'Документы',
		'Заявления с удаленной документацией',
		FALSE
		);
	


-- ******************* update 20/01/2020 13:47:18 ******************
-- VIEW: applications_returned_files_removed_list

--DROP VIEW applications_returned_files_removed_list;

CREATE OR REPLACE VIEW applications_returned_files_removed_list AS
	SELECT
		t.application_id,
		t.date_time,
		applications_ref(app) AS applications_ref
		
	FROM applications_returned_files_removed AS t
	LEFT JOIN applications AS app ON app.id=t.application_id
	ORDER BY date_time DESC
	;
	
ALTER VIEW applications_returned_files_removed_list OWNER TO expert72;


-- ******************* update 20/01/2020 13:55:56 ******************
-- VIEW: application_document_files_list

--DROP VIEW application_document_files_list;

CREATE OR REPLACE VIEW application_document_files_list AS
	SELECT
		t.file_id,
		t.application_id,
		applications_ref(app) AS applications_ref,
		t.document_id,
		t.document_type,
		t.date_time,
		t.file_name,
		t.file_path,
		t.file_signed,
		t.file_size,
		t.deleted,
		t.deleted_dt,
		t.file_signed_by_client,
		t.information_list
		
	FROM application_document_files AS t
	LEFT JOIN applications AS app ON app.id=t.application_id
	ORDER BY t.application_id DESC,t.document_type,t.file_name
	;
	
ALTER VIEW application_document_files_list OWNER TO expert72;


-- ******************* update 20/01/2020 14:08:02 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20016',
		'ApplicationDocumentFile_Controller',
		'get_list',
		'ApplicationDocumentFileList',
		'Документы',
		'Файлы заявлений',
		FALSE
		);
	

-- ******************* update 21/01/2020 12:25:49 ******************
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
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
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



-- ******************* update 27/01/2020 12:03:01 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20017',
		'Contract_Controller',
		'get_expertise_list',
		'ContractExpertiseList',
		'Документы',
		'Контракты по гос.экспертизе',
		FALSE
		);
	

-- ******************* update 28/01/2020 14:57:33 ******************

		ALTER TABLE contracts ADD COLUMN allow_client_out_documents bool
			DEFAULT FALSE;



-- ******************* update 28/01/2020 14:58:48 ******************
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
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		t.allow_new_file_add,
		t.allow_client_out_documents
		
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



-- ******************* update 28/01/2020 15:53:57 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_ban_client_responses_day_cnt
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_ban_client_responses_day_cnt OWNER TO expert72;
		INSERT INTO const_ban_client_responses_day_cnt (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'За сколько рабочих дней запрещать отправку ответов на замечания'
			,'За данное количество рабочих дней до окончания срока экспертизы клиентам будет запрещена отправка писем с видом ответы на замечания'
			,NULL
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_ban_client_responses_day_cnt_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_ban_client_responses_day_cnt LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_ban_client_responses_day_cnt_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_ban_client_responses_day_cnt_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_ban_client_responses_day_cnt SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_ban_client_responses_day_cnt_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_ban_client_responses_day_cnt_view AS
		SELECT
			'ban_client_responses_day_cnt'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_ban_client_responses_day_cnt AS t
		;
		ALTER VIEW const_ban_client_responses_day_cnt_view OWNER TO expert72;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_session_live_time_view
		UNION ALL
		SELECT *
		FROM const_client_download_file_types_view
		UNION ALL
		SELECT *
		FROM const_client_download_file_max_size_view
		UNION ALL
		SELECT *
		FROM const_employee_download_file_types_view
		UNION ALL
		SELECT *
		FROM const_employee_download_file_max_size_view
		UNION ALL
		SELECT *
		FROM const_application_check_days_view
		UNION ALL
		SELECT *
		FROM const_app_recipient_department_view
		UNION ALL
		SELECT *
		FROM const_client_lk_view
		UNION ALL
		SELECT *
		FROM const_debug_view
		UNION ALL
		SELECT *
		FROM const_reminder_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_outmail_data_view
		UNION ALL
		SELECT *
		FROM const_reminder_show_days_view
		UNION ALL
		SELECT *
		FROM const_cades_verify_after_signing_view
		UNION ALL
		SELECT *
		FROM const_cades_include_certificate_view
		UNION ALL
		SELECT *
		FROM const_cades_signature_type_view
		UNION ALL
		SELECT *
		FROM const_cades_hash_algorithm_view
		UNION ALL
		SELECT *
		FROM const_contract_document_visib_expert_list_view
		UNION ALL
		SELECT *
		FROM const_ban_client_responses_day_cnt_view;
		ALTER VIEW constants_list_view OWNER TO expert72;
	

-- ******************* update 31/01/2020 15:47:31 ******************
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
	v_is_expertise_cost_budget bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
							-- С 2020 если вернули подписанный контракт
							-- и при этом у нас бюджтное финансирование
							--  то статус сразу же поставим - экспертиза проекта!
							WHEN 
								v_application_state='waiting_for_contract'
								AND v_contract_return_date IS NOT NULL
								AND v_is_expertise_cost_budget THEN
									'expertise'::application_states
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



-- ******************* update 31/01/2020 16:22:38 ******************
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
	v_is_expertise_cost_budget bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
				RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							-- С 2020 если вернули подписанный контракт
							-- и при этом у нас бюджтное финансирование
							--  то статус сразу же поставим - экспертиза проекта!
							WHEN 
								v_application_state='waiting_for_contract'
								AND v_contract_return_date IS NOT NULL
								AND v_is_expertise_cost_budget THEN
									'expertise'::application_states
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



-- ******************* update 31/01/2020 16:27:04 ******************
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
	v_is_expertise_cost_budget bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
				RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							-- С 2020 если вернули подписанный контракт
							-- и при этом у нас бюджтное финансирование
							--  то статус сразу же поставим - экспертиза проекта!
							WHEN 
								v_application_state='waiting_for_contract'
								AND v_contract_return_date IS NOT NULL
								AND v_is_expertise_cost_budget THEN
									'expertise'::application_states
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



-- ******************* update 31/01/2020 18:01:42 ******************
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
	v_is_expertise_cost_budget bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							-- С 2020 если вернули подписанный контракт
							-- и при этом у нас бюджтное финансирование
							--  то статус сразу же поставим - экспертиза проекта!
							WHEN 
								v_application_state='waiting_for_contract'
								AND v_contract_return_date IS NOT NULL
								AND v_is_expertise_cost_budget THEN
									'expertise'::application_states
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



-- ******************* update 31/01/2020 18:01:51 ******************
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
	v_is_expertise_cost_budget bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
				RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							-- С 2020 если вернули подписанный контракт
							-- и при этом у нас бюджтное финансирование
							--  то статус сразу же поставим - экспертиза проекта!
							WHEN 
								v_application_state='waiting_for_contract'
								AND v_contract_return_date IS NOT NULL
								AND v_is_expertise_cost_budget THEN
									'expertise'::application_states
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



-- ******************* update 31/01/2020 18:02:19 ******************
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
	v_is_expertise_cost_budget bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							-- С 2020 если вернули подписанный контракт
							-- и при этом у нас бюджтное финансирование
							--  то статус сразу же поставим - экспертиза проекта!
							WHEN 
								v_application_state='waiting_for_contract'
								AND v_contract_return_date IS NOT NULL
								AND v_is_expertise_cost_budget THEN
									'expertise'::application_states
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



-- ******************* update 31/01/2020 18:21:24 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
				
				UPDATE contracts
				SET
					contract_return_date = coalesce(v_contract_return_date,NEW.date_time::date),
					contract_date = coalesce(v_contract_return_date,NEW.date_time),
					contract_return_date_on_sig = (v_contract_return_date IS NOT NULL),
					work_start_date =CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date ELSE work_start_date END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 31/01/2020 18:28:55 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
				
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date ELSE work_start_date END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 31/01/2020 18:36:08 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
				
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 03/02/2020 08:41:32 ******************

		ALTER TABLE applications ADD COLUMN customer_auth_letter text,ADD COLUMN customer_auth_letter_file jsonb;



-- ******************* update 03/02/2020 08:43:03 ******************
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
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		t.allow_new_file_add,
		t.allow_client_out_documents,
		
		app.customer_auth_letter
		
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



-- ******************* update 03/02/2020 09:21:16 ******************

		ALTER TABLE applications ADD COLUMN customer_is_developer bool
			DEFAULT FALSE;



-- ******************* update 03/02/2020 17:39:14 ******************
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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

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
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='cost_eval_validity' OR d.expertise_type='cost_eval_validity_pd' OR d.expertise_type='cost_eval_validity_eng_survey' OR d.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity OR d.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		d.filled_percent,
		d.exp_cost_eval_validity,
		
		d.fund_percent,
		
		d.update_dt,
		
		d.customer_auth_letter,
		d.customer_auth_letter_file
		
		
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
	) AS folders ON folders.application_id=d.id
	--ORDER BY d.id
	;
	
ALTER VIEW applications_dialog OWNER TO expert72;



-- ******************* update 04/02/2020 09:05:34 ******************
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
		
		CASE WHEN (app.customer->>'customer_is_developer')::bool THEN applications_client_descr(app.developer)
		ELSE applications_client_descr(app.customer)
		END AS customer_descr,
		
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
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		t.allow_new_file_add,
		t.allow_client_out_documents,
		
		app.customer_auth_letter
		
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



-- ******************* update 04/02/2020 09:06:41 ******************
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
		
		CASE WHEN (app.customer->>'customer_is_developer')::bool THEN 'Является застройщиком'--applications_client_descr(app.developer)
		ELSE applications_client_descr(app.customer)
		END AS customer_descr,
		
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
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		t.allow_new_file_add,
		t.allow_client_out_documents,
		
		app.customer_auth_letter
		
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



-- ******************* update 04/02/2020 09:07:12 ******************
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
		
		CASE WHEN (app.customer->>'customer_is_developer')::bool THEN applications_client_descr(app.developer)
		ELSE applications_client_descr(app.customer)
		END AS customer_descr,
		
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
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		t.allow_new_file_add,
		t.allow_client_out_documents,
		
		app.customer_auth_letter
		
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



-- ******************* update 04/02/2020 13:19:13 ******************
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
								AND app_f.file_id IS NOT NULL
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


-- ******************* update 04/02/2020 13:25:09 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
				
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 04/02/2020 14:24:01 ******************
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
								--coalesce(app_f.deleted,FALSE)=FALSE
								--AND
								t.doc_flow_out_client_id=doc_flow_in.from_doc_flow_out_client_id
								AND app_f.file_id IS NOT NULL
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


-- ******************* update 10/02/2020 12:21:21 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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
RAISE EXCEPTION 'v_contract_return_date=%',v_contract_return_date;
				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
				
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								'bank'::date_types,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 10/02/2020 12:29:31 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
RAISE EXCEPTION 'v_contract_return_date=%',v_contract_return_date;				
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 10/02/2020 12:30:19 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
RAISE EXCEPTION 'v_contract_return_date=%',v_contract_return_date;				
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 10/02/2020 12:32:33 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
RAISE EXCEPTION 'contracts_work_end_date=%',(SELECT contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expertise_day_count
							)
						FROM contracts
						WHERE contracts.id=v_contract_id
					);
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								contract_date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 10/02/2020 12:33:27 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
RAISE EXCEPTION 'contracts_work_end_date=%',(SELECT contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expertise_day_count
							)
						FROM contracts
						WHERE contracts.id=v_contract_id
					);
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 10/02/2020 12:34:09 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
RAISE EXCEPTION 'contracts_work_end_date=%',(SELECT contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						FROM contracts
						WHERE contracts.id=v_contract_id
					);
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 10/02/2020 12:34:31 ******************
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
	v_is_expertise_cost_budget bool;
	v_set_budget_contrcat_date bool;
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
				contracts.employee_id,
				(coalesce(contracts.expertise_cost_budget,0)>0)
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
				v_contract_employee_id,
				v_is_expertise_cost_budget
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0 AND app_f.file_id IS NOT NULL
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

				-- С 2020 если вернули подписанный контракт
				-- и при этом у нас бюджтное финансирование
				--  то статус сразу же поставим - экспертиза проекта!
				v_set_budget_contrcat_date = (
					v_application_state='waiting_for_contract'
					AND v_contract_return_date IS NOT NULL
					AND v_is_expertise_cost_budget
				);
/*				
RAISE EXCEPTION 'contracts_work_end_date=%',(SELECT contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						FROM contracts
						WHERE contracts.id=v_contract_id
					);
*/					
				UPDATE contracts
				SET
					contract_return_date =
						CASE WHEN contract_return_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time::date)
						ELSE contract_return_date
						END,
					contract_date =
						CASE WHEN contract_date IS NULL THEN coalesce(v_contract_return_date,NEW.date_time)
						ELSE contract_date
						END,
					contract_return_date_on_sig =
						CASE WHEN contract_return_date IS NULL THEN (v_contract_return_date IS NOT NULL)
						ELSE contract_return_date_on_sig
						END,
					work_start_date =
						CASE WHEN v_set_budget_contrcat_date THEN v_contract_return_date
						ELSE work_start_date
						END,
					work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expertise_day_count
							)
						ELSE work_end_date
						END,
					expert_work_end_date =
						CASE WHEN v_set_budget_contrcat_date THEN
							contracts_work_end_date(
								v_office_id,
								date_type,
								v_contract_return_date,
								expert_work_day_count
							)
						ELSE expert_work_end_date
					END
				WHERE id=v_contract_id AND (v_set_budget_contrcat_date OR contract_return_date IS NULL);
				--coalesce(contract_return_date_on_sig,FALSE)=FALSE;
				--RAISE EXCEPTION 'v_application_state=%, v_is_expertise_cost_budget=%, v_contract_return_date=%',v_application_state,v_is_expertise_cost_budget, v_contract_return_date;
				
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
							WHEN v_set_budget_contrcat_date THEN 'expertise'::application_states
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



-- ******************* update 11/02/2020 07:53:04 ******************
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
ALTER FUNCTION client_payments_process() OWNER TO expert72;


