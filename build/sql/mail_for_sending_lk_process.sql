-- Function: mail_for_sending_lk_process()

-- DROP FUNCTION mail_for_sending_lk_process();

CREATE OR REPLACE FUNCTION mail_for_sending_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO mail_for_sending(
				    id, date_time, from_addr, from_name, to_addr, to_name, reply_addr, 
			            reply_name, body, sender_addr, subject, sent, sent_date_time, 
			            email_type)
			    VALUES (NEW.id, NEW.date_time, NEW.from_addr, NEW.from_name, NEW.to_addr, NEW.to_name, NEW.reply_addr, 
			            NEW.reply_name, NEW.body, NEW.sender_addr, NEW.subject, NEW.sent, NEW.sent_date_time, 
			            NEW.email_type)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE mail_for_sending
			SET
				date_time = NEW.date_time,
				from_addr = NEW.from_addr,
				from_name = NEW.from_name,
				to_addr = NEW.to_addr,
				to_name = NEW.to_name,
				reply_addr = NEW.reply_addr, 
			        reply_name = NEW.reply_name,
			        body = NEW.body,
			        sender_addr = NEW.sender_addr,
			        subject = NEW.subject,
			        sent = NEW.sent,
			        sent_date_time = NEW.sent_date_time, 
			        email_type = NEW.email_type
			WHERE
				id = OLD.id;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM mail_for_sending
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
ALTER FUNCTION mail_for_sending_lk_process() OWNER TO ;

