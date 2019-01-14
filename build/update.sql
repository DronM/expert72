
-- ******************* update 09/01/2019 09:11:35 ******************

		ALTER TABLE application_document_files ADD COLUMN information_list bool
			DEFAULT FALSE;
	

-- ******************* update 09/01/2019 09:18:22 ******************
﻿-- Function: information_list_regexp(filename text)

-- DROP FUNCTION information_list_regexp(filename text);

CREATE OR REPLACE FUNCTION information_list_regexp(filename text)
  RETURNS void AS
$$
	SELECT
		('^'||(SELECT f_name FROM file_name_explode(lower($1)) AS (f_name text,f_ext text))||' *- *ул *\.'||(SELECT f_ext FROM file_name_explode(lower($1)) AS (f_name text,f_ext text))||'$')
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION information_list_regexp(filename text) OWNER TO expert72;

-- ******************* update 09/01/2019 09:18:31 ******************
﻿-- Function: information_list_regexp(filename text)

-- DROP FUNCTION information_list_regexp(filename text);

CREATE OR REPLACE FUNCTION information_list_regexp(filename text)
  RETURNS text AS
$$
	SELECT
		('^'||(SELECT f_name FROM file_name_explode(lower($1)) AS (f_name text,f_ext text))||' *- *ул *\.'||(SELECT f_ext FROM file_name_explode(lower($1)) AS (f_name text,f_ext text))||'$')
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION information_list_regexp(filename text) OWNER TO expert72;

-- ******************* update 09/01/2019 09:29:30 ******************
-- Trigger: application_document_files_trigger on application_document_files

 DROP TRIGGER application_document_files_before_trigger ON application_document_files;

CREATE TRIGGER application_document_files_before_trigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON application_document_files
  FOR EACH ROW
  EXECUTE PROCEDURE application_document_files_process();


-- ******************* update 09/01/2019 09:31:38 ******************
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
ALTER FUNCTION application_document_files_process() OWNER TO expert72;

