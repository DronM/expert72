-- Function: out_mail_process()

-- DROP FUNCTION out_mail_process();

CREATE OR REPLACE FUNCTION out_mail_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM out_mail_state_history WHERE out_mail_id = OLD.id;
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION out_mail_process() OWNER TO ;

