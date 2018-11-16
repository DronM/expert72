CREATE USER expert72 WITH PASSWORD '159753';
CREATE DATABASE expert72;
GRANT ALL PRIVILEGES ON DATABASE expert72 TO expert72;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO expert72;

CREATE USER expert72_lk WITH PASSWORD '159753';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO expert72_lk;
GRANT ALL ON application_document_files TO expert72_lk;
GRANT ALL ON applications TO expert72_lk;
GRANT USAGE, SELECT ON SEQUENCE applications_id_seq TO expert72_lk;

GRANT ALL ON doc_flow_in_client_reg_numbers TO expert72_lk;
GRANT ALL ON doc_flow_out_client TO expert72_lk;
GRANT USAGE, SELECT ON SEQUENCE doc_flow_out_client_id_seq TO expert72_lk;

GRANT ALL ON doc_flow_out_client_document_files TO expert72_lk;

GRANT ALL ON doc_flow_out_client_reg_numbers TO expert72_lk;
GRANT ALL ON file_signatures_lk TO expert72_lk;
GRANT USAGE, SELECT ON SEQUENCE file_signatures_lk_id_seq TO expert72_lk;

GRANT ALL ON file_verifications_lk TO expert72_lk;
GRANT ALL ON user_certificates_lk TO expert72_lk;
GRANT USAGE, SELECT ON SEQUENCE user_certificates_lk_id_seq TO expert72_lk;

GRANT ALL ON logins TO expert72_lk;
GRANT ALL ON users TO expert72_lk;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO expert72_lk;

GRANT USAGE, SELECT ON SEQUENCE logins_id_seq TO expert72_lk;

GRANT ALL ON sessions TO expert72_lk;
GRANT ALL ON morpher TO expert72_lk;
GRANT ALL ON application_processes TO expert72_lk;
SELECT grant_all_views('public', 'expert72_lk')

GRANT ALL ON TABLE public.application_processes_lk TO expert72_lk;

GRANT USAGE, SELECT ON SEQUENCE mail_for_sending_lk_id_seq TO expert72_lk;

ALTER SEQUENCE logins_id_seq RESTART WITH 1000000000;
ALTER SEQUENCE users_id_seq RESTART WITH 1000000000;
ALTER SEQUENCE file_signatures_lk_id_seq RESTART WITH 1000000000;
ALTER SEQUENCE mail_for_sending_lk_id_seq RESTART WITH 1000000000;



-Восстанавливает в другую базу
-s no data
pg_dump -U expert72 -vs expert72 > expert72.dump
psql -U expert72 -d expert72 -f expert72.dump

ПРОСТОЙ DUMP!!!
sudo service postgresql stop
sudo service postgresql start
psql -U postgres
DROP database expert72;
CREATE DATABASE expert72;
GRANT ALL ON SCHEMA public TO expert72;
GRANT ALL ON DATABASE expert72 TO expert72;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO expert72;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO expert72;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO expert72;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO expert72;

--=================================================================================
--Перенос с главного сервере на ЛК
CREATE PUBLICATION sync_office_to_lk FOR TABLE
	application_corrections,
	application_doc_folders,
	--application_processes,
	banks,
	build_types,
	client_payments,
	clients,
	const_app_recipient_department,
	const_application_check_days,
	const_cades_hash_algorithm,
	const_cades_include_certificate,
	const_cades_signature_type,
	const_cades_verify_after_signing,
	const_client_download_file_max_size,
	const_client_download_file_types,
	const_client_download_max_file_size,
	const_client_lk,
	const_debug,
	const_doc_per_page_count,
	const_employee_download_file_max_size,
	const_employee_download_file_types,
	const_grid_refresh_interval,
	const_outmail_data,
	const_reminder_refresh_interval,
	const_reminder_show_days,
	const_session_live_time,
	construction_types,
	contacts,
	departments,
	doc_flow_approvement_templates,
	doc_flow_approvements,
	doc_flow_attachments,
	doc_flow_examinations,
	doc_flow_importance_types,
	doc_flow_in,
	doc_flow_in_client,
	doc_flow_in_processes,
	doc_flow_inside,
	doc_flow_inside_processes,
	doc_flow_out,
	doc_flow_out_corrections,
	doc_flow_out_processes,
	doc_flow_registrations,
	doc_flow_tasks,
	doc_flow_types,
	document_templates,
	email_templates,
	employees,
	expert_sections,
	expert_works,
	expertise_reject_types,
	file_signatures,
	file_verifications,
	fund_sources,
	holidays,
	logins,--************* Нужна установка sequence на ЛК
	mail_for_sending,
	mail_for_sending_attachments,
	mail_types,
	main_menus,
	morpher,--************** Полномтью с главного копировать, ключ src
	office_day_schedules,
	offices,
	person_id_papers,
	posts,
	reminders,
	report_template_files,
	report_templates,
	services,
	--sessions, **************** Вообще никуда не копируем, на каждолм сервере свой
	short_message_recipient_current_states,
	short_message_recipient_states,
	short_messages,
	time_zone_locales,
	user_certificates,
	user_email_confirmations,--**************** Полномтью копируется с главного, ключ key уникален
	users,--*************** Нужна установка sequence на ЛК
	variant_storages,--************** Полномтью копируется с главного, ключ юзер+название варианта
	views
	;

--Перенос с ЛК на Главный
CREATE PUBLICATION sync_lk_to_office FOR TABLE
	application_processes_lk,
	application_document_files,	
	applications,
	doc_flow_in_client_reg_numbers,
	doc_flow_out_client,
	doc_flow_out_client_document_files,
	doc_flow_out_client_reg_numbers,
	file_signatures_lk,
	file_verifications_lk,
	user_certificates_lk,
	logins,--************* Нужна установка sequence на ЛК
	users_lk,
	mail_for_sending_lk,
	mail_for_sending_attachments_lk,
	user_email_confirmations_lk
	--sessions **************** Вообще никуда не копируем, на каждолм сервере свой
	;	

CREATE SUBSCRIPTION sync_office_from_lk
         CONNECTION 'host=expertiza72.ru port=5432 user=expert72 dbname=expert72_lk'
        PUBLICATION sync_lk_to_office
        WITH (enabled = false);

CREATE SUBSCRIPTION sync_office_from_lk
CONNECTION 'host=localhost port=5432 password=159753 user=repl dbname=expert72'
PUBLICATION sync_office_to_lk;

CREATE SUBSCRIPTION sync_lk_from_office
         CONNECTION 'host=92.255.164.139 port=5432 user=expert72 dbname=expert72'
        PUBLICATION sync_office_to_lk
        WITH (enabled = false);
	
