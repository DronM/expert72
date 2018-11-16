-- Function: users_lk_process()

-- DROP FUNCTION users_lk_process();

CREATE OR REPLACE FUNCTION users_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO users(
				    id, name, role_id, pwd, phone_cel, time_zone_locale_id, email, 
				    locale_id, pers_data_proc_agreement, create_dt, email_confirmed, 
				    comment_text, banned, name_full, color_palette, reminders_to_email, 
				    cades_load_timeout, cades_chunk_size)
			    VALUES (NEW.id, NEW.name, NEW.role_id, NEW.pwd, NEW.phone_cel, NEW.time_zone_locale_id, NEW.email, 
				    NEW.locale_id, NEW.pers_data_proc_agreement, NEW.create_dt, NEW.email_confirmed, 
				    NEW.comment_text, NEW.banned, NEW.name_full, NEW.color_palette, NEW.reminders_to_email, 
				    NEW.cades_load_timeout, NEW.cades_chunk_size)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE users
			SET
				name = NEW.name,
				role_id = NEW.role_id,
				pwd = NEW.pwd,
				phone_cel = NEW.phone_cel,
				time_zone_locale_id = NEW.time_zone_locale_id,
				email = NEW.email, 
				locale_id = NEW.locale_id,
				pers_data_proc_agreement = NEW.pers_data_proc_agreement,
				create_dt = NEW.create_dt,
				email_confirmed = NEW.email_confirmed, 
				comment_text = NEW.comment_text,
				banned = NEW.banned,
				name_full = NEW.name_full,
				color_palette = NEW.color_palette,
				reminders_to_email = NEW.reminders_to_email, 
				cades_load_timeout = NEW.cades_load_timeout,
				cades_chunk_size = NEW.cades_chunk_size
			WHERE
				id = OLD.id;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM users
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
ALTER FUNCTION users_lk_process() OWNER TO ;

