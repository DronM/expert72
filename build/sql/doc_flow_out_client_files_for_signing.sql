-- Function: doc_flow_out_client_files_for_signing(in_application_id int)

-- DROP FUNCTION doc_flow_out_client_files_for_signing(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_files_for_signing(in_application_id int)
  RETURNS jsonb AS
$$
	SELECT
		jsonb_build_object(
			'files',
			jsonb_agg(t.attachments)
		) AS attachment_files
	FROM (

		SELECT
			jsonb_build_object(
				'file_id',app_f.file_id,
				'file_name',app_f.file_name,
				'file_size',app_f.file_size,
				'file_signed',app_f.file_signed,
				'file_uploaded','true',
				'file_path',app_f.file_path,				
				'file_signed_by_client',app_f.file_signed_by_client,
				'signatures',sign.signatures				
			) AS attachments
		FROM application_document_files AS app_f
		LEFT JOIN application_doc_folders AS fld ON fld.name=app_f.file_path
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
		) AS sign ON sign.file_id=app_f.file_id			
		WHERE
			app_f.application_id = in_application_id AND app_f.document_type='documents'
			AND NOT coalesce(app_f.file_signed_by_client,FALSE)
			AND NOT coalesce(app_f.deleted,FALSE)
			AND fld.require_client_sig
	) AS t
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION doc_flow_out_client_files_for_signing(in_application_id int) OWNER TO ;
