-- Function: expertise_prolongations_process()

-- DROP FUNCTION expertise_prolongations_process();

CREATE OR REPLACE FUNCTION expertise_prolongations_process()
  RETURNS trigger AS
$BODY$
DECLARE
	affected_rows integer;
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN		
		UPDATE application_processes
		SET
			end_date_time = NEW.new_end_date,
			user_id = (SELECT emp.user_id FROM employees emp WHERE emp.id=NEW.employee_id)
		FROM (SELECT
			app_p.application_id,
			app_p.date_time
		FROM application_processes AS app_p
		WHERE app_p.application_id=(SELECT ct.application_id FROM contracts ct WHERE ct.id=1446)
			AND app_p.state='expertise'	
		) AS sel
		WHERE sel.application_id=application_processes.application_id AND sel.date_time=application_processes.date_time;
		
		--Error if state not found
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		--update contract data
		UPDATE contracts
		SET
			work_end_date = NEW.new_end_date
		WHERE id = NEW.contract_id;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO ;
	
