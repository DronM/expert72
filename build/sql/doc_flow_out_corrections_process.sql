-- Function: doc_flow_out_corrections_process()

-- DROP FUNCTION doc_flow_out_corrections_process();

CREATE OR REPLACE FUNCTION doc_flow_out_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		IF const_client_lk_val() OR const_debug_val() THEN
		
			UPDATE doc_flow_in_client
			SET
				viewed = FALSE,
				viewed_dt = NULL
			WHERE doc_flow_out_id=NEW.doc_flow_out_id;
			
			IF NEW.is_new THEN
				INSERT INTO application_document_files
				(file_id,application_id,document_id,document_type,date_time,file_name,
				file_path,file_signed,file_size)
				SELECT
					at.file_id,
					out.to_application_id,0,'documents',at.file_date,at.file_name,
					at.file_path,at.file_signed,at.file_size
				
				FROM doc_flow_attachments AS at
				LEFT JOIN doc_flow_out out ON out.id=at.doc_id
				WHERE
					at.file_id=NEW.file_id
					AND at.file_path!='Исходящие'
				;			
			ELSE
				DELETE FROM application_document_files WHERE file_id = NEW.file_id;
			END IF;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_corrections_process() OWNER TO ;
