-- Function: user_certificates_lk_process()

-- DROP FUNCTION user_certificates_lk_process();

CREATE OR REPLACE FUNCTION user_certificates_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO user_certificates(
				    fingerprint, date_time, date_time_from, date_time_to, subject_cert, 
				    issuer_cert)
			    VALUES (NEW.fingerprint, NEW.date_time, NEW.date_time_from, NEW.date_time_to, NEW.subject_cert, 
				    NEW.issuer_cert)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE user_certificates
			SET
				fingerprint = NEW.fingerprint,
				date_time = NEW.date_time,
				date_time_from = NEW.date_time_from,
				date_time_to = NEW.date_time_to,
				subject_cert = NEW.subject_cert, 
				issuer_cert = NEW.issuer_cert
			WHERE
				fingerprint = NEW.fingerprint AND date_time_from=NEW.date_time_from;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM user_certificates
			WHERE
				fingerprint = OLD.fingerprint AND date_time_from=OLD.date_time_from;
				    
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
ALTER FUNCTION user_certificates_lk_process() OWNER TO ;

