-- Function: application_document_files_process()

-- DROP FUNCTION application_document_files_process();

CREATE OR REPLACE FUNCTION application_document_files_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN			
		NEW.information_list = lower(NEW.file_name) ~ (' *- *ул *\.\D{3}$');
	
		RETURN NEW;	
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF NOT const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_verifications WHERE file_id = OLD.file_id;
		END IF;
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_verifications_lk WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;	
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_document_files_process() OWNER TO ;

