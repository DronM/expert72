-- Function: application_corrections_process()

-- DROP FUNCTION application_corrections_process();

CREATE OR REPLACE FUNCTION application_corrections_process()
  RETURNS trigger AS
$BODY$
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN
			--client server, update application state
			INSERT INTO public.application_processes(
				    application_id, date_time, state, user_id, end_date_time, doc_flow_examination_id)
			    VALUES (
			    NEW.application_id,
			    NEW.date_time,
			    'correcting'::application_states,
			    NEW.user_id,
			    NEW.end_date_time,
			    NEW.doc_flow_examination_id
			    );			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_corrections_process() OWNER TO ;

