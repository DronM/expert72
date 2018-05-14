-- Function: doc_flow_approvements_process()

-- DROP FUNCTION doc_flow_approvements_process();

CREATE OR REPLACE FUNCTION doc_flow_approvements_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		--v_ref = doc_flow_approvements_ref((SELECT doc_flow_approvements FROM doc_flow_approvements WHERE id=NEW.id));
		--статус
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
		
		PERFORM doc_flow_approvements_add_task_for_step(NEW,1);
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		--state
		IF NEW.date_time<>OLD.date_time
			OR NEW.end_date_time<>OLD.end_date_time
			OR NEW.doc_flow_importance_type_id<>OLD.doc_flow_importance_type_id
			OR NEW.subject_doc<>OLD.subject_doc
			OR NEW.subject<>OLD.subject
		THEN
			UPDATE doc_flow_out_processes
			SET
				date_time			= NEW.date_time,
				doc_flow_importance_type_id	= NEW.doc_flow_importance_type_id,
				doc_flow_out_id			= (NEW.subject_doc->'keys'->>'id')::int,
				description			= NEW.subject,
				end_date_time			= NEW.end_date_time
			WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=NEW.id;
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
		END IF;
							
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		--setting step count
		SELECT max(steps.step)
		INTO NEW.step_count
		FROM (
			SELECT (jsonb_array_elements(NEW.recipient_list->'rows')->'fields'->>'step')::int AS step
		) steps;
		
		IF TG_OP='INSERT' AND NEW.step_count>0 THEN
			NEW.current_step = 1;
		END IF;
										
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--статус
		DELETE FROM doc_flow_out_processes WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
		
		--задачи
		DELETE FROM doc_flow_tasks WHERE register_doc->>'dataType'='doc_flow_approvements' AND (register_doc->'keys'->>'id')::int=OLD.id;
											
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_process() OWNER TO ;
