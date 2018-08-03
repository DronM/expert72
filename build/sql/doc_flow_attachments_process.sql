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
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_attachments_process() OWNER TO ;
