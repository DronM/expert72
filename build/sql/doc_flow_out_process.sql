-- Function: doc_flow_out_process()

-- DROP FUNCTION doc_flow_out_process();

CREATE OR REPLACE FUNCTION doc_flow_out_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN		
		IF NEW.to_contract_id IS NOT NULL THEN
			SELECT application_id INTO NEW.to_application_id FROM contracts WHERE id=NEW.to_contract_id;
		END IF;	
		
		RETURN NEW;
		
	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM doc_flow_out_processes WHERE doc_flow_out_id = OLD.id;
		DELETE FROM doc_flow_attachments WHERE doc_type='doc_flow_out' AND doc_id = OLD.id;
		
		RETURN OLD;		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_process() OWNER TO ;

