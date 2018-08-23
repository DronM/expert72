-- Function: file_verifications_process()

-- DROP FUNCTION file_verifications_process();

CREATE OR REPLACE FUNCTION file_verifications_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_signatures WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION file_verifications_process() OWNER TO expert72;

