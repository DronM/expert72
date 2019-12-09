-- VIEW: doc_flow_in_dialog

--DROP VIEW doc_flow_in_dialog;

CREATE OR REPLACE VIEW doc_flow_in_dialog AS
	SELECT
		doc_flow_in.*,
		clients_ref(clients) AS from_clients_ref,
		users_ref(users) AS from_users_ref,
		applications_ref(applications) AS from_applications_ref,
		doc_flow_out_ref(doc_flow_out) AS doc_flow_out_ref,
		
		CASE
			WHEN doc_flow_in.from_doc_flow_out_client_id IS NOT NULL THEN
				-- от исходящего клиентского
				json_build_array(
					json_build_object(
						'files',
						(SELECT
							json_agg(files_t.attachments) AS attachments
						FROM
							(SELECT
								t.doc_flow_out_client_id,
								json_build_object(
									'file_id',app_f.file_id,
									'file_name',app_f.file_name,
									'file_size',app_f.file_size,
									'file_signed',app_f.file_signed,
									'file_uploaded','true',
									'file_path',app_f.file_path,
									'is_switched',(clorg_f.new_file_id IS NOT NULL)
									,'signatures',
									(SELECT
										json_agg(sub.signatures) AS signatures
									FROM (
										SELECT 
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
										WHERE f_sig.file_id=t.file_id
										ORDER BY f_sig.sign_date_time
									) AS sub
									)
								) AS attachments
							FROM doc_flow_out_client_document_files AS t
							LEFT JOIN application_document_files AS app_f ON app_f.file_id = t.file_id
							LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
							LEFT JOIN doc_flow_out_client_original_files AS clorg_f ON clorg_f.doc_flow_out_client_id=t.doc_flow_out_client_id AND clorg_f.new_file_id=t.file_id
							WHERE
								coalesce(app_f.deleted,FALSE)=FALSE
								AND t.doc_flow_out_client_id=doc_flow_in.from_doc_flow_out_client_id
							ORDER BY app_f.file_path,app_f.file_name
							) AS files_t
						)
					)
				)
			ELSE
				json_build_array(
					json_build_object(
						'files',
						(SELECT
							json_agg(
								json_build_object(
									'file_id',t.file_id,
									'file_name',t.file_name,
									'file_size',t.file_size,
									'file_signed',t.file_signed,
									'file_uploaded','true'
								)
							) AS attachments			
						FROM doc_flow_attachments AS t
						WHERE t.doc_type='doc_flow_in'::data_types AND t.doc_id=doc_flow_in.id
						)		
						
					)
				)
		END files,
		
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		employees_ref(employees) AS employees_ref,
		
		CASE
			WHEN recipient->>'dataType'='departments' THEN departments_ref(departments)
			WHEN recipient->>'dataType'='employees' THEN employees_ref(tp_emp)
			ELSE NULL
		END AS recipients_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		doc_flow_in_processes_chain(doc_flow_in.id) AS doc_flow_in_processes_chain
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN users ON users.id=doc_flow_in.from_user_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN doc_flow_out ON doc_flow_out.id=doc_flow_in.doc_flow_out_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_in.employee_id
	LEFT JOIN departments ON departments.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='departments'
	LEFT JOIN employees AS tp_emp ON tp_emp.id = (recipient->'keys'->>'id')::int AND recipient->>'dataType'='employees'
	
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_in_dialog OWNER TO expert72;
