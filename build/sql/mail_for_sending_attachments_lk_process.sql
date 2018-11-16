-- Function: mail_for_sending_attachments_lk_process()

-- DROP FUNCTION mail_for_sending_attachments_lk_process();

CREATE OR REPLACE FUNCTION mail_for_sending_attachments_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO mail_for_sending_attachments(
				    id, mail_for_sending_id, file_name)
			    VALUES (NEW.id, NEW.mail_for_sending_id, NEW.file_name)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE mail_for_sending_attachments
			SET
				mail_for_sending_id = NEW.mail_for_sending_id,
				file_name = NEW.file_name
			WHERE
				id = OLD.id;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM mail_for_sending_attachments
			WHERE
				id = OLD.id;
				    
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
ALTER FUNCTION mail_for_sending_attachments_lk_process() OWNER TO ;

