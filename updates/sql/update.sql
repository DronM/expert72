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