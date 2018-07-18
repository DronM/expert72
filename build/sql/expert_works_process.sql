-- Function: expert_works_process()

-- DROP FUNCTION expert_works_process();

CREATE OR REPLACE FUNCTION expert_works_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT'  OR TG_OP='UPDATE') ) THEN		

		--Письмо отделу по поводу изменений
		PERFORM expert_works_change_mail(NEW);
	
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN		
		PERFORM expert_works_change_mail(OLD);
	
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION expert_works_process() OWNER TO ;

