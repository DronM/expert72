-- Function: doc_flow_contract_ret_date(in_doc_flow_out_client_id int)

-- DROP FUNCTION doc_flow_contract_ret_date(in_doc_flow_out_client_id int);

CREATE OR REPLACE FUNCTION doc_flow_contract_ret_date(in_doc_flow_out_client_id int)
  RETURNS timestamp with time zone AS
$$
	SELECT
		--doc_f.file_id,
		max(sgn.sign_date_time) AS sign_date_time
	FROM doc_flow_out_client_document_files AS doc_f
	LEFT JOIN application_document_files AS app_f ON doc_f.file_id=app_f.file_id
	LEFT JOIN file_signatures AS sgn ON sgn.file_id=app_f.file_id
	WHERE doc_flow_out_client_id=in_doc_flow_out_client_id
		AND app_f.file_path=pdfn_application_doc_folders_contract()->>'descr'
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_contract_ret_date(in_doc_flow_out_client_id int) OWNER TO ;
