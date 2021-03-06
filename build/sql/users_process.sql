-- Function: users_process()

-- DROP FUNCTION users_process();

CREATE OR REPLACE FUNCTION users_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			PERFORM contacts_insert(NEW.id, 'users'::data_types,1,
				json_build_object(
					'name',NEW.name_full,
					'email',NEW.email,
					'tel',NEW.phone_cel
				),
				NULL
			);
		END IF;
						
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN		
		IF
		(NOT const_client_lk_val() OR const_debug_val())
		AND
		(OLD.name_full<>NEW.name_full) OR (OLD.email<>NEW.email) OR (OLD.phone_cel<>NEW.phone_cel)
		THEN
			DELETE FROM contacts WHERE parent_id=OLD.id AND parent_type='users'::data_types;
			PERFORM contacts_insert(NEW.id, 'users'::data_types, 1,
				json_build_object(
					'name',NEW.name_full,
					'email',NEW.email,
					'tel',NEW.phone_cel
				),
				NULL
			);
		END IF;				
		RETURN NEW;
	
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN		
		IF NEW.email IS NOT NULL AND NEW.email<>OLD.email THEN
			NEW.email_confirmed = FALSE;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION users_process() OWNER TO ;

