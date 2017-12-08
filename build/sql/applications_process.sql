-- Function: applications_process()

-- DROP FUNCTION applications_process();

CREATE OR REPLACE FUNCTION applications_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN
		INSERT INTO application_state_history (application_id,state) VALUES (NEW.id,'filling');
		
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		DELETE FROM application_state_history WHERE application_id = OLD.id;
		
		RETURN OLD;
		
	ELSE 
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION applications_process() OWNER TO ;

