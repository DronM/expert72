-- Function: user_email_confirmations_lk_process()

-- DROP FUNCTION user_email_confirmations_lk_process();

CREATE OR REPLACE FUNCTION user_email_confirmations_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO user_email_confirmations(
				    key, user_id, dt, confirmed)
			    VALUES (NEW.key, NEW.user_id, NEW.dt, NEW.confirmed)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE user_email_confirmations
			SET
				user_id = NEW.user_id,
				dt = NEW.dt,
				confirmed = NEW.confirmed
			WHERE
				key = OLD.key;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM user_email_confirmations
			WHERE
				key = OLD.key;
				    
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
ALTER FUNCTION user_email_confirmations_lk_process() OWNER TO ;

