
		ALTER TABLE contracts ADD COLUMN allow_client_out_documents bool
			DEFAULT FALSE;


--contracts_dialog
--applications_dialog
--doc_flow_in_dialog



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
		ALTER VIEW constants_list_view OWNER TO ;
	
	
	
--client_payments_process
--doc_flow_out_client_process()	


ALTER TABLE applications ADD COLUMN customer_auth_letter text,ADD COLUMN customer_auth_letter_file jsonb;



