-- VIEW: doc_flow_out_client_dialog

DROP VIEW doc_flow_out_client_dialog;

CREATE OR REPLACE VIEW doc_flow_out_client_dialog AS
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
		files.contract_file AS contract_files
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	LEFT JOIN (
		SELECT
		out_f.doc_flow_out_client_id,
		app_f.file_path,
		json_build_array(
			json_build_object(
				'id',app_f.file_id,
				'name',app_f.file_name,
				'size',app_f.file_size,
				'file_signed',app_f.file_signed
			)
		) AS contract_file
		FROM doc_flow_out_client_document_files AS out_f
		LEFT JOIN application_document_files AS app_f ON app_f.file_id=out_f.file_id	
	) AS files ON files.doc_flow_out_client_id=t.id AND files.file_path='Контракт'
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_out_client_dialog OWNER TO ;
