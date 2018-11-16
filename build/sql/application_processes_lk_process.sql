-- Function: application_processes_lk_process()

-- DROP FUNCTION application_processes_lk_process();

CREATE OR REPLACE FUNCTION application_processes_lk_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND (NOT const_client_lk_val() OR const_debug_val())) THEN		
		IF TG_OP='INSERT' THEN
			INSERT INTO application_processes(
				    application_id, date_time, state, user_id, end_date_time, doc_flow_examination_id)
			    VALUES (NEW.application_id, NEW.date_time, NEW.state, NEW.user_id, NEW.end_date_time, NEW.doc_flow_examination_id)
			ON CONFLICT DO NOTHING;
				    
			RETURN NEW;
		ELSIF TG_OP='UPDATE' THEN
			UPDATE application_processes
			SET
				state = NEW.state,
				user_id = NEW.user_id,
				end_date_time = NEW.end_date_time,
				doc_flow_examination_id = NEW.doc_flow_examination_id
			WHERE
				application_id = NEW.application_id AND date_time=NEW.date_time;
				    
			RETURN NEW;
		ELSIF TG_OP='DELETE' THEN
			DELETE FROM application_processes
			WHERE
				application_id = NEW.application_id AND date_time=NEW.date_time;
				    
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
ALTER FUNCTION application_processes_lk_process() OWNER TO ;

