ALTER TABLE application_corrections ENABLE ALWAYS TRIGGER application_corrections_after_trigger;
ALTER TABLE application_document_files ENABLE ALWAYS TRIGGER application_document_files_before_trigger;
ALTER TABLE application_processes ENABLE ALWAYS TRIGGER application_processes_after_trigger;
ALTER TABLE applications ENABLE ALWAYS TRIGGER applications_before_trigger;
ALTER TABLE client_payments ENABLE ALWAYS TRIGGER client_payments_after_trigger;
ALTER TABLE contacts ENABLE ALWAYS TRIGGER contacts_before_trigger;
ALTER TABLE contracts ENABLE ALWAYS TRIGGER contracts_before_trigger;
ALTER TABLE doc_flow_approvement_templates ENABLE ALWAYS TRIGGER doc_flow_approvement_templates_before_trigger;
ALTER TABLE doc_flow_approvements ENABLE ALWAYS TRIGGER doc_flow_approvements_after_trigger;
ALTER TABLE doc_flow_approvements ENABLE ALWAYS TRIGGER doc_flow_approvements_before_trigger;
ALTER TABLE doc_flow_attachments ENABLE ALWAYS TRIGGER doc_flow_attachments_after_trigger;
ALTER TABLE doc_flow_attachments ENABLE ALWAYS TRIGGER doc_flow_attachments_before_trigger;
ALTER TABLE doc_flow_examinations ENABLE ALWAYS TRIGGER doc_flow_examinations_after_trigger;
ALTER TABLE doc_flow_examinations ENABLE ALWAYS TRIGGER doc_flow_examinations_before_trigger;
ALTER TABLE doc_flow_in ENABLE ALWAYS TRIGGER doc_flow_in_before_trigger;
ALTER TABLE doc_flow_in_client ENABLE ALWAYS TRIGGER doc_flow_in_client_before_trigger;
ALTER TABLE doc_flow_in_client ENABLE ALWAYS TRIGGER doc_flow_in_client_after_trigger;
ALTER TABLE doc_flow_out ENABLE ALWAYS TRIGGER doc_flow_out_before_trigger;
ALTER TABLE doc_flow_out_client ENABLE ALWAYS TRIGGER doc_flow_out_client_after_trigger;
ALTER TABLE doc_flow_out_corrections ENABLE ALWAYS TRIGGER doc_flow_out_registrations_after_trigger;
ALTER TABLE doc_flow_registrations ENABLE ALWAYS TRIGGER doc_flow_registrations_after_trigger;
ALTER TABLE doc_flow_registrations ENABLE ALWAYS TRIGGER doc_flow_registrations_before_trigger;
ALTER TABLE file_signatures_lk ENABLE ALWAYS TRIGGER file_signatures_lk_after_trigger;
ALTER TABLE file_verifications_lk ENABLE ALWAYS TRIGGER file_verifications_lk_after_trigger;
ALTER TABLE file_verifications_lk ENABLE ALWAYS TRIGGER file_verifications_lk_before_trigger;
ALTER TABLE user_certificates_lk ENABLE ALWAYS TRIGGER user_certificates_lk_after_trigger;
ALTER TABLE users ENABLE ALWAYS TRIGGER users_after_trigger;
ALTER TABLE application_processes_lk ENABLE ALWAYS TRIGGER application_processes_lk_after_trigger;


#***********************************************************
1) Создать пользователя для репликации
CREATE ROLE repl WITH REPLICATION LOGIN PASSWORD '159753';
GRANT ALL PRIVILEGES ON DATABASE expert72 TO repl;
Подключаемся к базе
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO repl;

--Перенос с главного сервере на ЛК
CREATE PUBLICATION sync_office_to_lk FOR TABLE
	application_corrections,
	application_doc_folders,
	application_processes,
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
	--doc_flow_in_client, ЭТО делается на ЛК
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
	--logins,--************* Нужна установка sequence на ЛК
	--mail_for_sending,
	--mail_for_sending_attachments,
	mail_types,
	main_menus,
	--morpher,--************** Везде своя копия
	office_day_schedules,
	offices,
	person_id_papers,
	posts,
	reminders,
	report_template_files,
	report_templates,
	services,
	--sessions, **************** Вообще никуда не копируем, на каждом сервере своя таблица
	short_message_recipient_current_states,
	short_message_recipient_states,
	short_messages,
	time_zone_locales,
	user_certificates,
	--user_email_confirmations,**************** Полномтью копируется с копируется с ЛК
	--users, *************** Нужна установка sequence на ЛК, копируется с ЛК
	--variant_storages,************** копируется с ЛК
	views
	;


3) Создать пользователя expert72_lk
psql -U postgres -p 5432 -d expert72
CREATE ROLE expert72_lk WITH REPLICATION LOGIN PASSWORD '159753';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO expert72_lk;
#Конкретные таблицы
GRANT ALL ON application_document_files TO expert72_lk;
GRANT ALL ON applications TO expert72_lk;
GRANT USAGE, SELECT ON SEQUENCE applications_id_seq TO expert72_lk;

GRANT ALL ON doc_flow_in_client TO expert72_lk;
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
GRANT ALL ON application_processes_lk TO expert72_lk;
SELECT grant_all_views('public', 'expert72_lk')


4) Создать копию базы данных
pg_dump -U expert72 -v expert72 > expert72.dump


--5) Запустить сервер ЛК, создать базу
su postgres
/usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/slave -o "-p 5435" -l /var/lib/postgresql/10/slave/log start
psql -U postgres -p 5435
CREATE DATABASE expert72_lk;
GRANT ALL PRIVILEGES ON DATABASE expert72_lk TO expert72;
\q
psql -U postgres -p 5435 -d expert72_lk
GRANT SELECT ON ALL TABLES IN SCHEMA public TO expert72_lk;

6) Загрузить данные
psql -U expert72 -p 5435 -d expert72_lk -f expert72.dump

7) !!! Изменить значение константы на ЛК!!!
psql -U expert72 -p 5435 -d expert72_lk
update const_client_lk set val=TRUE;
update const_debug SET val=FALSE;

8) !!! Переставить сиквенсы на ЛК!!! 
psql -U expert72 -p 5435 -d expert72_lk
ALTER SEQUENCE logins_id_seq RESTART WITH 1000000000;
ALTER SEQUENCE users_id_seq RESTART WITH 1000000000;
ALTER SEQUENCE file_signatures_lk_id_seq RESTART WITH 1000000000;

Скопировать таблицы
COPY user_certificates TO '/tmp/user_certificates_copy.txt';
COPY user_certificates_lk FROM '/tmp/user_certificates_copy.txt';
COPY file_signatures TO '/tmp/file_signatures_copy.txt';
COPY file_signatures_lk FROM '/tmp/file_signatures_copy.txt';
COPY file_verifications TO '/tmp/file_verifications_copy.txt';
COPY file_verifications_lk FROM '/tmp/file_verifications_copy.txt';

7) Создать публикацию
psql -U postgres -p 5435 -d expert72_lk
--Перенос с ЛК на Главный
CREATE PUBLICATION sync_lk_to_office FOR TABLE
	application_processes_lk,
	application_document_files,	
	applications,
	doc_flow_in_client,
	doc_flow_in_client_reg_numbers,
	doc_flow_out_client,
	doc_flow_out_client_document_files,
	doc_flow_out_client_reg_numbers,
	file_signatures_lk,
	file_verifications_lk,
	user_certificates_lk,
	logins,--************* Нужна установка sequence на ЛК	
	--sessions **************** Вообще никуда не копируем, на каждом сервере свой
	;	


7) Создать SUBSCRIPTIONs
На LK
psql -U postgres -p 5435 -d expert72_lk
CREATE SUBSCRIPTION sync_lk_from_office
         CONNECTION 'host=localhost port=5432 password=159753 user=repl dbname=expert72'
        PUBLICATION sync_office_to_lk
        WITH (copy_data=FALSE);

CREATE SUBSCRIPTION sync_lk_from_office
         CONNECTION 'host=46.173.214.98 port=5432 password=Gvr72sS@expert72_office user=expert72_office dbname=expert72_test'
        PUBLICATION sync_office_to_lk
        WITH (copy_data=FALSE);


На основном сервере под postgres
psql -U postgres -p 5432 -d expert72
CREATE SUBSCRIPTION sync_office_from_lk
         CONNECTION 'host=localhost port=5435 password=159753 user=repl dbname=expert72_lk'
        PUBLICATION sync_lk_to_office
        WITH (copy_data=FALSE);

CREATE SUBSCRIPTION sync_office_from_lk
         CONNECTION 'host=178.46.157.185 port=5435 password=159753 user=rep dbname=expert72_office'
        PUBLICATION sync_lk_to_office
        WITH (copy_data=FALSE);


8) Создать пользователя для работы из офиса
CREATE ROLE expert72_office WITH REPLICATION LOGIN PASSWORD '159753';
GRANT ALL PRIVILEGES ON DATABASE expert72 TO expert72_office;
Подключаемся к базе
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO expert72_office;
REVOKE INSERT,UPDATE,DELETE ON application_processes_lk FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON application_document_files FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON applications FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON doc_flow_in_client FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON doc_flow_in_client_reg_numbers FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON doc_flow_out_client FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON doc_flow_out_client_document_files FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON doc_flow_out_client_reg_numbers FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON file_signatures_lk FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON file_verifications_lk FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON user_certificates_lk FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON user_lk FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON mail_for_sending_attachments_lk FROM expert72_office;
REVOKE INSERT,UPDATE,DELETE ON user_email_confirmations_lk FROM expert72_office;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA public TO expert72_office;

