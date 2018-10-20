-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',
				(SELECT
					json_agg(files.files)
				FROM
				(SELECT					
					jsonb_build_object(
						'file_id',att.file_id,
						'file_name',att.file_name,
						'file_size',att.file_size,
						'file_signed',att.file_signed,
						'file_uploaded','true',
						'file_path',att.file_path,
						'signatures',sign.signatures,
						'file_signed_by_client',app_f.file_signed_by_client
					) AS files
				FROM doc_flow_attachments AS att
				LEFT JOIN application_document_files AS app_f ON app_f.file_id=att.file_id
				LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
				LEFT JOIN (
					SELECT
						sign_t.file_id,
						jsonb_agg(sign_t.signatures) AS signatures
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
					) AS sign_t
					GROUP BY sign_t.file_id
				) AS sign ON sign.file_id=att.file_id													
				WHERE att.doc_type='doc_flow_out' AND att.doc_id=t.doc_flow_out_id
				GROUP BY att.file_path,att.file_name,att.file_id,sign.signatures,app_f.file_signed_by_client
				ORDER BY att.file_path,att.file_name
				) AS files
				)
				/*(SELECT
					jsonb_agg(s.attachment||
						jsonb_build_object('file_signed_by_client',app_f.file_signed_by_client)||
						jsonb_build_object('signatures',sign.signatures)
					)
				FROM (
					SELECT jsonb_array_elements(t.files) AS attachment
					--ORDER BY t.files->>'file_path'					
				) AS s
				LEFT JOIN
					application_document_files AS app_f ON app_f.file_id=s.attachment->>'file_id'
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
				) AS sign ON sign.file_id=s.attachment->>'file_id'				
				)
				*/
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO ;
