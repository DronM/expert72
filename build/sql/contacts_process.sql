-- Function: contacts_process()

-- DROP FUNCTION contacts_process();

CREATE OR REPLACE FUNCTION contacts_process()
  RETURNS trigger AS
$BODY$
BEGIN

	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			NEW.contact =
					CASE WHEN NEW.firm_name IS NULL THEN '' ELSE NEW.firm_name||' ' END||
					CASE WHEN NEW.dep IS NULL THEN '' ELSE NEW.dep||' ' END||
					CASE WHEN NEW.post IS NULL THEN '' ELSE NEW.post||' ' END||
					CASE WHEN NEW.name IS NULL THEN '' ELSE NEW.name||' ' END||				
					CASE WHEN NEW.tel IS NULL THEN '' ELSE format_cel_phone(NEW.tel)||' ' END||
					CASE WHEN NEW.email IS NULL THEN '' ELSE '<'||NEW.email||'>' END				
			;
		END IF;
		RETURN NEW;
	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contacts_process() OWNER TO ;

