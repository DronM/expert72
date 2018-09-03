-- ******************* update 23/08/2018 16:35:04 ******************
-- VIEW: doc_flow_out_dialog

DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'id',adf.file_id,
									'owner',NULL,
									'create_dt',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'id',f_sig.signature_file_id,
						'owner',u_certs.subject_cert,
						'create_dt',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 23/08/2018 16:35:54 ******************
-- VIEW: doc_flow_out_dialog

DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'id',t.file_id,
									'owner',NULL,
									'create_dt',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'id',f_sig.signature_file_id,
						'owner',u_certs.subject_cert,
						'create_dt',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 27/08/2018 08:35:11 ******************

		ALTER TABLE file_verifications ADD COLUMN hash_gost94 text;
		
-- ******************* update 27/08/2018 08:48:19 ******************
DROP TABLE file_signatures;
		CREATE TABLE file_signatures
		(file_id  varchar(36),user_certificate_id int REFERENCES user_certificates(id),sign_date_time timestampTZ,CONSTRAINT file_signatures_pkey PRIMARY KEY (file_id,user_certificate_id)
		);
		ALTER TABLE file_signatures OWNER TO expert72;


-- ******************* update 27/08/2018 08:49:13 ******************
DROP VIEW doc_flow_out_dialog;
DROP TABLE file_signatures;

		CREATE TABLE file_signatures
		(file_id  varchar(36),user_certificate_id int REFERENCES user_certificates(id),sign_date_time timestampTZ,CONSTRAINT file_signatures_pkey PRIMARY KEY (file_id,user_certificate_id)
		);
		ALTER TABLE file_signatures OWNER TO expert72;


-- ******************* update 27/08/2018 08:49:51 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'create_dt',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'create_dt',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 28/08/2018 13:01:24 ******************

		CREATE TABLE file_signatures
		(signature_id  varchar(36),file_id  varchar(36) NOT NULL,user_certificate_id int REFERENCES user_certificates(id),sign_date_time timestampTZ,CONSTRAINT file_signatures_pkey PRIMARY KEY (signature_id)
		);
	CREATE UNIQUE INDEX file_signatures_file_idx
	ON file_signatures(file_id);
		ALTER TABLE file_signatures OWNER TO expert72;


-- ******************* update 28/08/2018 13:06:04 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'create_dt',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'create_dt',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 28/08/2018 14:13:34 ******************
DROP VIEW doc_flow_out_dialog;
DROP TABLE file_signatures;
		CREATE TABLE file_signatures
		(id serial,file_id  varchar(36) NOT NULL,user_certificate_id int REFERENCES user_certificates(id),sign_date_time timestampTZ,CONSTRAINT file_signatures_pkey PRIMARY KEY (id)
		);
	DROP INDEX IF EXISTS file_signatures_file_idx;
	CREATE UNIQUE INDEX file_signatures_file_idx
	ON file_signatures(file_id);
		ALTER TABLE file_signatures OWNER TO expert72;


-- ******************* update 28/08/2018 14:13:55 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',sign.signatures
					/*
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'create_dt',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END
					*/					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'create_dt',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 28/08/2018 14:19:24 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',sign.signatures
					/*
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'create_dt',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END
					*/					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'create_dt',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 28/08/2018 16:29:35 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',sign.signatures
					/*
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'sign_date_time',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END
					*/					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 29/08/2018 11:57:15 ******************
-- Function: doc_flow_attachments_process()

-- DROP FUNCTION contracts_process();

CREATE OR REPLACE FUNCTION doc_flow_attachments_process()
  RETURNS trigger AS
$BODY$
DECLARE
	FOLDER_OUT text;
	FOLDER_DOCS text;
	FOLDER_RES text;
	v_application_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='UPDATE' ) THEN
		IF const_client_lk_val() OR const_debug_val() AND NEW.doc_type='doc_flow_out' THEN
			FOLDER_OUT = 'Исходящие';
			FOLDER_DOCS = 'Договорные документы';
			FOLDER_RES = 'Заключение';
		
			SELECT t.to_application_id INTO v_application_id FROM doc_flow_out t WHERE t.id=NEW.doc_id;
			
			IF v_application_id IS NOT NULL THEN
				IF (OLD.file_path=FOLDER_DOCS OR OLD.file_path=FOLDER_RES) AND NEW.file_path=FOLDER_OUT THEN
					DELETE FROM application_document_files WHERE file_id=NEW.file_id;
				
				ELSIF (NEW.file_path=FOLDER_DOCS OR NEW.file_path=FOLDER_RES) AND OLD.file_path=FOLDER_OUT THEN
					INSERT INTO application_document_files
					(
					file_id,
					application_id,
					document_id,
					document_type,
					date_time,
					file_name,
					file_path,
					file_signed,
					file_size
					)
					VALUES (
					NEW.file_id,
					v_application_id,
					0,
					'documents',
					NEW.file_date,
					NEW.file_name,
					NEW.file_path,
					NEW.file_signed,
					NEW.file_size
					);
				ELSIF (OLD.file_path=FOLDER_DOCS OR OLD.file_path=FOLDER_RES) AND (NEW.file_path=FOLDER_DOCS OR NEW.file_path=FOLDER_RES) THEN
					UPDATE application_document_files
						SET file_path=NEW.file_path
					WHERE file_id=NEW.file_id;
					
				END IF;
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_verifications WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_attachments_process() OWNER TO expert72;

-- ******************* update 29/08/2018 11:58:50 ******************
-- Trigger: doc_flow_attachments_after_trigger on doc_flow_attachments

 DROP TRIGGER doc_flow_attachments_after ON doc_flow_attachments;

 CREATE TRIGGER doc_flow_attachments_after_trigger
  AFTER UPDATE OR DELETE
  ON doc_flow_attachments
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_attachments_process();

-- ******************* update 29/08/2018 16:09:18 ******************
-- Trigger: doc_flow_attachments_after_trigger on doc_flow_attachments

 DROP TRIGGER doc_flow_attachments_after_trigger ON doc_flow_attachments;

 CREATE TRIGGER doc_flow_attachments_after_trigger
  AFTER UPDATE
  ON doc_flow_attachments
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_attachments_process();
  

-- ******************* update 29/08/2018 16:10:15 ******************
-- Trigger: doc_flow_attachments_before_trigger on doc_flow_attachments

-- DROP TRIGGER doc_flow_attachments_before_trigger ON doc_flow_attachments;

 CREATE TRIGGER doc_flow_attachments_before_trigger
  BEFORE DELETE
  ON doc_flow_attachments
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_attachments_process();
  

-- ******************* update 29/08/2018 17:03:14 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',sign.signatures
					/*
					CASE
						WHEN sign.signatures IS NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'sign_date_time',NULL,
									'check_result',NULL,
									'check_time',NULL,
									'error_str',NULL
								)
							)
						ELSE sign.signatures
					END
					*/					
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 30/08/2018 10:57:51 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					--'signatures',sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'owner',NULL,
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'check_time',NULL,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 30/08/2018 11:00:13 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					--'signatures',sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 30/08/2018 11:01:16 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					--'signatures',sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END AS signatures
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;

-- ******************* update 30/08/2018 11:01:33 ******************
-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain,
		
		contracts.expertise_result,
		expertise_reject_types_ref(expertise_reject_types) AS expertise_reject_types_ref,
		expertise_reject_types.id AS expertise_reject_type_id
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN expertise_reject_types ON expertise_reject_types.id=contracts.expertise_reject_type_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				f_sig.file_id,
				jsonb_agg(
					jsonb_build_object(
						'owner',u_certs.subject_cert,
						'cert_from',u_certs.date_time_from,
						'cert_to',u_certs.date_time_to,
						'sign_date_time',f_sig.sign_date_time,
						'check_result',ver.check_result,
						'check_time',ver.check_time,
						'error_str',ver.error_str
					)
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			GROUP BY f_sig.file_id
		) AS sign ON sign.file_id=t.file_id			
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO expert72;