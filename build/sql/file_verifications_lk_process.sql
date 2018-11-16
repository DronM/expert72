-- Function: file_verifications_lk_process()

-- DROP FUNCTION file_verifications_lk_process();

CREATE OR REPLACE FUNCTION file_verifications_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO file_verifications(
				    file_id, date_time, check_result, check_time, error_str, hash_gost94, 
			            user_id)
			    VALUES (NEW.file_id, NEW.date_time, NEW.check_result, NEW.check_time, NEW.error_str, NEW.hash_gost94, 
			            NEW.user_id)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE file_verifications
			SET
				date_time = NEW.date_time,
				check_result = NEW.check_result,
				check_time = NEW.check_time,
				error_str = NEW.error_str,
				hash_gost94 = NEW.hash_gost94, 
			        user_id = NEW.user_id
			WHERE
				file_id = NEW.file_id;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM file_verifications
			WHERE
				file_id = OLD.file_id;
				    
			RETURN OLD;
			
		END IF;	
					
	ELSIF TG_WHEN='AFTER' AND const_client_lk_val() THEN
		IF TG_OP='INSERT' OR TG_OP='UPDATE' THEN
			RETURN NEW;
		ELSE
			RETURN OLD;
		END IF;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN			
			DELETE FROM file_signatures_lk WHERE file_id = OLD.file_id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION file_verifications_lk_process() OWNER TO ;

