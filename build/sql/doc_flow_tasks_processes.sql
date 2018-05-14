-- Function: doc_flow_tasks_process()

-- DROP FUNCTION doc_flow_tasks_process();

CREATE OR REPLACE FUNCTION doc_flow_tasks_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_ref JSONB;
	v_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE')) THEN
		IF NEW.closed THEN
			INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				doc_flow_tasks_ref(NEW),
				employees.id,
				'Закрыта задача '||(NEW.register_doc->>'descr')::text||', '||NEW.description,
				NEW.register_doc
			FROM employees
			WHERE
				(NEW.recipient->>'dataType'='employees' AND employees.id=(NEW.recipient->'keys'->>'id')::int)
				OR
				(NEW.recipient->>'dataType'='departments' AND employees.department_id=(NEW.recipient->'keys'->>'id')::int)
			);
		ELSE
			--remainder
			INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
			(SELECT
				doc_flow_tasks_ref(NEW),
				employees.id,
				CASE WHEN TG_OP='INSERT' THEN 'Добавлена задача ' ELSE 'Изменена задача ' END
					||(NEW.register_doc->>'descr')::text||', '||NEW.description,
				NEW.register_doc
			FROM employees
			WHERE
				(NEW.recipient->>'dataType'='employees' AND employees.id=(NEW.recipient->'keys'->>'id')::int)
				OR
				(NEW.recipient->>'dataType'='departments' AND employees.department_id=(NEW.recipient->'keys'->>'id')::int)
			);
			
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.recipient<>OLD.recipient THEN	
			DELETE FROM reminders WHERE register_docs_ref->>'dataType'='doc_flow_tasks' AND  (register_docs_ref->'keys'->>'id')::int=OLD.id;
		END IF;
		RETURN NEW;

	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		INSERT INTO reminders (register_docs_ref,recipient_employee_id,content,docs_ref)
		(SELECT
			doc_flow_tasks_ref(OLD),
			employees.id,
			'Закрыта задача '||(OLD.register_doc->>'descr')::text||', '||OLD.description,
			OLD.register_doc
		FROM employees
		WHERE
			(OLD.recipient->>'dataType'='employees' AND employees.id=(OLD.recipient->'keys'->>'id')::int)
			OR
			(OLD.recipient->>'dataType'='departments' AND employees.department_id=(OLD.recipient->'keys'->>'id')::int)
		);
	
		DELETE FROM reminders WHERE register_docs_ref->>'dataType'='doc_flow_tasks' AND  (register_docs_ref->'keys'->>'id')::int=OLD.id;
											
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_tasks_process() OWNER TO ;
