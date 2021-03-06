-- VIEW: doc_flow_out_client_dialog_lk

--DROP VIEW doc_flow_out_client_dialog_lk;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog_lk AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.comment_text,
		t.content,
		applications_ref(applications) AS applications_ref,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in,
		t.doc_flow_out_client_type,
		
		CASE WHEN att.attachments IS NULL THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',att.attachments
				)
			)
		END
		AS attachment_files,
		
		CASE WHEN att_only_sigs.attachments IS NULL AND t.sent THEN NULL
		ELSE
			jsonb_build_array(
				jsonb_build_object(
					'files',
						CASE
							WHEN t.sent THEN '[]'::jsonb
							WHEN (doc_flow_out_client_files_for_signing(t.application_id)->'files')::text='null' THEN '[]'::jsonb
							ELSE doc_flow_out_client_files_for_signing(t.application_id)->'files'
						END
						||
						CASE WHEN att_only_sigs.attachments IS NULL THEN '[]'::jsonb ELSE att_only_sigs.attachments
						END
				)
			)
		END
		AS attachment_files_only_sigs
		
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	--(SELECT pdfn_application_doc_folders_contract()->>'descr')
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures_lk AS f_sig
			LEFT JOIN file_verifications_lk AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates_lk AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND folders.require_client_sig
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att_only_sigs ON att_only_sigs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
			files_t.doc_flow_out_client_id,
			jsonb_agg(files_t.attachments) AS attachments
		FROM
		(SELECT
			out_f.doc_flow_out_client_id,
			json_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,
				'signatures',sign.signatures,
				'file_signed_by_client',app_f.file_signed_by_client
			) AS attachments			
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id
		LEFT JOIN application_doc_folders AS folders ON folders.name=app_f.file_path
		LEFT JOIN (
			SELECT
				sign_t.file_id,
				json_agg(sign_t.signatures) AS signatures
			FROM
			(SELECT
				f_sig.file_id,
				json_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures_lk AS f_sig
			LEFT JOIN file_verifications_lk AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates_lk AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS sign_t
			GROUP BY sign_t.file_id
		) AS sign ON sign.file_id=app_f.file_id					
		WHERE app_f.document_id=0 AND coalesce(folders.require_client_sig,FALSE)=FALSE
		ORDER BY app_f.file_path,app_f.file_name
		) AS files_t
		GROUP BY files_t.doc_flow_out_client_id
	) AS att ON att.doc_flow_out_client_id=t.id
	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO ;
