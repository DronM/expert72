-- ******************* update 14/01/2019 09:59:16 ******************

		CREATE TABLE expertise_prolongations
		(contract_id int NOT NULL REFERENCES contracts(id),date_time timestamp
			DEFAULT CURRENT_TIMESTAMP NOT NULL,day_count int NOT NULL,date_type date_types,new_end_date date,employee_id int NOT NULL REFERENCES employees(id),comment_text text,CONSTRAINT expertise_prolongations_pkey PRIMARY KEY (contract_id,date_time)
		);
		ALTER TABLE expertise_prolongations OWNER TO expert72;


-- ******************* update 14/01/2019 10:01:03 ******************
-- VIEW: expertise_prolongations_list

--DROP VIEW expertise_prolongations_list;

CREATE OR REPLACE VIEW expertise_prolongations_list AS
	SELECT
		t.*,
		employees_ref(e) AS employees_ref
	FROM expertise_prolongations AS t
	LEFT JOIN employees AS e ON e.id=t.employee_id
	;
	
ALTER VIEW expertise_prolongations_list OWNER TO expert72;

-- ******************* update 14/01/2019 10:10:14 ******************
-- VIEW: expertise_prolongations_list

--DROP VIEW expertise_prolongations_list;

CREATE OR REPLACE VIEW expertise_prolongations_list AS
	SELECT
		t.*,
		employees_ref(e) AS employees_ref,
		contracts_ref(ct) AS contracts_ref
	FROM expertise_prolongations AS t
	LEFT JOIN employees AS e ON e.id=t.employee_id
	LEFT JOIN contracts AS ct ON ct.id=t.contract_id
	;
	
ALTER VIEW expertise_prolongations_list OWNER TO expert72;

-- ******************* update 14/01/2019 10:47:33 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10030',
		'ExpertiseProlongation_Controller',
		'get_list',
		'ExpertiseProlongationList',
		'Справочники',
		'Продление экспертизы',
		FALSE
		);
	
-- ******************* update 15/01/2019 09:15:12 ******************
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
		(SELECT
			app_p.id AS app_p_id
		FROM application_processes AS app_p
		WHERE app_p.application_id=(SELECT ct.application_id FROM contracts ct WHERE ct.id=1446)
			AND app_p.state='expertise'	
		) AS sel ON sel.app_p_id=application_processes.id;
		
		GET affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:15:45 ******************
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
			app_p.id AS app_p_id
		FROM application_processes AS app_p
		WHERE app_p.application_id=(SELECT ct.application_id FROM contracts ct WHERE ct.id=1446)
			AND app_p.state='expertise'	
		) AS sel ON sel.app_p_id=application_processes.id;
		
		GET affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:15:57 ******************
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
			app_p.id AS app_p_id
		FROM application_processes AS app_p
		WHERE app_p.application_id=(SELECT ct.application_id FROM contracts ct WHERE ct.id=1446)
			AND app_p.state='expertise'	
		) AS sel
		WHERE sel.app_p_id=application_processes.id;
		
		GET affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:16:45 ******************
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
			app_p.id AS app_p_id
		FROM application_processes AS app_p
		WHERE app_p.application_id=(SELECT ct.application_id FROM contracts ct WHERE ct.id=1446)
			AND app_p.state='expertise'	
		) AS sel
		WHERE sel.app_p_id=application_processes.id;
		
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:17:00 ******************
-- Trigger: expertise_prolongations_trigger on public.expertise_prolongations

-- DROP TRIGGER expertise_prolongations_trigger ON public.expertise_prolongations;

CREATE TRIGGER expertise_prolongations_trigger
  BEFORE UPDATE OR INSERT
  ON public.expertise_prolongations
  FOR EACH ROW
  EXECUTE PROCEDURE public.expertise_prolongations_process();


-- ******************* update 15/01/2019 09:18:46 ******************
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
		
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:21:01 ******************
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
		
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
		UPDATE contracts
		SET
			work_end_date = NEW.new_end_date;
		WHERE id = NEW.contract_id;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:21:08 ******************
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
		
		GET DIAGNOSTICS affected_rows = ROW_COUNT;
		IF affected_rows=0 OR affected_rows IS NULL THEN
			RAISE EXCEPTION 'Статус "экспертиза" не найден!';
		END IF;
		
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
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;
	

-- ******************* update 15/01/2019 09:21:41 ******************
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
ALTER FUNCTION expertise_prolongations_process() OWNER TO expert72;