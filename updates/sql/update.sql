-- ******************* update 23/11/2020 15:08:08 ******************

	-- ********** constant value table  off_work_app_send_not_allowed *************
	CREATE TABLE IF NOT EXISTS const_off_work_app_send_not_allowed
	(name text, descr text, val bool,
		val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
	ALTER TABLE const_off_work_app_send_not_allowed OWNER TO expert72;
	INSERT INTO const_off_work_app_send_not_allowed (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Запретить отправлять заявления на проверку в нерабочее время'
		,'Значение определяет возможность отправлять заявления на проверку в нерабочее время.'
		,FALSE
		,'Bool'
		,NULL
		,NULL
		,NULL
		,NULL
	);
		--constant get value
	CREATE OR REPLACE FUNCTION const_off_work_app_send_not_allowed_val()
	RETURNS bool AS
	$BODY$
		SELECT val::bool AS val FROM const_off_work_app_send_not_allowed LIMIT 1;
	$BODY$
	LANGUAGE sql STABLE COST 100;
	ALTER FUNCTION const_off_work_app_send_not_allowed_val() OWNER TO expert72;
	--constant set value
	CREATE OR REPLACE FUNCTION const_off_work_app_send_not_allowed_set_val(Bool)
	RETURNS void AS
	$BODY$
		UPDATE const_off_work_app_send_not_allowed SET val=$1;
	$BODY$
	LANGUAGE sql VOLATILE COST 100;
	ALTER FUNCTION const_off_work_app_send_not_allowed_set_val(Bool) OWNER TO expert72;
	--edit view: all keys and descr
	CREATE OR REPLACE VIEW const_off_work_app_send_not_allowed_view AS
	SELECT
		'off_work_app_send_not_allowed'::text AS id
		,t.name
		,t.descr
	,
	t.val::text AS val
	,t.val_type::text AS val_type
	,t.ctrl_class::text
	,t.ctrl_options::json
	,t.view_class::text
	,t.view_options::json
	FROM const_off_work_app_send_not_allowed AS t
	;
	ALTER VIEW const_off_work_app_send_not_allowed_view OWNER TO expert72;
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
	FROM const_ban_client_responses_day_cnt_view
	UNION ALL
	SELECT *
	FROM const_ext_contract_doc_pref_view
	UNION ALL
	SELECT *
	FROM const_off_work_app_send_not_allowed_view;
	ALTER VIEW constants_list_view OWNER TO expert72;
	

-- ******************* update 23/11/2020 17:19:45 ******************
﻿-- Function: applications_work_h(in_date_time timestamp)

-- DROP FUNCTION applications_work_h(in_date_time timestamp);

CREATE OR REPLACE FUNCTION applications_work_h(in_date_time timestamp)
  RETURNS bool AS
$$
	WITH
	in_t AS (SELECT in_date_time AS v)
	SELECT
		coalesce(
			(SELECT v FROM in_t)::time BETWEEN (sub.hours->>'from')::time AND (sub.hours->>'to')::time
		,FALSE)  AS work_h
	FROM (
	SELECT jsonb_array_elements(offices.work_hours) AS hours
	FROM offices WHERE id=1
		) AS sub
	LEFT JOIN holidays AS h ON h.date=(SELECT v FROM in_t)::date
	WHERE (sub.hours->>'checked')::bool
	AND (sub.hours->>'dow')::int=(SELECT EXTRACT(DOW FROM (SELECT v FROM in_t)))
	AND h.date is NULL
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_work_h(in_date_time timestamp) OWNER TO expert72;


-- ******************* update 23/11/2020 17:22:37 ******************
﻿-- Function: applications_work_h(in_date_time timestampTZ)

 DROP FUNCTION applications_work_h(in_date_time timestamp);

CREATE OR REPLACE FUNCTION applications_work_h(in_date_time timestampTZ)
  RETURNS bool AS
$$
	WITH
	in_t AS (SELECT in_date_time AS v)
	SELECT
		coalesce(
			(SELECT v FROM in_t)::time BETWEEN (sub.hours->>'from')::time AND (sub.hours->>'to')::time
		,FALSE)  AS work_h
	FROM (
	SELECT jsonb_array_elements(offices.work_hours) AS hours
	FROM offices WHERE id=1
		) AS sub
	LEFT JOIN holidays AS h ON h.date=(SELECT v FROM in_t)::date
	WHERE (sub.hours->>'checked')::bool
	AND (sub.hours->>'dow')::int=(SELECT EXTRACT(DOW FROM (SELECT v FROM in_t)))
	AND h.date is NULL
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_work_h(in_date_time timestampTZ) OWNER TO expert72;


-- ******************* update 23/11/2020 17:31:39 ******************
﻿-- Function: applications_work_h(in_date_time timestampTZ)

 DROP FUNCTION applications_work_h(in_date_time timestampTZ);
/*
CREATE OR REPLACE FUNCTION applications_work_h(in_date_time timestampTZ)
  RETURNS bool AS
$$
	WITH
	in_t AS (SELECT in_date_time AS v)
	SELECT
		coalesce(
			(SELECT v FROM in_t)::time BETWEEN (sub.hours->>'from')::time AND (sub.hours->>'to')::time
		,FALSE)  AS work_h
	FROM (
	SELECT jsonb_array_elements(offices.work_hours) AS hours
	FROM offices WHERE id=1
		) AS sub
	LEFT JOIN holidays AS h ON h.date=(SELECT v FROM in_t)::date
	WHERE (sub.hours->>'checked')::bool
	AND (sub.hours->>'dow')::int=(SELECT EXTRACT(DOW FROM (SELECT v FROM in_t)))
	AND h.date is NULL
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_work_h(in_date_time timestampTZ) OWNER TO expert72;

*/


-- ******************* update 23/11/2020 17:32:10 ******************
﻿-- Function: applications_work_h(in_date_time timestampTZ,in_office_id int)

-- DROP FUNCTION applications_work_h(in_date_time timestampTZ,in_office_id int);

CREATE OR REPLACE FUNCTION applications_work_h(in_date_time timestampTZ,in_office_id int)
  RETURNS bool AS
$$
	WITH
	in_t AS (SELECT in_date_time AS v)
	SELECT
		coalesce(
			(SELECT v FROM in_t)::time BETWEEN (sub.hours->>'from')::time AND (sub.hours->>'to')::time
		,FALSE)  AS work_h
	FROM (
	SELECT jsonb_array_elements(offices.work_hours) AS hours
	FROM offices WHERE id=in_office_id
		) AS sub
	LEFT JOIN holidays AS h ON h.date=(SELECT v FROM in_t)::date
	WHERE (sub.hours->>'checked')::bool
	AND (sub.hours->>'dow')::int=(SELECT EXTRACT(DOW FROM (SELECT v FROM in_t)))
	AND h.date is NULL
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_work_h(in_date_time timestampTZ,in_office_id int) OWNER TO expert72;




-- ******************* update 23/11/2020 17:45:12 ******************

UPDATE const_off_work_app_send_not_allowed SET ctrl_class='EditCheckBox'


-- ******************* update 23/11/2020 17:47:14 ******************

UPDATE const_off_work_app_send_not_allowed SET val='true'


-- ******************* update 23/11/2020 17:54:29 ******************

UPDATE const_off_work_app_send_not_allowed SET val='false'


-- ******************* update 23/11/2020 17:54:53 ******************

UPDATE const_off_work_app_send_not_allowed SET val='true'