-- VIEW: application_document_files_list

--DROP VIEW application_document_files_list;

CREATE OR REPLACE VIEW application_document_files_list AS
	SELECT
		t.file_id,
		t.application_id,
		applications_ref(app) AS applications_ref,
		t.document_id,
		t.document_type,
		t.date_time,
		t.file_name,
		t.file_path,
		t.file_signed,
		t.file_size,
		t.deleted,
		t.deleted_dt,
		t.file_signed_by_client,
		t.information_list
		
	FROM application_document_files AS t
	LEFT JOIN applications AS app ON app.id=t.application_id
	ORDER BY t.application_id DESC,t.document_type,t.file_name
	;
	
ALTER VIEW application_document_files_list OWNER TO ;
