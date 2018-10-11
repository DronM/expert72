-- VIEW: doc_flow_out_dialog

--DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		--****************************
		folders.files AS files,
		---***************************
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
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	LEFT JOIN
		(
		SELECT
			doc_att.doc_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		(SELECT
			att.doc_id,
			att.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',att.file_id,
					'file_name',att.file_name,
					'file_size',att.file_size,
					'file_signed',att.file_signed,
					'file_uploaded','true',
					'file_path',att.file_path,
					'date_time',f_ver.date_time,
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
					END,
					'file_signed_by_client',FALSE,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM doc_flow_attachments att
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=att.file_path
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=att.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
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
		WHERE att.doc_type='doc_flow_out'
		GROUP BY att.doc_id,app_fd.id,att.file_path
		ORDER BY app_fd.id
		)  AS doc_att
		
		GROUP BY doc_att.doc_id
	) AS folders ON folders.doc_id=doc_flow_out.id
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO ;
