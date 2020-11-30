
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


