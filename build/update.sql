


-- ******************* update 05/10/2017 13:23:46 ******************
CREATE TYPE locales AS ENUM (
			
				'ru'			
						
			);
			ALTER TYPE locales OWNER TO user_name;
		
			CREATE TYPE role_types AS ENUM (
			
				'admin'			
						
			);
			ALTER TYPE role_types OWNER TO user_name;
		
			CREATE TYPE role_types AS ENUM (
			
				'client'			
						
			);
			ALTER TYPE role_types OWNER TO user_name;
		
		CREATE TABLE views
		(id serial,c text,f text,t text,section text NOT NULL,descr text NOT NULL,CONSTRAINT views_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS views_section_descr_idx;
	CREATE UNIQUE INDEX views_section_descr_idx
	ON views
	(section,descr);

		ALTER TABLE views OWNER TO user_name;
	
		CREATE TABLE main_menus
		(id serial,role_id role_types NOT NULL,user_id int REFERENCES users(id),content text NOT NULL,CONSTRAINT main_menus_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS main_menus_role_user_idx;
	CREATE UNIQUE INDEX main_menus_role_user_idx
	ON main_menus
	(role_id,user_id);

		ALTER TABLE main_menus OWNER TO user_name;
	
		CREATE TABLE banks
		(bik  varchar(9),codegr  varchar(9),name  varchar(50),korshet  varchar(20),adres  varchar(70),gor  varchar(31),tgroup bool,CONSTRAINT banks_pkey PRIMARY KEY (bik));
		
	DROP INDEX IF EXISTS banks_codegr_idx;
	CREATE INDEX banks_codegr_idx
	ON banks
	(codegr);

		ALTER TABLE banks OWNER TO user_name;
	
		CREATE TABLE variant_storages
		(user_id int REFERENCES users(id),storage_name text,variant_name text,default_variant bool,filter_data text,col_visib_data text,col_order_data text,CONSTRAINT variant_storages_pkey PRIMARY KEY (user_id,storage_name,variant_name));
		
		ALTER TABLE variant_storages OWNER TO user_name;
	
		CREATE TABLE time_zone_locales
		(id serial,descr  varchar(100) NOT NULL,name  varchar(50) NOT NULL,hour_dif int NOT NULL,CONSTRAINT time_zone_locales_pkey PRIMARY KEY (id));
		
		ALTER TABLE time_zone_locales OWNER TO user_name;
	
		CREATE TABLE users
		(id serial,name  varchar(50) NOT NULL,role_id role_types NOT NULL,pwd  varchar(32),phone_cel  varchar(10),time_zone_locale_id int NOT NULL REFERENCES time_zone_locales(id),email  varchar(50),locale_id locales
			DEFAULT ''ru''
		,CONSTRAINT users_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS users_name_idx;
	CREATE UNIQUE INDEX users_name_idx
	ON users
	(lower(name));

	DROP INDEX IF EXISTS users_email_idx;
	CREATE UNIQUE INDEX users_email_idx
	ON users
	(lower(email));

		ALTER TABLE users OWNER TO user_name;
	
		CREATE TABLE mail_for_sending
		(id serial,date_time timestampTZ
			DEFAULT current_timestamp,from_addr  varchar(50),from_name  varchar(255),to_addr  varchar(50),to_name  varchar(255),reply_addr  varchar(50),reply_name  varchar(255),body text,sender_addr  varchar(50),subject  varchar(255),sent bool
			DEFAULT false,sent_date_time timestampTZ,email_type email_types,CONSTRAINT mail_for_sending_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS mail_for_sending_date_time_index;
	CREATE INDEX mail_for_sending_date_time_index
	ON mail_for_sending
	(date_time);

	DROP INDEX IF EXISTS mail_for_sending_sent_index;
	CREATE INDEX mail_for_sending_sent_index
	ON mail_for_sending
	(sent);

		ALTER TABLE mail_for_sending OWNER TO user_name;
	
		CREATE TABLE mail_for_sending_attachments
		(id serial,mail_for_sending_id int REFERENCES mail_for_sending(id),file_name  varchar(255),CONSTRAINT mail_for_sending_attachments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS mail_for_sending_attachments_id_index;
	CREATE INDEX mail_for_sending_attachments_id_index
	ON mail_for_sending_attachments
	(mail_for_sending_id);

		ALTER TABLE mail_for_sending_attachments OWNER TO user_name;
	
			
				
			
			
			
			
			
		
			
				
			
			
			
			
									
			
			
									
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
			
				
						
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
		--constant value table
		CREATE TABLE IF NOT EXISTS const_doc_per_page_count
		(name text, descr text, val int,
			val_type text);
		ALTER TABLE const_doc_per_page_count OWNER TO user_name;
		INSERT INTO const_doc_per_page_count (name,descr,val,val_type) VALUES (
			'Количество документов на странице',
			'Количество документов на странице в журнале документов',
			60,
			'Int'
		);
	
		--constant get value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_doc_per_page_count LIMIT 1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_val() OWNER TO user_name;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_doc_per_page_count SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_set_val(Int) OWNER TO user_name;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_doc_per_page_count_view AS
		SELECT t.name,t.descr
		,t.val::text AS val_descr
		,t.val_type::text AS val_type
		FROM const_doc_per_page_count AS t
		
		;
		ALTER VIEW const_doc_per_page_count_view OWNER TO user_name;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_grid_refresh_interval
		(name text, descr text, val int,
			val_type text);
		ALTER TABLE const_grid_refresh_interval OWNER TO user_name;
		INSERT INTO const_grid_refresh_interval (name,descr,val,val_type) VALUES (
			'Период обновления таблиц',
			'Период обновления таблиц в секундах',
			15,
			'Int'
		);
	
		--constant get value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_grid_refresh_interval LIMIT 1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_val() OWNER TO user_name;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_grid_refresh_interval SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_set_val(Int) OWNER TO user_name;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_grid_refresh_interval_view AS
		SELECT t.name,t.descr
		,t.val::text AS val_descr
		,t.val_type::text AS val_type
		FROM const_grid_refresh_interval AS t
		
		;
		ALTER VIEW const_grid_refresh_interval_view OWNER TO user_name;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_session_live_time
		(name text, descr text, val interval,
			val_type text);
		ALTER TABLE const_session_live_time OWNER TO user_name;
		INSERT INTO const_session_live_time (name,descr,val,val_type) VALUES (
			'Время жизни сессии',
			'Время, в течении которого сессия не будет удаляться на сервере',
			
				'48:00'
				,
			'Interval'
		);
	
		--constant get value
		CREATE OR REPLACE FUNCTION const_session_live_time_val()
		RETURNS interval AS
		$BODY$
			SELECT val::interval AS val FROM const_session_live_time LIMIT 1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_val() OWNER TO user_name;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_session_live_time_set_val(Interval)
		RETURNS void AS
		$BODY$
			UPDATE const_session_live_time SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_set_val(Interval) OWNER TO user_name;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_session_live_time_view AS
		SELECT t.name,t.descr
		,t.val::text AS val_descr
		,t.val_type::text AS val_type
		FROM const_session_live_time AS t
		
		;
		ALTER VIEW const_session_live_time_view OWNER TO user_name;
	
		CREATE OR REPLACE VIEW constants_list_view AS
		
		SELECT 'doc_per_page_count' AS id,name,descr,val_descr,val_type FROM const_doc_per_page_count_view
		UNION ALL
		
		SELECT 'grid_refresh_interval' AS id,name,descr,val_descr,val_type FROM const_grid_refresh_interval_view
		UNION ALL
		
		SELECT 'session_live_time' AS id,name,descr,val_descr,val_type FROM const_session_live_time_view;
		ALTER VIEW constants_list_view OWNER TO ;
	
	CREATE TABLE views (
		id int NOT NULL,
		c text,
		f text,
		t text,
		section text NOT NULL,
		descr text NOT NULL,
		limited bool,
	CONSTRAINT views_pkey PRIMARY KEY (id)
	);
	ALTER VIEW views OWNER TO ;	
	
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10000',
		'User_Controller',
		'get_list',
		'UserList',
		'Справочники',
		'Пользователи',
		FALSE
		);
	
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10001',
		'Bank_Controller',
		'get_list',
		'BankList',
		'Справочники',
		'Банки',
		FALSE
		);
	
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10002',
		'TimeZoneLocale_Controller',
		'get_list',
		'TimeZoneLocale',
		'Справочники',
		'Временные зоны',
		FALSE
		);
	
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'40000',
		'Constant_Controller',
		'get_list',
		'ConstantList',
		'Константы',
		'Все константы',
		FALSE
		);


-- ******************* update 09/10/2017 12:22:09 ******************
CREATE TYPE email_types AS ENUM (
			
				'reset_pwd'			
						
			);
			ALTER TYPE email_types OWNER TO expert72;
		
		CREATE TABLE mail_for_sending
		(id serial,date_time timestampTZ
			DEFAULT current_timestamp,from_addr  varchar(50),from_name  varchar(255),to_addr  varchar(50),to_name  varchar(255),reply_addr  varchar(50),reply_name  varchar(255),body text,sender_addr  varchar(50),subject  varchar(255),sent bool
			DEFAULT false,sent_date_time timestampTZ,email_type email_types,CONSTRAINT mail_for_sending_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS mail_for_sending_date_time_idx;
	CREATE INDEX mail_for_sending_date_time_idx
	ON mail_for_sending
	(date_time);

	DROP INDEX IF EXISTS mail_for_sending_sent_idx;
	CREATE INDEX mail_for_sending_sent_idx
	ON mail_for_sending
	(sent);

		ALTER TABLE mail_for_sending OWNER TO expert72;
	
		CREATE TABLE mail_for_sending_attachments
		(id serial,mail_for_sending_id int REFERENCES mail_for_sending(id),file_name  varchar(255),CONSTRAINT mail_for_sending_attachments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS mail_for_sending_attachments_id_idx;
	CREATE INDEX mail_for_sending_attachments_id_idx
	ON mail_for_sending_attachments
	(mail_for_sending_id);

		ALTER TABLE mail_for_sending_attachments OWNER TO expert72;
	
		CREATE TABLE email_templates
		(id serial,email_type email_types NOT NULL,template text NOT NULL,comment_text text NOT NULL,mes_subject text NOT NULL,fields text NOT NULL,CONSTRAINT email_templates_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS email_templates_type_index;
	CREATE UNIQUE INDEX email_templates_type_index
	ON email_templates
	(email_type);

		ALTER TABLE email_templates OWNER TO expert72;


-- ******************* update 09/10/2017 17:40:15 ******************
ALTER TABLE users ADD COLUMN pers_data_proc_agreement bool
			DEFAULT FALSE;
		
	DROP INDEX IF EXISTS users_name_idx;
	CREATE UNIQUE INDEX users_name_idx
	ON users
	(lower(name));

	DROP INDEX IF EXISTS users_email_idx;
	CREATE UNIQUE INDEX users_email_idx
	ON users
	(lower(email));


-- ******************* update 13/10/2017 18:50:01 ******************
ALTER TYPE role_types ADD VALUE 'client';


-- ******************* update 16/10/2017 05:51:28 ******************
ALTER TABLE users ADD COLUMN create_dt timestampTZ
			DEFAULT CURRENT_TIMESTAMP,ADD COLUMN email_confirmed bool
			DEFAULT FALSE;
		
	DROP INDEX IF EXISTS users_name_idx;
	CREATE UNIQUE INDEX users_name_idx
	ON users
	(lower(name));

	DROP INDEX IF EXISTS users_email_idx;
	CREATE UNIQUE INDEX users_email_idx
	ON users
	(lower(email));


-- ******************* update 16/10/2017 07:38:12 ******************
CREATE TABLE user_email_confiramtions
		(key  varchar(36),user_id int NOT NULL REFERENCES users(id),dt timestampTZ
			DEFAULT CURRENT_TIMESTAMP NOT NULL,CONSTRAINT user_email_confiramtions_pkey PRIMARY KEY (key));
		
		ALTER TABLE user_email_confiramtions OWNER TO expert72;


-- ******************* update 16/10/2017 07:45:40 ******************
ALTER TABLE user_email_confiramtions ADD COLUMN confirmed bool
			DEFAULT FALSE;


-- ******************* update 16/10/2017 07:55:51 ******************
ALTER TYPE email_types ADD VALUE 'user_email_conf';


-- ******************* update 16/10/2017 09:11:52 ******************
ALTER TYPE email_types ADD VALUE 'new_account';


-- ******************* update 17/10/2017 09:26:12 ******************
CREATE TABLE main_menus
		(id serial,role_id role_types NOT NULL,user_id int REFERENCES users(id),content text NOT NULL,CONSTRAINT main_menus_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS main_menus_role_user_idx;
	CREATE UNIQUE INDEX main_menus_role_user_idx
	ON main_menus
	(role_id,user_id);

		ALTER TABLE main_menus OWNER TO expert72;


-- ******************* update 17/10/2017 09:38:02 ******************
CREATE TABLE variant_storages
		(user_id int REFERENCES users(id),storage_name text,variant_name text,default_variant bool,filter_data text,col_visib_data text,col_order_data text,CONSTRAINT variant_storages_pkey PRIMARY KEY (user_id,storage_name,variant_name));
		
		ALTER TABLE variant_storages OWNER TO expert72;


-- ******************* update 17/10/2017 13:18:38 ******************
ALTER TABLE users ADD COLUMN comment_text text;
		
	DROP INDEX IF EXISTS users_name_idx;
	CREATE UNIQUE INDEX users_name_idx
	ON users
	(lower(name));

	DROP INDEX IF EXISTS users_email_idx;
	CREATE UNIQUE INDEX users_email_idx
	ON users
	(lower(email));


-- ******************* update 18/10/2017 16:18:41 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'50000',
		'User_Controller',
		'get_profile',
		'UserProfile',
		'Формы',
		'Профиль пользователя',
		FALSE
		);


-- ******************* update 18/10/2017 17:53:48 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10002',
		'MailForSending_Controller',
		'get_list',
		'MailForSendingList',
		'Справочники',
		'Электронная почта',
		FALSE
		);


-- ******************* update 18/10/2017 18:16:52 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10004',
		'EmailTemplate_Controller',
		'get_list',
		'EmailTemplateList',
		'Справочники',
		'Шаблоны писем',
		FALSE
		);


-- ******************* update 19/10/2017 13:04:15 ******************
CREATE TABLE clients
		(id serial,name  varchar(100) NOT NULL UNIQUE,name_full text NOT NULL,inn  varchar(12),kpp  varchar(10),ogrn  varchar(15),okpo  varchar(20),okved text,ext_id  varchar(36),user_id int REFERENCES users(id),post_address jsonb,legal_address jsonb,responsable_persons jsonb,CONSTRAINT clients_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_user_idx;
	CREATE INDEX clients_user_idx
	ON clients
	(user_id);

		ALTER TABLE clients OWNER TO expert72;
	
		CREATE TABLE constructions
		(id serial,client_id int REFERENCES clients(id),name text NOT NULL,address jsonb NOT NULL,CONSTRAINT constructions_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS constructions_client_idx;
	CREATE INDEX constructions_client_idx
	ON constructions
	(client_id);

	DROP INDEX IF EXISTS constructions_name_idx;
	CREATE UNIQUE INDEX constructions_name_idx
	ON constructions
	(lower(name));

		ALTER TABLE constructions OWNER TO expert72;


-- ******************* update 19/10/2017 13:14:16 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10005',
		'Client_Controller',
		'get_list',
		'ClientList',
		'Справочники',
		'Контрагенты',
		FALSE
		);


-- ******************* update 19/10/2017 17:35:50 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'50001',
		NULL,
		NULL,
		'ClientSearch',
		'Формы',
		'Поиск клиентов',
		FALSE
		);


-- ******************* update 23/10/2017 11:48:19 ******************
CREATE TABLE application_templates
		(id serial,client_id int REFERENCES clients(id),content xml NOT NULL,comment_text text,date_time timestampTZ
			DEFAULT now(),CONSTRAINT application_templates_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS application_templates_date_time_idx;
	CREATE UNIQUE INDEX application_templates_date_time_idx
	ON application_templates
	(date_time);

		ALTER TABLE application_templates OWNER TO expert72;


-- ******************* update 23/10/2017 12:22:10 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10006',
		'ApplicationTemplate_Controller',
		'get_list',
		'ApplicationTemplateList',
		'Справочники',
		'Шаблоны заявлений',
		FALSE
		);


-- ******************* update 25/10/2017 06:22:30 ******************
ALTER TABLE clients ADD COLUMN bank_accounts jsonb;
		
	DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_user_idx;
	CREATE INDEX clients_user_idx
	ON clients
	(user_id);


-- ******************* update 25/10/2017 14:47:21 ******************
CREATE TABLE offices
		(id serial,client_id int REFERENCES clients(id),address jsonb,CONSTRAINT offices_pkey PRIMARY KEY (id));
		
		ALTER TABLE offices OWNER TO expert72;


-- ******************* update 25/10/2017 14:50:14 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10007',
		'Office_Controller',
		'get_list',
		'OfficeList',
		'Справочники',
		'Места проведения экспертизы',
		FALSE
		);


-- ******************* update 25/10/2017 15:21:02 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10008',
		'Construction_Controller',
		'get_list',
		'ConstructionList',
		'Справочники',
		'Объекты строительства',
		FALSE
		);


-- ******************* update 13/11/2017 10:18:52 ******************
--Refrerece type
CREATE OR REPLACE FUNCTION clients_ref(clients)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION clients_ref(clients) OWNER TO ;
-- ************* virtual table ****************

-- VIEW: offices_list

--DROP VIEW offices_list;

CREATE OR REPLACE VIEW offices_list AS
	SELECT
		offices.*,
		clients.name AS client_descr
	FROM offices
	LEFT JOIN clients ON clients.id=offices.client_id
	;
	
ALTER VIEW offices_list OWNER TO ;


-- ******************* update 13/11/2017 10:23:09 ******************
--Refrerece type
CREATE OR REPLACE FUNCTION clients_ref(clients)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION clients_ref(clients) OWNER TO ;
-- ************* virtual table ****************

-- VIEW: offices_list

--DROP VIEW offices_list;

CREATE OR REPLACE VIEW offices_list AS
	SELECT
		offices.*,
		clients.name AS client_descr
	FROM offices
	LEFT JOIN clients ON clients.id=offices.client_id
	;
	
ALTER VIEW offices_list OWNER TO ;


-- ******************* update 14/11/2017 06:25:33 ******************
CREATE TYPE client_types AS ENUM (
			
				'enterprise'			
			,
				'person'			
						
			);
			ALTER TYPE client_types OWNER TO expert72;


-- ******************* update 14/11/2017 06:29:28 ******************
ALTER TABLE clients ADD COLUMN client_type client_types;
		
	DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_user_idx;
	CREATE INDEX clients_user_idx
	ON clients
	(user_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 14/11/2017 06:51:32 ******************
DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_inn_kpp_idx;
	CREATE UNIQUE INDEX clients_inn_kpp_idx
	ON clients
	(inn,kpp);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 14/11/2017 06:58:31 ******************
CREATE TABLE user_clients
		(id serial,name  varchar(100) NOT NULL UNIQUE,name_full text NOT NULL,inn  varchar(12) NOT NULL,kpp  varchar(10),ogrn  varchar(15),okpo  varchar(20),okved text,user_id int REFERENCES users(id),post_address jsonb,legal_address jsonb,responsable_persons jsonb,bank_accounts jsonb,client_type client_types
			DEFAULT 'enterprise'
		 NOT NULL,CONSTRAINT user_clients_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS user_clients_inn_kpp_idx;
	CREATE UNIQUE INDEX user_clients_inn_kpp_idx
	ON user_clients
	(inn,kpp);

		ALTER TABLE user_clients OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 14/11/2017 07:35:44 ******************
CREATE TYPE expertise_types AS ENUM (
			
				'pd'			
			,
				'eng_survey'			
			,
				'pd_eng_survey'			
			,
				'pd_eng_survey_estim_cost'			
						
			);
			ALTER TYPE expertise_types OWNER TO expert72;
		
			CREATE TYPE estim_cost_types AS ENUM (
			
				'construction'			
			,
				'reconstruction'			
			,
				'cap_repairs'			
						
			);
			ALTER TYPE estim_cost_types OWNER TO expert72;
		
			CREATE TYPE construction_types AS ENUM (
			
				'buildings'			
			,
				'extended_constructions'			
						
			);
			ALTER TYPE construction_types OWNER TO expert72;


-- ******************* update 14/11/2017 10:56:23 ******************
CREATE TYPE fund_sources AS ENUM (
			
				'fed_budget'			
			,
				'own'			
						
			);
			ALTER TYPE fund_sources OWNER TO expert72;
		
			CREATE TYPE aria_units AS ENUM (
			
				'm'			
			,
				'km'			
			,
				'ga'			
			,
				'akr'			
						
			);
			ALTER TYPE aria_units OWNER TO expert72;
		
		CREATE TABLE constructions
		(id serial,user_id int REFERENCES users(id),name text NOT NULL,address jsonb NOT NULL,technical_features jsonb NOT NULL,construction_type construction_types NOT NULL,total_est_cost  numeric(15,2),land_area jsonb,total_area jsonb,CONSTRAINT constructions_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS constructions_user_idx;
	CREATE INDEX constructions_user_idx
	ON constructions
	(user_id);

		ALTER TABLE constructions OWNER TO expert72;
	
		CREATE TABLE applications
		(id serial,user_id int NOT NULL REFERENCES users(id),create_dt timestampTZ
			DEFAULT now(),expertise_type expertise_types NOT NULL,estim_cost_type estim_cost_types NOT NULL,fund_source fund_sources NOT NULL,applicant_id int NOT NULL REFERENCES user_clients(id),contractors jsonb NOT NULL,construction_id int NOT NULL REFERENCES constructions(id),customer_id int NOT NULL REFERENCES user_clients(id),documents xml,CONSTRAINT applications_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS applicatios_user_idx;
	CREATE INDEX applicatios_user_idx
	ON applications
	(user_id);

	DROP INDEX IF EXISTS applicatios_create_dt_idx;
	CREATE INDEX applicatios_create_dt_idx
	ON applications
	(create_dt);

		ALTER TABLE applications OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
		
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION user_clients_ref(user_clients)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION user_clients_ref(user_clients) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION constructions_ref(constructions)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION constructions_ref(constructions) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION user_clients_ref(user_clients)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION user_clients_ref(user_clients) OWNER TO ;


-- ******************* update 14/11/2017 10:59:00 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20000',
		'Application_Controller',
		'get_list',
		'ApplicationList',
		'Документы',
		'Заявления',
		FALSE
		);


-- ******************* update 14/11/2017 14:52:41 ******************
CREATE TYPE application_states AS ENUM (
			
				'filling'			
						
			);
			ALTER TYPE application_states OWNER TO expert72;
		
		CREATE TABLE application_state_history
		(id serial,application_id int NOT NULL REFERENCES applications(id),date_time timestampTZ
			DEFAULT now() NOT NULL,state application_states NOT NULL,CONSTRAINT application_state_history_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS application_state_history_date_idx;
	CREATE INDEX application_state_history_date_idx
	ON application_state_history
	(date_time);

		ALTER TABLE application_state_history OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
		
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 14/11/2017 15:11:26 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10009',
		'UserClient_Controller',
		'get_list',
		'UserClientList',
		'Справочники',
		'Контрагенты клиента',
		FALSE
		);


-- ******************* update 15/11/2017 06:22:32 ******************
ALTER TABLE applications ,,,ADD COLUMN applicant jsonb,ADD COLUMN customer jsonb,,ADD COLUMN constr_name text,ADD COLUMN constr_address jsonb,ADD COLUMN constr_technical_features jsonb,ADD COLUMN constr_construction_type construction_types,ADD COLUMN constr_total_est_cost  numeric(15,2),ADD COLUMN constr_land_area jsonb,ADD COLUMN constr_total_area jsonb;
		
	DROP INDEX IF EXISTS applicatios_user_idx;
	CREATE INDEX applicatios_user_idx
	ON applications
	(user_id);

	DROP INDEX IF EXISTS applicatios_create_dt_idx;
	CREATE INDEX applicatios_create_dt_idx
	ON applications
	(create_dt);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION user_clients_ref(user_clients)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION user_clients_ref(user_clients) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION constructions_ref(constructions)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION constructions_ref(constructions) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION user_clients_ref(user_clients)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION user_clients_ref(user_clients) OWNER TO ;


-- ******************* update 15/11/2017 06:32:55 ******************
DELETE FROM views WHERE id='10008';


-- ******************* update 15/11/2017 06:36:05 ******************
DELETE FROM views WHERE id='10009';


-- ******************* update 15/11/2017 14:22:03 ******************
ALTER TABLE clients ADD COLUMN base_document_for_contract text;
		
	DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_inn_kpp_idx;
	CREATE UNIQUE INDEX clients_inn_kpp_idx
	ON clients
	(inn,kpp);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 16/11/2017 10:33:40 ******************
CREATE TABLE person_id_papers
		(name  varchar(100),CONSTRAINT person_id_papers_pkey PRIMARY KEY (name));
		
		ALTER TABLE person_id_papers OWNER TO expert72;


-- ******************* update 16/11/2017 13:40:37 ******************
CREATE TABLE person_id_papers
		(id serial,name  varchar(100),CONSTRAINT person_id_papers_pkey PRIMARY KEY (id));
		
		ALTER TABLE person_id_papers OWNER TO expert72;
		
		ALTER TABLE clients ADD COLUMN person_id_paper jsonb;
		
	DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_inn_kpp_idx;
	CREATE UNIQUE INDEX clients_inn_kpp_idx
	ON clients
	(inn,kpp);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 16/11/2017 14:24:11 ******************
CREATE TABLE person_id_papers
		(id serial,name  varchar(100),CONSTRAINT person_id_papers_pkey PRIMARY KEY (id));
		
		ALTER TABLE person_id_papers OWNER TO expert72;
		
		ALTER TABLE clients ADD COLUMN person_id_paper jsonb,ADD COLUMN person_registr_paper jsonb;
		
	DROP INDEX IF EXISTS clients_name_idx;
	CREATE INDEX clients_name_idx
	ON clients
	(lower(name));

	DROP INDEX IF EXISTS clients_inn_kpp_idx;
	CREATE UNIQUE INDEX clients_inn_kpp_idx
	ON clients
	(inn,kpp);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 20/11/2017 10:04:07 ******************
DROP INDEX IF EXISTS application_state_history_idx;
	CREATE INDEX application_state_history_idx
	ON application_state_history
	(application_id,date_time);

		CREATE TABLE application_document_files
		(application_id int REFERENCES applications(id),document_id int,date_time timestampTZ
			DEFAULT now() NOT NULL,file_id  varchar(32) NOT NULL,CONSTRAINT application_document_files_pkey PRIMARY KEY (application_id,document_id));
		
		ALTER TABLE application_document_files OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 20/11/2017 10:07:00 ******************
ALTER TABLE application_document_files ADD COLUMN file_size int;
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 20/11/2017 11:01:47 ******************
ALTER TABLE application_document_files ADD COLUMN file_name text,,;
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 21/11/2017 16:41:29 ******************
--constant value table
		CREATE TABLE IF NOT EXISTS const_client_download_max_file_size
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_client_download_max_file_size OWNER TO expert72;
		INSERT INTO const_client_download_max_file_size (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Максимальный размер файла для загрузки'
			,'Максимальный размер файла, разрешенный для загрузки клиентам'
			,83886080
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_max_file_size_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_client_download_max_file_size LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_max_file_size_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_max_file_size_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_max_file_size SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_max_file_size_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_max_file_size_view AS
		SELECT
			'client_download_max_file_size'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_max_file_size AS t
		;
		ALTER VIEW const_client_download_max_file_size_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_client_download_file_types
		(name text, descr text, val text,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_client_download_file_types OWNER TO expert72;
		INSERT INTO const_client_download_file_types (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Расширения файлов для загрузки'
			,'Список разрешенных расширений файлов для загрузки клиентами'
			,NULL
			,'Text'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_file_types_val()
		RETURNS text AS
		$BODY$
			
			SELECT val::text AS val FROM const_client_download_file_types LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_file_types_set_val(Text)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_file_types SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_set_val(Text) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_file_types_view AS
		SELECT
			'client_download_file_types'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_file_types AS t
		;
		ALTER VIEW const_client_download_file_types_view OWNER TO expert72;
	
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
		FROM const_client_download_max_file_size_view
		UNION ALL
		
		SELECT *
		FROM const_client_download_file_types_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 21/11/2017 16:49:06 ******************
DROP FUNCTION const_doc_per_page_count_val();
		DROP FUNCTION const_doc_per_page_count_set_val(Int);
		DROP VIEW const_doc_per_page_count_view CASCADE;
		
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_doc_per_page_count LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_doc_per_page_count SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_doc_per_page_count_view AS
		SELECT
			'doc_per_page_count'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_doc_per_page_count AS t
		;
		ALTER VIEW const_doc_per_page_count_view OWNER TO expert72;
	
		DROP FUNCTION const_grid_refresh_interval_val();
		DROP FUNCTION const_grid_refresh_interval_set_val(Int);
		DROP VIEW const_grid_refresh_interval_view CASCADE;
		
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_grid_refresh_interval LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_grid_refresh_interval SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_grid_refresh_interval_view AS
		SELECT
			'grid_refresh_interval'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_grid_refresh_interval AS t
		;
		ALTER VIEW const_grid_refresh_interval_view OWNER TO expert72;
	
		DROP FUNCTION const_session_live_time_val();
		DROP FUNCTION const_session_live_time_set_val(Interval);
		DROP VIEW const_session_live_time_view CASCADE;
		
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_session_live_time_val()
		RETURNS interval AS
		$BODY$
			
			SELECT val::interval AS val FROM const_session_live_time LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_session_live_time_set_val(Interval)
		RETURNS void AS
		$BODY$
			UPDATE const_session_live_time SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_set_val(Interval) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_session_live_time_view AS
		SELECT
			'session_live_time'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_session_live_time AS t
		;
		ALTER VIEW const_session_live_time_view OWNER TO expert72;
	
		DROP FUNCTION const_client_download_max_file_size_val();
		DROP FUNCTION const_client_download_max_file_size_set_val(Int);
		DROP VIEW const_client_download_max_file_size_view CASCADE;
		
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_max_file_size_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_client_download_max_file_size LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_max_file_size_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_max_file_size_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_max_file_size SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_max_file_size_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_max_file_size_view AS
		SELECT
			'client_download_max_file_size'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_max_file_size AS t
		;
		ALTER VIEW const_client_download_max_file_size_view OWNER TO expert72;
	
		DROP FUNCTION const_client_download_file_types_val();
		DROP FUNCTION const_client_download_file_types_set_val(Text);
		DROP VIEW const_client_download_file_types_view CASCADE;
		
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_file_types_val()
		RETURNS text AS
		$BODY$
			
			SELECT val::text AS val FROM const_client_download_file_types LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_file_types_set_val(Text)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_file_types SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_set_val(Text) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_file_types_view AS
		SELECT
			'client_download_file_types'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_file_types AS t
		;
		ALTER VIEW const_client_download_file_types_view OWNER TO expert72;
	
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
		FROM const_client_download_max_file_size_view
		UNION ALL
		
		SELECT *
		FROM const_client_download_file_types_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 21/11/2017 16:54:55 ******************
--constant value table
		CREATE TABLE IF NOT EXISTS const_doc_per_page_count
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_doc_per_page_count OWNER TO expert72;
		INSERT INTO const_doc_per_page_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Количество документов на странице'
			,'Количество документов на странице в журнале документов'
			,60
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_doc_per_page_count LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_doc_per_page_count SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_doc_per_page_count_view AS
		SELECT
			'doc_per_page_count'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_doc_per_page_count AS t
		;
		ALTER VIEW const_doc_per_page_count_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_grid_refresh_interval
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_grid_refresh_interval OWNER TO expert72;
		INSERT INTO const_grid_refresh_interval (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Период обновления таблиц'
			,'Период обновления таблиц в секундах'
			,15
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_grid_refresh_interval LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_grid_refresh_interval SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_grid_refresh_interval_view AS
		SELECT
			'grid_refresh_interval'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_grid_refresh_interval AS t
		;
		ALTER VIEW const_grid_refresh_interval_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_session_live_time
		(name text, descr text, val interval,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_session_live_time OWNER TO expert72;
		INSERT INTO const_session_live_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Время жизни сессии'
			,'Время, в течении которого сессия не будет удаляться на сервере'
			,
				'48:00'
				
			,'Interval'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_session_live_time_val()
		RETURNS interval AS
		$BODY$
			
			SELECT val::interval AS val FROM const_session_live_time LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_session_live_time_set_val(Interval)
		RETURNS void AS
		$BODY$
			UPDATE const_session_live_time SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_set_val(Interval) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_session_live_time_view AS
		SELECT
			'session_live_time'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_session_live_time AS t
		;
		ALTER VIEW const_session_live_time_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_client_download_max_file_size
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_client_download_max_file_size OWNER TO expert72;
		INSERT INTO const_client_download_max_file_size (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Максимальный размер файла для загрузки'
			,'Максимальный размер файла, разрешенный для загрузки клиентам'
			,83886080
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_max_file_size_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_client_download_max_file_size LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_max_file_size_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_max_file_size_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_max_file_size SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_max_file_size_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_max_file_size_view AS
		SELECT
			'client_download_max_file_size'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_max_file_size AS t
		;
		ALTER VIEW const_client_download_max_file_size_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_client_download_file_types
		(name text, descr text, val text,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_client_download_file_types OWNER TO expert72;
		INSERT INTO const_client_download_file_types (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Расширения файлов для загрузки'
			,'Список разрешенных расширений файлов для загрузки клиентами'
			,NULL
			,'Text'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_file_types_val()
		RETURNS text AS
		$BODY$
			
			SELECT val::text AS val FROM const_client_download_file_types LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_file_types_set_val(Text)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_file_types SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_set_val(Text) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_file_types_view AS
		SELECT
			'client_download_file_types'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_file_types AS t
		;
		ALTER VIEW const_client_download_file_types_view OWNER TO expert72;
	
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
		FROM const_client_download_max_file_size_view
		UNION ALL
		
		SELECT *
		FROM const_client_download_file_types_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 22/11/2017 11:25:19 ******************
DROP INDEX IF EXISTS application_document_files_file_id_idx;
	CREATE INDEX application_document_files_file_id_idx
	ON application_document_files
	(file_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 22/11/2017 11:34:51 ******************
CREATE TABLE application_document_files
		(file_id  varchar(36),application_id int NOT NULL REFERENCES applications(id),document_id int NOT NULL,date_time timestampTZ
			DEFAULT now() NOT NULL,file_name text,file_size int,CONSTRAINT application_document_files_pkey PRIMARY KEY (file_id));
		
	DROP INDEX IF EXISTS application_document_files_application_idx;
	CREATE INDEX application_document_files_application_idx
	ON application_document_files
	(application_id);

		ALTER TABLE application_document_files OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 22/11/2017 13:47:10 ******************
ALTER TYPE application_states ADD VALUE 'app_sent';


-- ******************* update 23/11/2017 06:53:16 ******************
ALTER TYPE application_states ADD VALUE 'sent';


-- ******************* update 23/11/2017 09:22:46 ******************
--constant value table
		CREATE TABLE IF NOT EXISTS const_doc_per_page_count
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_doc_per_page_count OWNER TO expert72;
		INSERT INTO const_doc_per_page_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Количество документов на странице'
			,'Количество документов на странице в журнале документов'
			,60
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_doc_per_page_count LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_doc_per_page_count SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_doc_per_page_count_view AS
		SELECT
			'doc_per_page_count'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_doc_per_page_count AS t
		;
		ALTER VIEW const_doc_per_page_count_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_grid_refresh_interval
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_grid_refresh_interval OWNER TO expert72;
		INSERT INTO const_grid_refresh_interval (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Период обновления таблиц'
			,'Период обновления таблиц в секундах'
			,15
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_grid_refresh_interval LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_grid_refresh_interval SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_grid_refresh_interval_view AS
		SELECT
			'grid_refresh_interval'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_grid_refresh_interval AS t
		;
		ALTER VIEW const_grid_refresh_interval_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_session_live_time
		(name text, descr text, val interval,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_session_live_time OWNER TO expert72;
		INSERT INTO const_session_live_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Время жизни сессии'
			,'Время, в течении которого сессия не будет удаляться на сервере'
			,
				'48:00'
				
			,'Interval'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_session_live_time_val()
		RETURNS interval AS
		$BODY$
			
			SELECT val::interval AS val FROM const_session_live_time LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_session_live_time_set_val(Interval)
		RETURNS void AS
		$BODY$
			UPDATE const_session_live_time SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_session_live_time_set_val(Interval) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_session_live_time_view AS
		SELECT
			'session_live_time'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_session_live_time AS t
		;
		ALTER VIEW const_session_live_time_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_client_download_file_types
		(name text, descr text, val text,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_client_download_file_types OWNER TO expert72;
		INSERT INTO const_client_download_file_types (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Расширения файлов для загрузки'
			,'Список разрешенных расширений файлов для загрузки клиентами. Расширения разделены запятой.'
			,NULL
			,'Text'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_file_types_val()
		RETURNS text AS
		$BODY$
			
			SELECT val::text AS val FROM const_client_download_file_types LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_file_types_set_val(Text)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_file_types SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_types_set_val(Text) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_file_types_view AS
		SELECT
			'client_download_file_types'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_file_types AS t
		;
		ALTER VIEW const_client_download_file_types_view OWNER TO expert72;
	
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
		FROM const_client_download_file_types_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 23/11/2017 10:44:46 ******************
ALTER TABLE applications ADD COLUMN filled_percent int;
		
	DROP INDEX IF EXISTS applicatios_user_idx;
	CREATE INDEX applicatios_user_idx
	ON applications
	(user_id);

	DROP INDEX IF EXISTS applicatios_create_dt_idx;
	CREATE INDEX applicatios_create_dt_idx
	ON applications
	(create_dt);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 23/11/2017 12:22:44 ******************
ALTER TABLE applications ADD COLUMN office_id int REFERENCES offices(id);
		
	DROP INDEX IF EXISTS applicatios_user_idx;
	CREATE INDEX applicatios_user_idx
	ON applications
	(user_id);

	DROP INDEX IF EXISTS applicatios_create_dt_idx;
	CREATE INDEX applicatios_create_dt_idx
	ON applications
	(create_dt);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION offices_ref(offices)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION offices_ref(offices) OWNER TO ;


-- ******************* update 27/11/2017 09:36:40 ******************
/* function */
		CREATE OR REPLACE FUNCTION 
		enum_locales_val(locales,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'ru'::locales=$1 AND '


-- ******************* update 27/11/2017 09:38:33 ******************
/* function */
		CREATE OR REPLACE FUNCTION 
		enum_locales_val(locales,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'ru'::locales=$1 AND 'ru'::locales=$2 THEN 'Русский'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_locales_val(locales,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_role_types_val(role_types,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'admin'::role_types=$1 AND 'ru'::locales=$2 THEN 'Администратор'
			
			CASE WHEN 'client'::role_types=$1 AND 'ru'::locales=$2 THEN 'Клиент'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_role_types_val(role_types,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_email_types_val(email_types,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'new_account'::email_types=$1 AND 'ru'::locales=$2 THEN 'Новый акаунт'
			
			CASE WHEN 'reset_pwd'::email_types=$1 AND 'ru'::locales=$2 THEN 'Установка пароля'
			
			CASE WHEN 'user_email_conf'::email_types=$1 AND 'ru'::locales=$2 THEN 'Подтверждение пароля'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_email_types_val(email_types,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_client_types_val(client_types,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'enterprise'::client_types=$1 AND 'ru'::locales=$2 THEN 'Юридическое лицо'
			
			CASE WHEN 'person'::client_types=$1 AND 'ru'::locales=$2 THEN 'Индивидуальный предприниматель'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_client_types_val(client_types,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_expertise_types_val(expertise_types,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'pd'::expertise_types=$1 AND 'ru'::locales=$2 THEN 'Государственная экспертиза проектной документации'
			
			CASE WHEN 'eng_survey'::expertise_types=$1 AND 'ru'::locales=$2 THEN 'Государственная экспертиза результатов инженерных изысканий'
			
			CASE WHEN 'pd_eng_survey'::expertise_types=$1 AND 'ru'::locales=$2 THEN 'Государственная экспертиза проектной документации и Государственная экспертиза результатов инженерных изысканий'
			
			CASE WHEN 'pd_eng_survey_estim_cost'::expertise_types=$1 AND 'ru'::locales=$2 THEN 'Государственная экспертиза проектной документации и результатов инженерных изысканий с одновременной проверкой достоверности определения сметной стоимости'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_expertise_types_val(expertise_types,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_estim_cost_types_val(estim_cost_types,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'construction'::estim_cost_types=$1 AND 'ru'::locales=$2 THEN 'Cтроительство'
			
			CASE WHEN 'reconstruction'::estim_cost_types=$1 AND 'ru'::locales=$2 THEN 'Реконструкция'
			
			CASE WHEN 'capital_repairs'::estim_cost_types=$1 AND 'ru'::locales=$2 THEN 'Капитальный ремонт'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_estim_cost_types_val(estim_cost_types,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_construction_types_val(construction_types,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'buildings'::construction_types=$1 AND 'ru'::locales=$2 THEN 'Здания и сооружения'
			
			CASE WHEN 'extended_constructions'::construction_types=$1 AND 'ru'::locales=$2 THEN 'Линейно-протяжённые объекты'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_construction_types_val(construction_types,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_fund_sources_val(fund_sources,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'fed_budget'::fund_sources=$1 AND 'ru'::locales=$2 THEN 'Федеральный бюджет'
			
			CASE WHEN 'own'::fund_sources=$1 AND 'ru'::locales=$2 THEN 'Собственные средства'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_fund_sources_val(fund_sources,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_aria_units_val(aria_units,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'm'::aria_units=$1 AND 'ru'::locales=$2 THEN 'м2'
			
			CASE WHEN 'km'::aria_units=$1 AND 'ru'::locales=$2 THEN 'км2'
			
			CASE WHEN 'ga'::aria_units=$1 AND 'ru'::locales=$2 THEN 'га'
			
			CASE WHEN 'akr'::aria_units=$1 AND 'ru'::locales=$2 THEN 'акр'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_aria_units_val(aria_units,locales)
	 OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION 
		enum_application_states_val(application_states,locales)
	
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'filling'::application_states=$1 AND 'ru'::locales=$2 THEN 'Заполнение анкеты'
			
			CASE WHEN 'sent'::application_states=$1 AND 'ru'::locales=$2 THEN 'Анкета отправлена'
			
			CASE WHEN 'checking'::application_states=$1 AND 'ru'::locales=$2 THEN 'Проверка анкеты'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION 
		enum_application_states_val(application_states,locales)
	 OWNER TO expert72;


-- ******************* update 27/11/2017 09:43:10 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_role_types_val(role_types,locales)
		RETURNS text AS $$
			SELECT
			
			CASE WHEN 'admin'::role_types=$1 AND 'ru'::locales=$2 THEN 'Администратор'
			
			CASE WHEN 'client'::role_types=$1 AND 'ru'::locales=$2 THEN 'Клиент'
			
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_role_types_val(role_types,locales) OWNER TO expert72;


-- ******************* update 27/11/2017 09:44:34 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_role_types_val(role_types,locales)
		RETURNS text AS $$
			SELECT
			CASE WHEN $1='admin'::role_types AND $2='ru'::locales THEN 'Администратор'
			CASE WHEN $1='client'::role_types AND $2='ru'::locales THEN 'Клиент'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_role_types_val(role_types,locales) OWNER TO expert72;


-- ******************* update 27/11/2017 09:45:33 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_role_types_val(role_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='admin'::role_types AND $2='ru'::locales THEN 'Администратор'
			WHEN $1='client'::role_types AND $2='ru'::locales THEN 'Клиент'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_role_types_val(role_types,locales) OWNER TO expert72;


-- ******************* update 27/11/2017 09:46:38 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_locales_val(locales,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='ru'::locales AND $2='ru'::locales THEN 'Русский'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_locales_val(locales,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_email_types_val(email_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='new_account'::email_types AND $2='ru'::locales THEN 'Новый акаунт'
			WHEN $1='reset_pwd'::email_types AND $2='ru'::locales THEN 'Установка пароля'
			WHEN $1='user_email_conf'::email_types AND $2='ru'::locales THEN 'Подтверждение пароля'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_email_types_val(email_types,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_client_types_val(client_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='enterprise'::client_types AND $2='ru'::locales THEN 'Юридическое лицо'
			WHEN $1='person'::client_types AND $2='ru'::locales THEN 'Индивидуальный предприниматель'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_client_types_val(client_types,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_expertise_types_val(expertise_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='pd'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации'
			WHEN $1='eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза результатов инженерных изысканий'
			WHEN $1='pd_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации и Государственная экспертиза результатов инженерных изысканий'
			WHEN $1='pd_eng_survey_estim_cost'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации и результатов инженерных изысканий с одновременной проверкой достоверности определения сметной стоимости'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_expertise_types_val(expertise_types,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_estim_cost_types_val(estim_cost_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='construction'::estim_cost_types AND $2='ru'::locales THEN 'Cтроительство'
			WHEN $1='reconstruction'::estim_cost_types AND $2='ru'::locales THEN 'Реконструкция'
			WHEN $1='capital_repairs'::estim_cost_types AND $2='ru'::locales THEN 'Капитальный ремонт'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_estim_cost_types_val(estim_cost_types,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_construction_types_val(construction_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='buildings'::construction_types AND $2='ru'::locales THEN 'Здания и сооружения'
			WHEN $1='extended_constructions'::construction_types AND $2='ru'::locales THEN 'Линейно-протяжённые объекты'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_construction_types_val(construction_types,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_fund_sources_val(fund_sources,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='fed_budget'::fund_sources AND $2='ru'::locales THEN 'Федеральный бюджет'
			WHEN $1='own'::fund_sources AND $2='ru'::locales THEN 'Собственные средства'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_fund_sources_val(fund_sources,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_aria_units_val(aria_units,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='m'::aria_units AND $2='ru'::locales THEN 'м2'
			WHEN $1='km'::aria_units AND $2='ru'::locales THEN 'км2'
			WHEN $1='ga'::aria_units AND $2='ru'::locales THEN 'га'
			WHEN $1='akr'::aria_units AND $2='ru'::locales THEN 'акр'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_aria_units_val(aria_units,locales) OWNER TO expert72;		
		
		/* function */
		CREATE OR REPLACE FUNCTION enum_application_states_val(application_states,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='filling'::application_states AND $2='ru'::locales THEN 'Заполнение анкеты'
			WHEN $1='sent'::application_states AND $2='ru'::locales THEN 'Анкета отправлена'
			WHEN $1='checking'::application_states AND $2='ru'::locales THEN 'Проверка анкеты'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_application_states_val(application_states,locales) OWNER TO expert72;


-- ******************* update 27/11/2017 09:47:58 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_application_states_val(application_states,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='filling'::application_states AND $2='ru'::locales THEN 'Заполнение анкеты'
			WHEN $1='sent'::application_states AND $2='ru'::locales THEN 'Анкета отправлена'
			WHEN $1='checking'::application_states AND $2='ru'::locales THEN 'Проверка анкеты'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_application_states_val(application_states,locales) OWNER TO expert72;		
		
					ALTER TYPE application_states ADD VALUE 'checking';


-- ******************* update 27/11/2017 11:14:16 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_role_types_val(role_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='admin'::role_types AND $2='ru'::locales THEN 'Администратор'
			WHEN $1='client'::role_types AND $2='ru'::locales THEN 'Клиент'
			WHEN $1='lawyer'::role_types AND $2='ru'::locales THEN 'Юрист отдела приема'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_role_types_val(role_types,locales) OWNER TO expert72;		
		
					ALTER TYPE role_types ADD VALUE 'lawyer';


-- ******************* update 27/11/2017 12:36:54 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_application_states_val(application_states,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='filling'::application_states AND $2='ru'::locales THEN 'Заполнение анкеты'
			WHEN $1='sent'::application_states AND $2='ru'::locales THEN 'Анкета отправлена на проаерку'
			WHEN $1='checking'::application_states AND $2='ru'::locales THEN 'Проверка анкеты'
			WHEN $1='returned'::application_states AND $2='ru'::locales THEN 'Анкета возвращена на доработку'
			WHEN $1='closed_no_expertise'::application_states AND $2='ru'::locales THEN 'Возврат без рассмотрения'
			WHEN $1='waiting_for_contract'::application_states AND $2='ru'::locales THEN 'Подписание контракта'
			WHEN $1='waiting_for_pay'::application_states AND $2='ru'::locales THEN 'Ожидание оплаты'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_application_states_val(application_states,locales) OWNER TO expert72;		
		
					ALTER TYPE application_states ADD VALUE 'returned';
					
					ALTER TYPE application_states ADD VALUE 'closed_no_expertise';
					
					ALTER TYPE application_states ADD VALUE 'waiting_for_contract';
					
					ALTER TYPE application_states ADD VALUE 'waiting_for_pay';


-- ******************* update 27/11/2017 13:34:59 ******************
CREATE TABLE chat_messages
		(id serial,date_time timestampTZ,user_id int REFERENCES users(id),to_user_id int REFERENCES users(id),content text,parent_message_id int REFERENCES chat_messages(id),CONSTRAINT chat_messages_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS chat_messages_period_idx;
	CREATE INDEX chat_messages_period_idx
	ON chat_messages
	(date_time);

	DROP INDEX IF EXISTS chat_messages_to_user_idx;
	CREATE INDEX chat_messages_to_user_idx
	ON chat_messages
	(to_user_id);

		ALTER TABLE chat_messages OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION chat_messages_ref(chat_messages)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.content
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION chat_messages_ref(chat_messages) OWNER TO ;


-- ******************* update 28/11/2017 06:49:06 ******************
CREATE TABLE application_dost_templates
		(id serial,content xml NOT NULL,comment_text text,date_time timestampTZ
			DEFAULT now(),CONSTRAINT application_dost_templates_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS application_dost_templates_date_time_idx;
	CREATE UNIQUE INDEX application_dost_templates_date_time_idx
	ON application_dost_templates
	(date_time);

		ALTER TABLE application_dost_templates OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
		UPDATE views SET
			c='ApplicationPdTemplate_Controller',
			f='get_list',
			t='ApplicationPdTemplateList',
			section='Справочники',
			descr='Шаблоны заявлений ПД',
			limited=FALSE
		WHERE id='10006';
	
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10008',
		'ApplicationDostTemplate_Controller',
		'get_list',
		'ApplicationDostTemplateList',
		'Справочники',
		'Шаблоны заявлений достоверность',
		FALSE
		);


-- ******************* update 28/11/2017 07:04:35 ******************
ALTER TABLE applications ADD COLUMN documents_dost xml,,,,,,,,,,,,;
		
	DROP INDEX IF EXISTS applicatios_user_idx;
	CREATE INDEX applicatios_user_idx
	ON applications
	(user_id);

	DROP INDEX IF EXISTS applicatios_create_dt_idx;
	CREATE INDEX applicatios_create_dt_idx
	ON applications
	(create_dt);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION offices_ref(offices)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION offices_ref(offices) OWNER TO ;


-- ******************* update 28/11/2017 08:48:32 ******************
DROP INDEX IF EXISTS application_pd_document_files_application_idx;
	CREATE INDEX application_pd_document_files_application_idx
	ON application_pd_document_files
	(application_id);

		CREATE TABLE application_dost_document_files
		(file_id  varchar(36),application_id int NOT NULL REFERENCES applications(id),document_id int NOT NULL,date_time timestampTZ
			DEFAULT now() NOT NULL,file_name text,file_size int,CONSTRAINT application_dost_document_files_pkey PRIMARY KEY (file_id));
		
	DROP INDEX IF EXISTS application_dost_document_files_application_idx;
	CREATE INDEX application_dost_document_files_application_idx
	ON application_dost_document_files
	(application_id);

		ALTER TABLE application_dost_document_files OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 28/11/2017 10:27:06 ******************
ALTER TABLE application_pd_document_files ADD COLUMN deleted bool;
		
	DROP INDEX IF EXISTS application_pd_document_files_application_idx;
	CREATE INDEX application_pd_document_files_application_idx
	ON application_pd_document_files
	(application_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 28/11/2017 10:47:06 ******************
ALTER TABLE application_pd_document_files ADD COLUMN deleted_dt timestampTZ;
		
	DROP INDEX IF EXISTS application_pd_document_files_application_idx;
	CREATE INDEX application_pd_document_files_application_idx
	ON application_pd_document_files
	(application_id);
	
		ALTER TABLE application_dost_document_files ADD COLUMN deleted_dt timestampTZ;
		
	DROP INDEX IF EXISTS application_dost_document_files_application_idx;
	CREATE INDEX application_dost_document_files_application_idx
	ON application_dost_document_files
	(application_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 28/11/2017 10:53:30 ******************
ALTER TABLE application_pd_document_files ADD COLUMN file_path text,,,;
		
	DROP INDEX IF EXISTS application_pd_document_files_application_idx;
	CREATE INDEX application_pd_document_files_application_idx
	ON application_pd_document_files
	(application_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 29/11/2017 07:09:09 ******************
--constant value table
		CREATE TABLE IF NOT EXISTS const_app_building_tech_features
		(name text, descr text, val text,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_app_building_tech_features OWNER TO expert72;
		INSERT INTO const_app_building_tech_features (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Технические характеристики зданий'
			,'Список технических характеристик здания. Подставляется в заявление клиента по умолчанию'
			,NULL
			,'Text'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_app_building_tech_features_val()
		RETURNS text AS
		$BODY$
			
			SELECT val::text AS val FROM const_app_building_tech_features LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_app_building_tech_features_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_app_building_tech_features_set_val(Text)
		RETURNS void AS
		$BODY$
			UPDATE const_app_building_tech_features SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_app_building_tech_features_set_val(Text) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_app_building_tech_features_view AS
		SELECT
			'app_building_tech_features'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_app_building_tech_features AS t
		;
		ALTER VIEW const_app_building_tech_features_view OWNER TO expert72;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_app_extended_constr_tech_features
		(name text, descr text, val text,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_app_extended_constr_tech_features OWNER TO expert72;
		INSERT INTO const_app_extended_constr_tech_features (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Технические характеристики линейного объекта'
			,'Список технических характеристик линейного объекта. Подставляется в заявление клиента по умолчанию'
			,NULL
			,'Text'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_app_extended_constr_tech_features_val()
		RETURNS text AS
		$BODY$
			
			SELECT val::text AS val FROM const_app_extended_constr_tech_features LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_app_extended_constr_tech_features_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_app_extended_constr_tech_features_set_val(Text)
		RETURNS void AS
		$BODY$
			UPDATE const_app_extended_constr_tech_features SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_app_extended_constr_tech_features_set_val(Text) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_app_extended_constr_tech_features_view AS
		SELECT
			'app_extended_constr_tech_features'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_app_extended_constr_tech_features AS t
		;
		ALTER VIEW const_app_extended_constr_tech_features_view OWNER TO expert72;
	
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
		FROM const_app_building_tech_features_view
		UNION ALL
		
		SELECT *
		FROM const_app_extended_constr_tech_features_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 29/11/2017 07:29:14 ******************
--constant value table
		CREATE TABLE IF NOT EXISTS const_client_download_file_max_size
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_client_download_file_max_size OWNER TO expert72;
		INSERT INTO const_client_download_file_max_size (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Максимальный размер файла для загрузки'
			,'Максимальный разрешенный размер файла для загрузки клиентами на сервер.'
			,83886080
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_file_max_size_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_client_download_file_max_size LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_max_size_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_file_max_size_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_file_max_size SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_max_size_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_file_max_size_view AS
		SELECT
			'client_download_file_max_size'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_file_max_size AS t
		;
		ALTER VIEW const_client_download_file_max_size_view OWNER TO expert72;
	
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
		FROM const_app_building_tech_features_view
		UNION ALL
		
		SELECT *
		FROM const_app_extended_constr_tech_features_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 29/11/2017 08:55:53 ******************
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
		FROM const_app_building_tech_features_view
		UNION ALL
		
		SELECT *
		FROM const_app_extended_constr_tech_features_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 29/11/2017 09:02:10 ******************
CREATE TABLE constr_type_technical_features
		(construction_type construction_types,technical_features json,CONSTRAINT constr_type_technical_features_pkey PRIMARY KEY (construction_type));
		
		ALTER TABLE constr_type_technical_features OWNER TO expert72;


-- ******************* update 29/11/2017 09:05:16 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10008',
		'ConstrTypeTechnicalFeature_Controller',
		'get_list',
		'ConstrTypeTechnicalFeatureList',
		'Справочники',
		'Технические характеристики объектов строительства',
		FALSE
		);


-- ******************* update 29/11/2017 12:13:37 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_responsable_person_types_val(responsable_person_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='boss'::responsable_person_types AND $2='ru'::locales THEN 'Руководитель'
			WHEN $1='chef_accountant'::responsable_person_types AND $2='ru'::locales THEN 'Главны бухгалтер'
			WHEN $1='other'::responsable_person_types AND $2='ru'::locales THEN 'Прочий'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_responsable_person_types_val(responsable_person_types,locales) OWNER TO expert72;		
		
			CREATE TYPE responsable_person_types AS ENUM (
			
				'boss'			
			,
				'chef_accountant'			
			,
				'other'			
						
			);
			ALTER TYPE responsable_person_types OWNER TO expert72;


-- ******************* update 29/11/2017 13:11:59 ******************
CREATE TABLE morpher
		(src text,res xml,CONSTRAINT morpher_pkey PRIMARY KEY (src));
		
		ALTER TABLE morpher OWNER TO expert72;


-- ******************* update 30/11/2017 17:33:03 ******************
--constant value table
		CREATE TABLE IF NOT EXISTS const_application_check_days
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_application_check_days OWNER TO expert72;
		INSERT INTO const_application_check_days (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Срок на проверку отправленных заявлений'
			,'Рабочих дней на проверку отправленных заявлений.'
			,3
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
	
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_application_check_days_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_application_check_days LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_application_check_days_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_application_check_days_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_application_check_days SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_application_check_days_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_application_check_days_view AS
		SELECT
			'application_check_days'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_application_check_days AS t
		;
		ALTER VIEW const_application_check_days_view OWNER TO expert72;
	
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
		FROM const_application_check_days_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 30/11/2017 17:34:34 ******************
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
		FROM const_application_check_days_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 30/11/2017 17:35:13 ******************
DROP FUNCTION const_client_download_file_max_size_val();
		DROP FUNCTION const_client_download_file_max_size_set_val(Int);
		DROP VIEW const_client_download_file_max_size_view CASCADE;
		
		--constant get value
		
		CREATE OR REPLACE FUNCTION const_client_download_file_max_size_val()
		RETURNS int AS
		$BODY$
			
			SELECT val::int AS val FROM const_client_download_file_max_size LIMIT 1;
			
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_max_size_val() OWNER TO expert72;
		
		--constant set value
		CREATE OR REPLACE FUNCTION const_client_download_file_max_size_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_client_download_file_max_size SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_client_download_file_max_size_set_val(Int) OWNER TO expert72;
		
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_client_download_file_max_size_view AS
		SELECT
			'client_download_file_max_size'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_client_download_file_max_size AS t
		;
		ALTER VIEW const_client_download_file_max_size_view OWNER TO expert72;


-- ******************* update 30/11/2017 17:35:53 ******************
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
		FROM const_application_check_days_view;
		ALTER VIEW constants_list_view OWNER TO ;


-- ******************* update 30/11/2017 17:56:26 ******************
CREATE TABLE holidays
		(date date,name  varchar(50),CONSTRAINT holidays_pkey PRIMARY KEY (date));
		
		ALTER TABLE holidays OWNER TO expert72;


-- ******************* update 30/11/2017 17:58:08 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10010',
		'Holiday_Controller',
		'get_list',
		'HolidayList',
		'Справочники',
		'Государствееные праздники',
		FALSE
		);


-- ******************* update 01/12/2017 16:49:00 ******************
CREATE TABLE out_mail
		(id serial,date_time timestampTZ,user_id int REFERENCES users(id),to_user_id int REFERENCES users(id),application_id int REFERENCES applications(id),subject text,content text,CONSTRAINT out_mail_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS out_mail_date_time_idx;
	CREATE INDEX out_mail_date_time_idx
	ON out_mail
	(date_time);

	DROP INDEX IF EXISTS out_mail_to_user_idx;
	CREATE INDEX out_mail_to_user_idx
	ON out_mail
	(to_user_id);

		ALTER TABLE out_mail OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 01/12/2017 16:55:38 ******************
CREATE TABLE out_mail_attachments
		(id serial,out_mail_id int REFERENCES out_mail(id),file_name  varchar(255),CONSTRAINT out_mail_attachments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS out_mail_attachments_mail_id_idx;
	CREATE INDEX out_mail_attachments_mail_id_idx
	ON out_mail_attachments
	(out_mail_id);

		ALTER TABLE out_mail_attachments OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION out_mail_ref(out_mail)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.subject
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION out_mail_ref(out_mail) OWNER TO ;


-- ******************* update 01/12/2017 17:21:45 ******************
ALTER TABLE out_mail ADD COLUMN reg_number  varchar(15),;
		
	DROP INDEX IF EXISTS out_mail_date_time_idx;
	CREATE INDEX out_mail_date_time_idx
	ON out_mail
	(date_time);

	DROP INDEX IF EXISTS out_mail_to_user_idx;
	CREATE INDEX out_mail_to_user_idx
	ON out_mail
	(to_user_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 01/12/2017 17:25:25 ******************
DROP INDEX IF EXISTS out_mail_date_time_idx;
	CREATE INDEX out_mail_date_time_idx
	ON out_mail
	(date_time);

	DROP INDEX IF EXISTS out_mail_to_user_idx;
	CREATE INDEX out_mail_to_user_idx
	ON out_mail
	(to_user_id);

	DROP INDEX IF EXISTS out_mail_reg_number_idx;
	CREATE INDEX out_mail_reg_number_idx
	ON out_mail
	(reg_number_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 01/12/2017 17:28:15 ******************
UPDATE views SET
			c='Holiday_Controller',
			f='get_list',
			t='HolidayList',
			section='Справочники',
			descr='Государственные праздники',
			limited=FALSE
		WHERE id='10010';
	
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10011',
		'OutMail_Controller',
		'get_list',
		'OutMailList',
		'Справочники',
		'Исходящие письма',
		FALSE
		);


-- ******************* update 01/12/2017 17:41:25 ******************
CREATE TABLE departments
		(id serial,name  varchar(200),CONSTRAINT departments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS departments_name_idx;
	CREATE UNIQUE INDEX departments_name_idx
	ON departments
	(lower(name));

		ALTER TABLE departments OWNER TO expert72;


-- ******************* update 01/12/2017 17:45:25 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10012',
		'Department_Controller',
		'get_list',
		'DepartmentList',
		'Справочники',
		'Отделы',
		FALSE
		);


-- ******************* update 01/12/2017 18:05:01 ******************
CREATE TABLE employes
		(id serial,name  varchar(200),user_id int REFERENCES users(id),CONSTRAINT employes_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS employes_name_idx;
	CREATE UNIQUE INDEX employes_name_idx
	ON employes
	(lower(name));

	DROP INDEX IF EXISTS employes_user_idx;
	CREATE UNIQUE INDEX employes_user_idx
	ON employes
	(user_id);

		ALTER TABLE employes OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;


-- ******************* update 02/12/2017 06:37:30 ******************
INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10013',
		'Employee_Controller',
		'get_list',
		'EmployeeList',
		'Справочники',
		'Сотрудники',
		FALSE
		);


-- ******************* update 02/12/2017 06:38:35 ******************
ALTER TABLE employees ADD COLUMN department_id int REFERENCES departments(id);
		
	DROP INDEX IF EXISTS employes_name_idx;
	CREATE UNIQUE INDEX employes_name_idx
	ON employees
	(lower(name));

	DROP INDEX IF EXISTS employes_user_idx;
	CREATE UNIQUE INDEX employes_user_idx
	ON employees
	(user_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION departments_ref(departments)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION departments_ref(departments) OWNER TO ;


-- ******************* update 02/12/2017 07:56:13 ******************
CREATE TABLE out_mail
		(id serial,date_time timestampTZ,employee_id int REFERENCES employees(id),to_user_id int REFERENCES users(id),to_addr  varchar(50),to_name  varchar(255),application_id int REFERENCES applications(id),subject text,reg_number  varchar(15),content text,CONSTRAINT out_mail_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS out_mail_date_time_idx;
	CREATE INDEX out_mail_date_time_idx
	ON out_mail
	(date_time);

	DROP INDEX IF EXISTS out_mail_application_idx;
	CREATE INDEX out_mail_application_idx
	ON out_mail
	(application_id);

	DROP INDEX IF EXISTS out_mail_to_user_idx;
	CREATE INDEX out_mail_to_user_idx
	ON out_mail
	(to_user_id);

	DROP INDEX IF EXISTS out_mail_reg_number_idx;
	CREATE INDEX out_mail_reg_number_idx
	ON out_mail
	(reg_number_id);

		ALTER TABLE out_mail OWNER TO expert72;
	
		CREATE TABLE out_mail_attachments
		(id serial,out_mail_id int REFERENCES out_mail(id),file_name  varchar(255),CONSTRAINT out_mail_attachments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS out_mail_attachments_mail_id_idx;
	CREATE INDEX out_mail_attachments_mail_id_idx
	ON out_mail_attachments
	(out_mail_id);

		ALTER TABLE out_mail_attachments OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION employees_ref(employees)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION employees_ref(employees) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION out_mail_ref(out_mail)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.to_addr
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION out_mail_ref(out_mail) OWNER TO ;


-- ******************* update 02/12/2017 07:57:17 ******************
CREATE TABLE in_mail
		(id serial,date_time timestampTZ,from_addr  varchar(50),from_name  varchar(255),reply_addr  varchar(50),reply_name  varchar(255),subject text,reg_number  varchar(15),content text,CONSTRAINT in_mail_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS in_mail_date_time_idx;
	CREATE INDEX in_mail_date_time_idx
	ON in_mail
	(date_time);

	DROP INDEX IF EXISTS in_mail_from_addr_idx;
	CREATE INDEX in_mail_from_addr_idx
	ON in_mail
	(lower(from_addr));

	DROP INDEX IF EXISTS in_mail_from_name_idx;
	CREATE INDEX in_mail_from_name_idx
	ON in_mail
	(lower(from_name));

		ALTER TABLE in_mail OWNER TO expert72;
	
		CREATE TABLE in_mail_attachments
		(id serial,in_mail_id int REFERENCES out_mail(id),file_name  varchar(255),CONSTRAINT in_mail_attachments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS in_mail_attachments_mail_id_idx;
	CREATE INDEX in_mail_attachments_mail_id_idx
	ON in_mail_attachments
	(in_mail_id);

		ALTER TABLE in_mail_attachments OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION out_mail_ref(out_mail)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.to_addr
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION out_mail_ref(out_mail) OWNER TO ;


-- ******************* update 02/12/2017 07:58:47 ******************
CREATE TABLE chat_messages
		(id serial,date_time timestampTZ,employee_id int REFERENCES employees(id),to_employee_id int REFERENCES employees(id),out_mail_id int REFERENCES out_mail(id),in_mail_id int REFERENCES in_mail(id),subject text,content text,parent_chat_message_id int REFERENCES chat_messages(id),CONSTRAINT chat_messages_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS chat_messages_period_idx;
	CREATE INDEX chat_messages_period_idx
	ON chat_messages
	(date_time);

	DROP INDEX IF EXISTS chat_messages_to_employee_idx;
	CREATE INDEX chat_messages_to_employee_idx
	ON chat_messages
	(to_employee_id);

		ALTER TABLE chat_messages OWNER TO expert72;
	
		CREATE TABLE chat_message_attachments
		(id serial,chat_message_id int REFERENCES chat_message(id),file_name  varchar(255),CONSTRAINT chat_message_attachments_pkey PRIMARY KEY (id));
		
	DROP INDEX IF EXISTS chat_message_attachments_message_idx;
	CREATE INDEX chat_message_attachments_message_idx
	ON chat_message_attachments
	(chat_message_id);

		ALTER TABLE chat_message_attachments OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION employees_ref(employees)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION employees_ref(employees) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION employees_ref(employees)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION employees_ref(employees) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION out_mail_ref(out_mail)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.to_addr
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION out_mail_ref(out_mail) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION in_mail_ref(in_mail)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.from_addr
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION in_mail_ref(in_mail) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION chat_messages_ref(chat_messages)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.subject
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION chat_messages_ref(chat_messages) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION chat_message_ref(chat_message)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				    
				),	
			'descr',$1.
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION chat_message_ref(chat_message) OWNER TO ;


-- ******************* update 02/12/2017 08:33:16 ******************
CREATE TABLE out_mail_attachments
		(file_id  varchar(36),out_mail_id int REFERENCES out_mail(id),file_name  varchar(255),file_size int,CONSTRAINT out_mail_attachments_pkey PRIMARY KEY (file_id));
		
	DROP INDEX IF EXISTS out_mail_attachments_mail_id_idx;
	CREATE INDEX out_mail_attachments_mail_id_idx
	ON out_mail_attachments
	(out_mail_id);

		ALTER TABLE out_mail_attachments OWNER TO expert72;
	
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION out_mail_ref(out_mail)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.to_addr
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION out_mail_ref(out_mail) OWNER TO ;


-- ******************* update 04/12/2017 12:46:05 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_out_mail_types_val(out_mail_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='to_client'::out_mail_types AND $2='ru'::locales THEN 'Клиенту'
			WHEN $1='email'::out_mail_types AND $2='ru'::locales THEN 'По электронной почте'
			WHEN $1='ordinary'::out_mail_types AND $2='ru'::locales THEN 'Обычное'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_out_mail_types_val(out_mail_types,locales) OWNER TO expert72;		
		
			CREATE TYPE out_mail_types AS ENUM (
			
				'to_client'			
			,
				'email'			
			,
				'ordinary'			
						
			);
			ALTER TYPE out_mail_types OWNER TO expert72;
			
		ALTER TABLE out_mail ADD COLUMN out_mail_type out_mail_types NOT NULL;
		
	DROP INDEX IF EXISTS out_mail_date_time_idx;
	CREATE INDEX out_mail_date_time_idx
	ON out_mail
	(date_time);

	DROP INDEX IF EXISTS out_mail_application_idx;
	CREATE INDEX out_mail_application_idx
	ON out_mail
	(application_id);

	DROP INDEX IF EXISTS out_mail_to_user_idx;
	CREATE INDEX out_mail_to_user_idx
	ON out_mail
	(to_user_id);

	DROP INDEX IF EXISTS out_mail_reg_number_idx;
	CREATE INDEX out_mail_reg_number_idx
	ON out_mail
	(reg_number_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION employees_ref(employees)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION employees_ref(employees) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 04/12/2017 15:16:29 ******************
ALTER TABLE out_mail ,ADD COLUMN sent bool;
		
	DROP INDEX IF EXISTS out_mail_date_time_idx;
	CREATE INDEX out_mail_date_time_idx
	ON out_mail
	(date_time);

	DROP INDEX IF EXISTS out_mail_application_idx;
	CREATE INDEX out_mail_application_idx
	ON out_mail
	(application_id);

	DROP INDEX IF EXISTS out_mail_to_user_idx;
	CREATE INDEX out_mail_to_user_idx
	ON out_mail
	(to_user_id);

	DROP INDEX IF EXISTS out_mail_reg_number_idx;
	CREATE INDEX out_mail_reg_number_idx
	ON out_mail
	(reg_number_id);

			
				
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
				
				
			
			
			
			
			
			
			
			
			
			
				
			
		
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
		
			
			
			
			
			
		
			
			
		
			
			
			
		
			
			
		
			
		
			
			
			
			
			
			
		
			
			
			
		
			
			
			
		
			
			
		
			
			
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
		
			
			
			
			
			
			
		
			
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
			
		
			
				
			
			
			
			
			
			
			
			
			
			
			
			
		
			
			
		
			
				
			
			
			
		
			
			
			
			
		
			
			
			
		
--Refrerece type
CREATE OR REPLACE FUNCTION employees_ref(employees)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION employees_ref(employees) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION users_ref(users)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION users_ref(users) OWNER TO ;	
	
--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT json_build_object(
		'RefType',
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.constr_name
		)
	);
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;


-- ******************* update 07/12/2017 10:28:26 ******************
/* function */
		CREATE OR REPLACE FUNCTION enum_email_types_val(email_types,locales)
		RETURNS text AS $$
			SELECT
			CASE
			WHEN $1='new_account'::email_types AND $2='ru'::locales THEN 'Новый акаунт'
			WHEN $1='reset_pwd'::email_types AND $2='ru'::locales THEN 'Установка пароля'
			WHEN $1='user_email_conf'::email_types AND $2='ru'::locales THEN 'Подтверждение пароля'
			WHEN $1='out_mail'::email_types AND $2='ru'::locales THEN 'Исходящее письмо'
			ELSE ''
			END;		
		$$ LANGUAGE sql;	
		ALTER FUNCTION enum_email_types_val(email_types,locales) OWNER TO expert72;		
		
					ALTER TYPE email_types ADD VALUE 'out_mail';