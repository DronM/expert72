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


-- ******************* update 27/11/2020 12:46:57 ******************
﻿-- Function: doc_flow_out_client_ban_inf(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_ban_inf(in_application_id int);

/**
 * returns
 *	bool allow_client_out_documents разрешение на отправку исх. писем даже после запрета
 *	date work_end_date - дата окончания работ
 *	date ban_from дата закрытия, после которой нельзя отправлять
 */
CREATE OR REPLACE FUNCTION doc_flow_out_client_ban_inf(in_application_id int)
  RETURNS record AS
$$
	SELECT
		coalesce(ct.allow_client_out_documents,FALSE) AS allow_client_out_documents,
		ct.work_end_date,
		bank_day_next(
			ct.work_end_date,
			(SELECT -1 * coalesce(sv.ban_client_responses_day_cnt,const_ban_client_responses_day_cnt_val())
			FROM services AS sv
			WHERE
				sv.expertise_type = app.expertise_type
				AND sv.service_type = app.service_type 
			)
		) AS ban_from
	FROM contracts AS ct
	LEFT JOIN applications AS app ON app.id=ct.application_id
	WHERE ct.application_id=in_application_id
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_ban_inf(in_application_id int) OWNER TO expert72;


-- ******************* update 27/11/2020 12:56:49 ******************
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
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='eng_survey' THEN 'РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			ban_from
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = FALSE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 27/11/2020 13:01:08 ******************
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
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='eng_survey' THEN 'РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = FALSE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 27/11/2020 13:01:19 ******************
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
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='eng_survey' THEN 'РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = FALSE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 27/11/2020 13:30:18 ******************
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
		
		t.allow_new_file_add,
		
		t.service_type,
		
		CASE WHEN t.service_type = 'modified_documents' THEN contracts_ref(exp_maint_ct)			
		ELSE NULL
		END AS expert_maintenance_contracts_ref,
		CASE WHEN t.service_type = 'modified_documents' THEN exp_maint_ct.id
		ELSE NULL
		END AS expert_maintenance_contract_id,
		
		employees_ref(m_exp) AS main_experts_ref
		
		,t.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(t.application_id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
		
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN contracts AS exp_maint_ct ON exp_maint_ct.application_id=applications.base_application_id
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
	
	WHERE coalesce(applications.ext_contract,FALSE)=FALSE --AND t.service_type <> 'modified_documents'
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW contracts_list OWNER TO expert72;


-- ******************* update 27/11/2020 13:30:36 ******************
-- VIEW: contracts_ext_list

--DROP VIEW contracts_ext_list;

CREATE OR REPLACE VIEW contracts_ext_list AS
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
		
		t.allow_new_file_add,
		
		t.service_type,
		
		CASE WHEN t.service_type = 'modified_documents' THEN contracts_ref(exp_maint_ct)			
		ELSE NULL
		END AS expert_maintenance_contracts_ref,
		CASE WHEN t.service_type = 'modified_documents' THEN exp_maint_ct.id
		ELSE NULL
		END AS expert_maintenance_contract_id
		
		,t.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(t.application_id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN contracts AS exp_maint_ct ON exp_maint_ct.application_id=applications.base_application_id
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
	
	WHERE coalesce(applications.ext_contract,FALSE)=TRUE
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW contracts_ext_list OWNER TO expert72;


-- ******************* update 28/11/2020 10:33:44 ******************
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
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД, Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД, РИИ'
			WHEN l.expertise_type='eng_survey' THEN 'РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД, РИИ, Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ, Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = FALSE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 30/11/2020 14:39:50 ******************
-- VIEW: applications_ext_list

--DROP VIEW applications_ext_list;

CREATE OR REPLACE VIEW applications_ext_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = TRUE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_ext_list OWNER TO expert72;



-- ******************* update 30/11/2020 14:46:02 ******************
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
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД, Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД, РИИ'
			WHEN l.expertise_type='eng_survey' THEN 'РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД, РИИ, Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ, Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
		
		,contr.expert_work_end_date
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = FALSE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_list OWNER TO expert72;



-- ******************* update 30/11/2020 14:46:09 ******************
-- VIEW: applications_ext_list

--DROP VIEW applications_ext_list;

CREATE OR REPLACE VIEW applications_ext_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
		
		,contr.work_start_date
		,(SELECT
			CASE WHEN allow_client_out_documents=TRUE THEN NULL ELSE ban_from END
		FROM doc_flow_out_client_ban_inf(l.id) AS (allow_client_out_documents bool, work_end_date date,ban_from date )
		) AS ban_from
		
		,contr.expert_work_end_date
				
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
	WHERE l.service_type <> 'modified_documents' AND coalesce(l.ext_contract,FALSE) = TRUE
	ORDER BY l.user_id,l.create_dt DESC
	
	;
	
ALTER VIEW applications_ext_list OWNER TO expert72;



-- ******************* update 22/12/2020 09:26:03 ******************

		ALTER TABLE public.contracts ADD COLUMN disable_client_out_documents bool
			DEFAULT FALSE;



-- ******************* update 22/12/2020 09:28:32 ******************
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
		app.documents AS documents,
		/*
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(app.create_dt::date) l
			WHERE
				(app.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=app.construction_type_id AND
				l.document_type IN (
					CASE WHEN app.expertise_type='pd' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='pd' OR exp_maint_base.expertise_type='pd_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'pd'::document_types
						ELSE NULL
					END,
					CASE WHEN app.expertise_type='eng_survey' OR app.expertise_type='pd_eng_survey' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='eng_survey' OR exp_maint_base.expertise_type='pd_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'eng_survey'::document_types
						ELSE NULL
					END,
					CASE WHEN app.cost_eval_validity OR app.exp_cost_eval_validity OR app.expertise_type='cost_eval_validity' OR app.expertise_type='cost_eval_validity_pd' OR app.expertise_type='cost_eval_validity_eng_survey' OR app.expertise_type='cost_eval_validity_pd_eng_survey'
						OR exp_maint_base.expertise_type='cost_eval_validity' OR exp_maint_base.expertise_type='cost_eval_validity_pd' OR exp_maint_base.expertise_type='cost_eval_validity_eng_survey' OR exp_maint_base.expertise_type='cost_eval_validity_pd_eng_survey'
						THEN 'cost_eval_validity'::document_types
						ELSE NULL
					END,
					CASE WHEN app.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN app.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		*/		
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
		
		app.customer_auth_letter,
		
		t.service_type,

		CASE
			WHEN app.service_type='modified_documents' THEN
				b_app.expert_maintenance_service_type
			WHEN  app.service_type='expert_maintenance' THEN
				app.expert_maintenance_service_type
			ELSE NULL
		END AS expert_maintenance_service_type,

		CASE
			WHEN app.service_type='modified_documents' THEN
				b_app.expert_maintenance_expertise_type
			WHEN  app.service_type='expert_maintenance' THEN
				app.expert_maintenance_expertise_type
			ELSE NULL
		END AS expert_maintenance_expertise_type,				
		
		CASE WHEN t.service_type='expert_maintenance' THEN
			contracts_ref(exp_main_ct)
		ELSE NULL
		END AS expert_maintenance_base_contracts_ref,
		
		/** Заполняется у контрактов по экспертному сопровождению
		 * вытаскиваем все письма-заключения у всех измененных документаций
		 * связанных с этим контрактом
		 */
		CASE WHEN app.service_type='expert_maintenance' THEN
			(SELECT
				json_agg(
					json_build_object(
						'client_viewed',doc_flow_in_client.viewed,
						'contract',json_build_object(
							'reg_number',mod_doc_out_contr.reg_number,
							'expertise_result',mod_doc_out_contr.expertise_result,
							'expertise_result_date',mod_doc_out_contr.expertise_result_date,
							'expertise_reject_types_ref',expertise_reject_types_ref((SELECT expertise_reject_types FROM expertise_reject_types WHERE id=mod_doc_out_contr.expertise_reject_type_id)),
							'result_sign_expert_list',mod_doc_out_contr.result_sign_expert_list
						),
						'file',json_build_object(
							'file_id',att.file_id,
							'file_name',att.file_name,
							'file_size',att.file_size,
							'file_signed',att.file_signed,
							'file_uploaded','true',
							'file_path',att.file_path,
							'date_time',f_ver.date_time,
							'signatures',
							(WITH sign AS
							(SELECT
								json_agg(files_t.signatures) AS signatures
							FROM
								(SELECT
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
								WHERE f_sig.file_id=f_ver.file_id
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
							'file_signed_by_client',(SELECT t1.file_signed_by_client FROM application_document_files t1 WHERE t1.file_id=att.file_id)
						)
					)
				)
			
			FROM doc_flow_out AS mod_doc_out
			LEFT JOIN doc_flow_attachments AS att ON
				att.file_path='Заключение' AND att.doc_type='doc_flow_out' AND att.doc_id=mod_doc_out.id
			LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
			LEFT JOIN contracts AS mod_doc_out_contr ON mod_doc_out_contr.id=mod_doc_out.to_contract_id
			LEFT JOIN doc_flow_in_client ON doc_flow_in_client.doc_flow_out_id=mod_doc_out.id				
			WHERE mod_doc_out.to_application_id IN
				(SELECT
					mod_app.id
				FROM applications AS mod_app
				WHERE mod_app.base_application_id = t.application_id 
				)
				AND mod_doc_out.doc_flow_type_id = (pdfn_doc_flow_types_contr_close()->'keys'->>'id')::int
			)
		ELSE NULL
		END AS results_on_modified_documents_list,
		
		app.ext_contract,
		
		t.disable_client_out_documents
		
	FROM contracts t
	LEFT JOIN applications AS app ON app.id=t.application_id
	LEFT JOIN contracts AS exp_main_ct ON exp_main_ct.application_id=app.expert_maintenance_base_application_id
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
	
	LEFT JOIN applications b_app ON b_app.id=app.base_application_id
	--LEFT JOIN applications exp_maint_base ON exp_maint_base.id=exp_maint.expert_maintenance_base_application_id

	--LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;



-- ******************* update 22/12/2020 09:44:23 ******************

	-- ********** constant value table  disabled_client_out_documents_error *************
	CREATE TABLE IF NOT EXISTS const_disabled_client_out_documents_error
	(name text, descr text, val text,
		val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
	ALTER TABLE const_disabled_client_out_documents_error OWNER TO expert72;
	INSERT INTO const_disabled_client_out_documents_error (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Текст сообщения об ошибке при запрете отправки ответов из контракта'
		,'Текст сообщения об ошибке при невозможности отправки ответов на замечания. Ставится в контракте'
		,
			'Отправка ответов на замечания запрещена.'
		,'Text'
		,'Text'
		,NULL
		,NULL
		,NULL
	);
		--constant get value
	CREATE OR REPLACE FUNCTION const_disabled_client_out_documents_error_val()
	RETURNS text AS
	$BODY$
		SELECT val::text AS val FROM const_disabled_client_out_documents_error LIMIT 1;
	$BODY$
	LANGUAGE sql STABLE COST 100;
	ALTER FUNCTION const_disabled_client_out_documents_error_val() OWNER TO expert72;
	--constant set value
	CREATE OR REPLACE FUNCTION const_disabled_client_out_documents_error_set_val(Text)
	RETURNS void AS
	$BODY$
		UPDATE const_disabled_client_out_documents_error SET val=$1;
	$BODY$
	LANGUAGE sql VOLATILE COST 100;
	ALTER FUNCTION const_disabled_client_out_documents_error_set_val(Text) OWNER TO expert72;
	--edit view: all keys and descr
	CREATE OR REPLACE VIEW const_disabled_client_out_documents_error_view AS
	SELECT
		'disabled_client_out_documents_error'::text AS id
		,t.name
		,t.descr
	,
	t.val::text AS val
	,t.val_type::text AS val_type
	,t.ctrl_class::text
	,t.ctrl_options::json
	,t.view_class::text
	,t.view_options::json
	FROM const_disabled_client_out_documents_error AS t
	;
	ALTER VIEW const_disabled_client_out_documents_error_view OWNER TO expert72;
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
	FROM const_off_work_app_send_not_allowed_view
	UNION ALL
	SELECT *
	FROM const_off_work_app_send_not_allowed_error_view
	UNION ALL
	SELECT *
	FROM const_disabled_client_out_documents_error_view;
	ALTER VIEW constants_list_view OWNER TO expert72;