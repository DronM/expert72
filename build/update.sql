
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
	

-- ******************* update 17/01/2019 11:47:34 ******************
﻿-- Function: email_warn_work_end(warn_period_days int)

-- DROP FUNCTION email_warn_work_end(warn_period_days int);

CREATE OR REPLACE FUNCTION email_warn_work_end(warn_period_days int)
  RETURNS void AS
$$
	INSERT INTO mail_for_sending
		(from_addr,from_name,
		to_addr,to_name,
		reply_addr,reply_name,
		sender_addr,subject,body,email_type)
	(
	WITH 
		templ AS (
			SELECT t.template AS v,t.mes_subject AS s
			FROM email_templates t
			WHERE t.email_type='warn_work_end'
		),
		outmail_data AS (
			SELECT
				t->>'from_addr' AS from_addr,
				t->>'from_name' AS from_name	
			FROM const_outmail_data_val() AS t
		)
	--Пользователи	
	(SELECT
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		u.email,
		u.name_full,
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT s FROM templ),
		
		sms_templates_text(
			ARRAY[
				ROW('end_date',to_char(contr.work_end_date,'DD/MM/YYYY'))::template_value,
				ROW('contract_number',contr.contract_number::text)::template_value,
				ROW('contract_date',to_char(contr.contract_date,'DD/MM/YYYY'))::template_value,
				ROW('user_name',u.name_full::text)::template_value,
				ROW('applicant',app.applicant->>'name')::template_value,
				ROW('constr_name',coalesce(contr.constr_name,app.constr_name)::text)::template_value
			],
			(SELECT v FROM templ)
		),
		'warn_work_end'::email_types
	FROM contracts contr
	LEFT JOIN applications AS app ON app.id=contr.application_id
	LEFT JOIN users AS u ON u.id=app.user_id
	WHERE contr.work_end_date=(SELECT d2::date FROM applications_check_period(app.office_id,now(),$1) AS (d1 timestampTZ,d2 timestampTZ))
		AND u.email_confirmed
	)
	
	UNION ALL
	--Сотрудник - ответственные эксперты
	(SELECT
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		u.email,
		u.name_full,
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT s FROM templ),
		
		sms_templates_text(
			ARRAY[
				ROW('end_date',to_char(contr.work_end_date,'DD/MM/YYYY'))::template_value,
				ROW('contract_number',contr.contract_number::text)::template_value,
				ROW('contract_date',to_char(contr.contract_date,'DD/MM/YYYY'))::template_value,
				ROW('user_name',u.name_full::text)::template_value,
				ROW('applicant',app.applicant->>'name')::template_value,
				ROW('constr_name',coalesce(contr.constr_name,app.constr_name)::text)::template_value
			],
			(SELECT v FROM templ)
		),
		'warn_work_end'::email_types
	FROM contracts contr
	LEFT JOIN applications AS app ON app.id=contr.application_id
	LEFT JOIN employees AS emp ON emp.id=contr.main_expert_id
	LEFT JOIN users AS u ON u.id=emp.user_id
	WHERE contr.work_end_date=(SELECT d2::date FROM applications_check_period(app.office_id,now(),$1) AS (d1 timestampTZ,d2 timestampTZ))
		AND u.email_confirmed		
	)
	
	);

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_warn_work_end(warn_period_days int) OWNER TO expert72;

-- ******************* update 17/01/2019 11:49:22 ******************
﻿-- Function: email_warn_expert_work_end(warn_period_days int)

-- DROP FUNCTION email_warn_expert_work_end(warn_period_days int);

CREATE OR REPLACE FUNCTION email_warn_expert_work_end(warn_period_days int)
  RETURNS void AS
$$
	INSERT INTO mail_for_sending
		(from_addr,from_name,
		to_addr,to_name,
		reply_addr,reply_name,
		sender_addr,subject,body,email_type)
	(
	WITH 
		templ AS (
			SELECT t.template AS v,t.mes_subject AS s
			FROM email_templates t
			WHERE t.email_type='warn_expert_work_end'
		),
		outmail_data AS (
			SELECT
				t->>'from_addr' AS from_addr,
				t->>'from_name' AS from_name	
			FROM const_outmail_data_val() AS t
		)
	--Пользователи		
	(SELECT
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		u.email,
		u.name_full,
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT s FROM templ),
		
		sms_templates_text(
			ARRAY[
				ROW('end_date',to_char(contr.expert_work_end_date,'DD/MM/YYYY'))::template_value,
				ROW('contract_number',contr.contract_number::text)::template_value,
				ROW('contract_date',to_char(contr.contract_date,'DD/MM/YYYY'))::template_value,
				ROW('user_name',u.name_full::text)::template_value,
				ROW('applicant',app.applicant->>'name')::template_value,
				ROW('constr_name',coalesce(contr.constr_name,app.constr_name)::text)::template_value
			],
			(SELECT v FROM templ)
		),
		'warn_expert_work_end'::email_types
	FROM contracts contr
	LEFT JOIN applications AS app ON app.id=contr.application_id
	LEFT JOIN users AS u ON u.id=app.user_id
	WHERE contr.expert_work_end_date=(SELECT d2::date FROM applications_check_period(app.office_id,now(),$1) AS (d1 timestampTZ,d2 timestampTZ))
		AND u.email_confirmed
	)
	
	UNION ALL
	--Сотрудник - ответственные эксперты
	(SELECT
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		u.email,
		u.name_full,
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT outmail_data.from_name FROM outmail_data),
		(SELECT outmail_data.from_addr FROM outmail_data),
		(SELECT s FROM templ),
		
		sms_templates_text(
			ARRAY[
				ROW('end_date',to_char(contr.expert_work_end_date,'DD/MM/YYYY'))::template_value,
				ROW('contract_number',contr.contract_number::text)::template_value,
				ROW('contract_date',to_char(contr.contract_date,'DD/MM/YYYY'))::template_value,
				ROW('user_name',u.name_full::text)::template_value,
				ROW('applicant',app.applicant->>'name')::template_value,
				ROW('constr_name',coalesce(contr.constr_name,app.constr_name)::text)::template_value
			],
			(SELECT v FROM templ)
		),
		'warn_expert_work_end'::email_types
	FROM contracts contr
	LEFT JOIN applications AS app ON app.id=contr.application_id
	LEFT JOIN employees AS emp ON emp.id=contr.main_expert_id
	LEFT JOIN users AS u ON u.id=emp.user_id
	WHERE contr.expert_work_end_date=(SELECT d2::date FROM applications_check_period(app.office_id,now(),$1) AS (d1 timestampTZ,d2 timestampTZ))
		AND u.email_confirmed
	)
	
	);

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_warn_expert_work_end(warn_period_days int) OWNER TO expert72;

-- ******************* update 17/01/2019 12:43:00 ******************
/*
CREATE TYPE template_value AS (
    field   text,
    value	text
);
*/

-- Function: sms_templates_text(template_value[],text)

-- DROP FUNCTION sms_templates_text(template_value[],text);

CREATE OR REPLACE FUNCTION sms_templates_text(template_value[],text)
	RETURNS text AS
$BODY$
DECLARE
   v_value template_value;
   v_text text;
BEGIN
	v_text = $2;
	FOREACH v_value IN ARRAY $1
	LOOP
		v_text = replace(v_text,
				'['||v_value.field||']',
				COALESCE(v_value.value,'')
		);
	END LOOP;
	
	RETURN Ev_text;
END
$BODY$
  LANGUAGE plpgsql COST 100;
  
ALTER FUNCTION sms_templates_text(template_value[],text) OWNER TO expert72;

-- ******************* update 17/01/2019 12:50:56 ******************
/*
CREATE TYPE template_value AS (
    field   text,
    value	text
);
*/

-- Function: sms_templates_text(template_value[],text)

-- DROP FUNCTION sms_templates_text(template_value[],text);

CREATE OR REPLACE FUNCTION sms_templates_text(template_value[],text)
	RETURNS text AS
$BODY$
DECLARE
   v_value template_value;
   v_text text;
BEGIN
	v_text = $2;
	FOREACH v_value IN ARRAY $1
	LOOP
		v_text = replace(v_text,
				'['||v_value.field||']',
				COALESCE(v_value.value,'')
		);
	END LOOP;
	
	RETURN E(v_text);
END
$BODY$
  LANGUAGE plpgsql COST 100;
  
ALTER FUNCTION sms_templates_text(template_value[],text) OWNER TO expert72;

-- ******************* update 17/01/2019 12:51:28 ******************
/*
CREATE TYPE template_value AS (
    field   text,
    value	text
);
*/

-- Function: sms_templates_text(template_value[],text)

-- DROP FUNCTION sms_templates_text(template_value[],text);

CREATE OR REPLACE FUNCTION sms_templates_text(template_value[],text)
	RETURNS text AS
$BODY$
DECLARE
   v_value template_value;
   v_text text;
BEGIN
	v_text = $2;
	FOREACH v_value IN ARRAY $1
	LOOP
		v_text = replace(v_text,
				'['||v_value.field||']',
				COALESCE(v_value.value,'')
		);
	END LOOP;
	
	RETURN E''||v_text;
END
$BODY$
  LANGUAGE plpgsql COST 100;
  
ALTER FUNCTION sms_templates_text(template_value[],text) OWNER TO expert72;

-- ******************* update 17/01/2019 13:01:40 ******************
/*
CREATE TYPE template_value AS (
    field   text,
    value	text
);
*/

-- Function: sms_templates_text(template_value[],text)

-- DROP FUNCTION sms_templates_text(template_value[],text);

CREATE OR REPLACE FUNCTION sms_templates_text(template_value[],text)
	RETURNS text AS
$BODY$
DECLARE
   v_value template_value;
   v_text text;
BEGIN
	v_text = $2;
	FOREACH v_value IN ARRAY $1
	LOOP
		v_text = replace(v_text,
				'['||v_value.field||']',
				COALESCE(v_value.value,'')
		);
	END LOOP;
	
	RETURN v_text;
END
$BODY$
  LANGUAGE plpgsql COST 100;
  
ALTER FUNCTION sms_templates_text(template_value[],text) OWNER TO expert72;

-- ******************* update 18/01/2019 07:42:57 ******************
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
					WHERE doc_f.doc_flow_out_client_id=NEW.id AND app_f.document_id<>0
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
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 18/01/2019 07:47:42 ******************
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
		
		END IF;
	
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_process() OWNER TO expert72;


-- ******************* update 25/01/2019 11:26:15 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_contract_document_visib_expert_list
		(name text, descr text, val json,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_contract_document_visib_expert_list OWNER TO expert72;
		INSERT INTO const_contract_document_visib_expert_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Список экспертов, у которых доступна закладка 'Документы' в контракте'
			,'Закладка 'Документы' в контракте не доступна для роли 'эксперт'. Однако можно задать список экспертов, для которых закладка будет видима.'
			,NULL
			,'JSON'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_val()
		RETURNS json AS
		$BODY$
			SELECT val::json AS val FROM const_contract_document_visib_expert_list LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_set_val(JSON)
		RETURNS void AS
		$BODY$
			UPDATE const_contract_document_visib_expert_list SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_set_val(JSON) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_contract_document_visib_expert_list_view AS
		SELECT
			'contract_document_visib_expert_list'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_contract_document_visib_expert_list AS t
		;
		ALTER VIEW const_contract_document_visib_expert_list_view OWNER TO expert72;
	
-- ******************* update 25/01/2019 11:26:36 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_contract_document_visib_expert_list
		(name text, descr text, val json,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_contract_document_visib_expert_list OWNER TO expert72;
		INSERT INTO const_contract_document_visib_expert_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Список экспертов, у которых доступна закладка \'Документы\' в контракте'
			,'Закладка \'Документы\' в контракте не доступна для роли 'эксперт'. Однако можно задать список экспертов, для которых закладка будет видима.'
			,NULL
			,'JSON'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_val()
		RETURNS json AS
		$BODY$
			SELECT val::json AS val FROM const_contract_document_visib_expert_list LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_set_val(JSON)
		RETURNS void AS
		$BODY$
			UPDATE const_contract_document_visib_expert_list SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_set_val(JSON) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_contract_document_visib_expert_list_view AS
		SELECT
			'contract_document_visib_expert_list'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_contract_document_visib_expert_list AS t
		;
		ALTER VIEW const_contract_document_visib_expert_list_view OWNER TO expert72;
	

-- ******************* update 25/01/2019 11:26:55 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_contract_document_visib_expert_list
		(name text, descr text, val json,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_contract_document_visib_expert_list OWNER TO expert72;
		INSERT INTO const_contract_document_visib_expert_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Список экспертов, у которых доступна закладка "Документы" в контракте'
			,'Закладка "Документы" в контракте не доступна для роли 'эксперт'. Однако можно задать список экспертов, для которых закладка будет видима.'
			,NULL
			,'JSON'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_val()
		RETURNS json AS
		$BODY$
			SELECT val::json AS val FROM const_contract_document_visib_expert_list LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_set_val(JSON)
		RETURNS void AS
		$BODY$
			UPDATE const_contract_document_visib_expert_list SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_set_val(JSON) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_contract_document_visib_expert_list_view AS
		SELECT
			'contract_document_visib_expert_list'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_contract_document_visib_expert_list AS t
		;
		ALTER VIEW const_contract_document_visib_expert_list_view OWNER TO expert72;
	

-- ******************* update 25/01/2019 11:27:05 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_contract_document_visib_expert_list
		(name text, descr text, val json,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_contract_document_visib_expert_list OWNER TO expert72;
		INSERT INTO const_contract_document_visib_expert_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Список экспертов, у которых доступна закладка "Документы" в контракте'
			,'Закладка "Документы" в контракте не доступна для роли "эксперт". Однако можно задать список экспертов, для которых закладка будет видима.'
			,NULL
			,'JSON'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_val()
		RETURNS json AS
		$BODY$
			SELECT val::json AS val FROM const_contract_document_visib_expert_list LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_contract_document_visib_expert_list_set_val(JSON)
		RETURNS void AS
		$BODY$
			UPDATE const_contract_document_visib_expert_list SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_contract_document_visib_expert_list_set_val(JSON) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_contract_document_visib_expert_list_view AS
		SELECT
			'contract_document_visib_expert_list'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_contract_document_visib_expert_list AS t
		;
		ALTER VIEW const_contract_document_visib_expert_list_view OWNER TO expert72;
	

-- ******************* update 25/01/2019 11:39:58 ******************

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
		FROM const_contract_document_visib_expert_list_view;
		ALTER VIEW constants_list_view OWNER TO expert72;
	
-- ******************* update 08/02/2019 14:40:02 ******************
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
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
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
		d.exp_cost_eval_validity
		
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
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
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
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
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
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 08/02/2019 14:40:27 ******************
-- VIEW: applications_dialog_lk

--DROP VIEW contracts_dialog_lk;
DROP VIEW applications_dialog_lk;

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
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
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

