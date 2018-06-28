-- Function: mail_for_sending_process()

-- DROP FUNCTION mail_for_sending_process();

CREATE OR REPLACE FUNCTION mail_for_sending_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN		
		IF NEW.from_addr IS NULL OR NEW.from_addr='' THEN
			SELECT
				const_outmail_data_val()->>'from_name'::text,
				const_outmail_data_val()->>'from_addr'::text
			INTO
				NEW.from_name,
				NEW.from_addr
			;
			NEW.reply_name = NEW.from_name;
			NEW.reply_addr = NEW.from_addr;
			NEW.sender_addr = NEW.from_addr;
		END IF;
			
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM mail_for_sending_attachments WHERE mail_for_sending_id = OLD.id;
		RETURN OLD;
		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION mail_for_sending_process() OWNER TO ;

