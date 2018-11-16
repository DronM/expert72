-- Function: file_signatures_lk_process()

-- DROP FUNCTION file_signatures_lk_process();

CREATE OR REPLACE FUNCTION file_signatures_lk_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_fingerprint varchar(40);
	v_date_time_from timestamp with time zone;
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			SELECT
				ucert.fingerprint,
				ucert.date_time_from	
			INTO v_fingerprint,v_date_time_from
			FROM user_certificates_lk AS ucert
			WHERE ucert.id=NEW.user_certificate_id;
			
			INSERT INTO file_signatures(
				    file_id, user_certificate_id, sign_date_time, algorithm)
			    VALUES (
			    	NEW.file_id,
			    	(SELECT ucert.id FROM user_certificates ucert
			    	WHERE ucert.fingerprint=v_fingerprint AND ucert.date_time_from=v_date_time_from
			    	),
			    	NEW.sign_date_time,
			    	NEW.algorithm
			    );
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			SELECT
				ucert.fingerprint,
				ucert.date_time_from	
			INTO v_fingerprint,v_date_time_from
			FROM user_certificates_lk AS ucert
			WHERE ucert.id=NEW.user_certificate_id;
		
			UPDATE file_signatures
			SET
				file_id = NEW.file_id,
				user_certificate_id = (
					SELECT ucert.id FROM user_certificates ucert
				    	WHERE ucert.fingerprint=v_fingerprint AND ucert.date_time_from=v_date_time_from
			    	),
				sign_date_time = NEW.sign_date_time,
				algorithm = NEW.algorithm
			WHERE
				file_id = NEW.file_id;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM file_signatures
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
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION file_signatures_lk_process() OWNER TO ;

