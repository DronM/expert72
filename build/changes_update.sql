


-- Table: public.user_certificates

-- DROP TABLE public.user_certificates;

CREATE TABLE public.user_certificates
(
  id serial,
  fingerprint character varying(40) NOT NULL,
  date_time timestamp with time zone NOT NULL,
  date_time_from timestamp with time zone NOT NULL,
  date_time_to timestamp with time zone NOT NULL,
  subject_cert jsonb,
  issuer_cert jsonb,
  employee_id integer,
  CONSTRAINT user_certificates_pkey PRIMARY KEY (id),
  CONSTRAINT user_certificates_employee_id_fkey FOREIGN KEY (employee_id)
      REFERENCES public.employees (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.user_certificates
  OWNER TO expert72;

-- Index: public.user_certificates_fingerprint_user_idx

-- DROP INDEX public.user_certificates_fingerprint_user_idx;

CREATE UNIQUE INDEX user_certificates_fingerprint_user_idx
  ON public.user_certificates
  USING btree
  (fingerprint COLLATE pg_catalog."default", date_time_from);

-- Table: public.file_signatures

-- DROP TABLE public.file_signatures;

CREATE TABLE public.file_signatures
(
  id serial,
  file_id character varying(36) NOT NULL,
  user_certificate_id integer,
  sign_date_time timestamp with time zone,
  algorithm text,
  CONSTRAINT file_signatures_pkey PRIMARY KEY (id),
  CONSTRAINT file_signatures_user_certificate_id_fkey FOREIGN KEY (user_certificate_id)
      REFERENCES public.user_certificates (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.file_signatures
  OWNER TO expert72;

-- Index: public.file_signatures_file_idx

-- DROP INDEX public.file_signatures_file_idx;

CREATE INDEX file_signatures_file_idx
  ON public.file_signatures
  USING btree
  (file_id COLLATE pg_catalog."default");

-- Function: file_verifications_process()

-- DROP FUNCTION file_verifications_process();

CREATE OR REPLACE FUNCTION file_verifications_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_signatures WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION file_verifications_process() OWNER TO expert72;

-- Table: public.file_verifications

-- DROP TABLE public.file_verifications;

CREATE TABLE public.file_verifications
(
  file_id character varying(36) NOT NULL,
  date_time timestamp with time zone,
  check_result boolean,
  check_time numeric(15,4),
  error_str text,
  hash_gost94 text,
  CONSTRAINT file_verifications_pkey PRIMARY KEY (file_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.file_verifications
  OWNER TO expert72;

-- Trigger: file_verifications_before_trigger on public.file_verifications

-- DROP TRIGGER file_verifications_before_trigger ON public.file_verifications;

CREATE TRIGGER file_verifications_before_trigger
  BEFORE DELETE
  ON public.file_verifications
  FOR EACH ROW
  EXECUTE PROCEDURE public.file_verifications_process();


-- Function: application_document_files_process()

-- DROP FUNCTION application_document_files_process();

CREATE OR REPLACE FUNCTION application_document_files_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_verifications WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_document_files_process() OWNER TO ;


ALTER TABLE public.application_doc_folders ADD COLUMN require_client_sig bool DEFAULT FALSE;
ALTER TABLE contracts ADD COLUMN contract_return_date_on_sig bool DEFAULT false;	

-- Trigger: doc_flow_attachments_after_trigger on doc_flow_attachments

-- DROP TRIGGER doc_flow_attachments_after_trigger ON doc_flow_attachments;

 CREATE TRIGGER doc_flow_attachments_after_trigger
  AFTER UPDATE
  ON doc_flow_attachments
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_attachments_process();
  
CREATE OR REPLACE FUNCTION public.application_doc_folders_ref(application_doc_folders)
  RETURNS json AS
$BODY$
	SELECT 
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',$1.name,
			'dataType','application_doc_folders'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.application_doc_folders_ref(application_doc_folders)
  OWNER TO expert72;

CREATE OR REPLACE FUNCTION public.pdfn_application_doc_folders_doc_flow_out()
  RETURNS json AS
$BODY$
	SELECT application_doc_folders_ref(application_doc_folders) FROM application_doc_folders WHERE id=3;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_application_doc_folders_doc_flow_out()
  OWNER TO expert72;

ALTER TABLE public.application_document_files ADD COLUMN file_signed_by_client boolean;


ALTER TYPE doc_flow_out_client_types ADD VALUE 'date_prolongate';

/* function */

CREATE OR REPLACE FUNCTION enum_doc_flow_out_client_types_val(doc_flow_out_client_types,locales)
RETURNS text AS $$
	SELECT
	CASE
	WHEN $1='app'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Заявление'
	WHEN $1='contr_resp'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Ответы на замечания по контракту'
	WHEN $1='contr_return'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Возврат контракта'
	WHEN $1='contr_other'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Прочее'
	WHEN $1='date_prolongate'::doc_flow_out_client_types AND $2='ru'::locales THEN 'Продление срока'
	ELSE ''
	END;		
$$ LANGUAGE sql;	
ALTER FUNCTION enum_doc_flow_out_client_types_val(doc_flow_out_client_types,locales) OWNER TO expert72;		
	
CREATE OR REPLACE FUNCTION public.pdfn_application_doc_folders_contract()
  RETURNS json AS
$BODY$
	SELECT application_doc_folders_ref(application_doc_folders) FROM application_doc_folders WHERE id=1;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_application_doc_folders_contract()
  OWNER TO expert72;
	
CREATE OR REPLACE FUNCTION public.pdfn_application_doc_folders_doc_flow_out()
  RETURNS json AS
$BODY$
	SELECT application_doc_folders_ref(application_doc_folders) FROM application_doc_folders WHERE id=3;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_application_doc_folders_doc_flow_out()
  OWNER TO expert72;

ALTER TABLE users ADD COLUMN cades_load_timeout int
	DEFAULT 60000,ADD COLUMN cades_chunk_size int
	DEFAULT 1048576;
	
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_verify_after_signing
		(name text, descr text, val bool,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_verify_after_signing OWNER TO expert72;
		INSERT INTO const_cades_verify_after_signing (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Проверять подпись после подписания'
			,'Нужно ли проверять подпись в КриптоПро плагин после создания'
			,FALSE
			,'Bool'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_verify_after_signing_val()
		RETURNS bool AS
		$BODY$
			SELECT val::bool AS val FROM const_cades_verify_after_signing LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_verify_after_signing_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_verify_after_signing_set_val(Bool)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_verify_after_signing SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_verify_after_signing_set_val(Bool) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_verify_after_signing_view AS
		SELECT
			'cades_verify_after_signing'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_verify_after_signing AS t
		;
		ALTER VIEW const_cades_verify_after_signing_view OWNER TO expert72;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_include_certificate
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_include_certificate OWNER TO expert72;
		INSERT INTO const_cades_include_certificate (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Порядок влючения сертификатов в подпись'
			,'0 - включать сертификаты кроме головного, 1 - включать все сертификаты, 2 - включать только сертификат подписанта'
			,1
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_include_certificate_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_cades_include_certificate LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_include_certificate_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_include_certificate_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_include_certificate SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_include_certificate_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_include_certificate_view AS
		SELECT
			'cades_include_certificate'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_include_certificate AS t
		;
		ALTER VIEW const_cades_include_certificate_view OWNER TO expert72;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_signature_type
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_signature_type OWNER TO expert72;
		INSERT INTO const_cades_signature_type (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Тип усовершенствованной подписи'
			,'1- Тип подписи CAdES BES, 0- Тип подписи по умолчанию (CAdES-X Long Type 1), 5- Тип подписи CAdES T, 93- Тип подписи CAdES-X Long Type 1'
			,1
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_signature_type_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_cades_signature_type LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_signature_type_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_signature_type_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_signature_type SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_signature_type_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_signature_type_view AS
		SELECT
			'cades_signature_type'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_signature_type AS t
		;
			
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_verify_after_signing
		(name text, descr text, val bool,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_verify_after_signing OWNER TO expert72;
		INSERT INTO const_cades_verify_after_signing (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Проверять подпись после подписания'
			,'Нужно ли проверять подпись в КриптоПро плагин после создания'
			,FALSE
			,'Bool'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_verify_after_signing_val()
		RETURNS bool AS
		$BODY$
			SELECT val::bool AS val FROM const_cades_verify_after_signing LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_verify_after_signing_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_verify_after_signing_set_val(Bool)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_verify_after_signing SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_verify_after_signing_set_val(Bool) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_verify_after_signing_view AS
		SELECT
			'cades_verify_after_signing'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_verify_after_signing AS t
		;
		ALTER VIEW const_cades_verify_after_signing_view OWNER TO expert72;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_include_certificate
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_include_certificate OWNER TO expert72;
		INSERT INTO const_cades_include_certificate (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Порядок влючения сертификатов в подпись'
			,'0 - включать сертификаты кроме головного, 1 - включать все сертификаты, 2 - включать только сертификат подписанта'
			,1
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_include_certificate_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_cades_include_certificate LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_include_certificate_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_include_certificate_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_include_certificate SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_include_certificate_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_include_certificate_view AS
		SELECT
			'cades_include_certificate'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_include_certificate AS t
		;
		ALTER VIEW const_cades_include_certificate_view OWNER TO expert72;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_signature_type
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_signature_type OWNER TO expert72;
		INSERT INTO const_cades_signature_type (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Тип усовершенствованной подписи'
			,'1- Тип подписи CAdES BES, 0- Тип подписи по умолчанию (CAdES-X Long Type 1), 5- Тип подписи CAdES T, 93- Тип подписи CAdES-X Long Type 1'
			,0
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_signature_type_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_cades_signature_type LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_signature_type_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_signature_type_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_signature_type SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_signature_type_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_signature_type_view AS
		SELECT
			'cades_signature_type'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_signature_type AS t
		;
		ALTER VIEW const_cades_signature_type_view OWNER TO expert72;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_hash_algorithm
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_hash_algorithm OWNER TO expert72;
		INSERT INTO const_cades_hash_algorithm (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Алгоритм хэширования'
			,'100 - Алгоритм ГОСТ Р 34.11-94, 101 - Алгоритм ГОСТ Р 34.10-2012 256 бит, 102 - Алгоритм ГОСТ Р 34.10-2012 512 бит'
			,100
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_hash_algorithm_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_cades_hash_algorithm LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_hash_algorithm_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_hash_algorithm_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_hash_algorithm SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_hash_algorithm_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_hash_algorithm_view AS
		SELECT
			'cades_hash_algorithm'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_hash_algorithm AS t
		;
		ALTER VIEW const_cades_hash_algorithm_view OWNER TO expert72;

		ALTER VIEW const_cades_signature_type_view OWNER TO expert72;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_cades_hash_algorithm
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_cades_hash_algorithm OWNER TO expert72;
		INSERT INTO const_cades_hash_algorithm (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'КриптоПро плагин: Алгоритм хэширования'
			,'100 - Алгоритм ГОСТ Р 34.11-94, 101 - Алгоритм ГОСТ Р 34.10-2012 256 бит, 102 - Алгоритм ГОСТ Р 34.10-2012 512 бит'
			,100
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_cades_hash_algorithm_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_cades_hash_algorithm LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cades_hash_algorithm_val() OWNER TO expert72;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cades_hash_algorithm_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cades_hash_algorithm SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cades_hash_algorithm_set_val(Int) OWNER TO expert72;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cades_hash_algorithm_view AS
		SELECT
			'cades_hash_algorithm'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cades_hash_algorithm AS t
		;
		ALTER VIEW const_cades_hash_algorithm_view OWNER TO expert72;


-- VIEW: user_view

DROP VIEW user_view;
CREATE OR REPLACE VIEW user_view AS
	SELECT
		u.*,
		tzl.name AS user_time_locale,
		employees_ref(emp) AS employees_ref,
		departments_ref(dep) AS departments_ref,
		(emp.id=dep.boss_employee_id) department_boss,
		
		CASE WHEN st.id IS NULL THEN pdfn_short_message_recipient_states_free()
		ELSE short_message_recipient_states_ref(st)
		END AS recipient_states_ref
	FROM users u
	LEFT JOIN time_zone_locales tzl ON tzl.id=u.time_zone_locale_id
	LEFT JOIN employees emp ON emp.user_id=u.id
	LEFT JOIN departments dep ON dep.id=emp.department_id
	LEFT JOIN short_message_recipient_current_states cur_st ON cur_st.recipient_id=emp.id
	LEFT JOIN short_message_recipient_states st ON st.id=cur_st.recipient_state_id
	;
	
ALTER VIEW user_view OWNER TO expert72;

-- View: user_view

--DROP VIEW user_profile;

CREATE OR REPLACE VIEW user_profile AS 
	SELECT
		u.id,
		u.name,
		u.name_full,
		u.email,
		u.phone_cel,
		u.color_palette,
		u.reminders_to_email,
		u.cades_chunk_size,
		u.cades_load_timeout
	FROM users u;

ALTER TABLE user_profile OWNER TO expert72;

ALTER TABLE public.employees ADD COLUMN snils varchar(11);
CREATE UNIQUE INDEX employees_snils_idx
  ON public.employees
  USING btree
  (snils);

DROP INDEX user_certificates_fingerprint_user_idx;
CREATE UNIQUE INDEX user_certificates_fingerprint_user_idx
  ON public.user_certificates
  USING btree
  (fingerprint,date_time_from);
  
CREATE OR REPLACE FUNCTION public.contracts_ref(contracts)
  RETURNS json AS
$BODY$
	SELECT
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Контракт №'||coalesce($1.expertise_result_number,coalesce($1.reg_number,$1.id::text))||coalesce(' от '||to_char($1.date_time,'DD/MM/YY'),''),
			'dataType','contracts'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.contracts_ref(contracts)
  OWNER TO expert72;
  


--****************************************
doc_flow_out_dialog
doc_flow_attachments_process()
  contracts_list()
  doc_flow_in_dialog()
contracts_process()
contracts_dialog()
doc_flow_out_dialog()
applications_dialog()
doc_flow_contract_ret_date(in_doc_flow_out_client_id int)

1;"Договорные документы/Контракт";TRUE
2;"Заключение";FALSE
3;"Исходящие";FALSE
100;"Договорные документы/Акт выполненных работ";TRUE
101;"Договорные документы/Счет";FALSE

--****************************************



