-- Function: doc_flow_out_process()

-- DROP FUNCTION doc_flow_out_process();

CREATE OR REPLACE FUNCTION doc_flow_out_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN		
	
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			IF NEW.to_contract_id IS NOT NULL AND NEW.to_application_id IS NULL THEN
				SELECT application_id INTO NEW.to_application_id FROM contracts WHERE id=NEW.to_contract_id;
			END IF;	

			IF NEW.doc_flow_in_id IS NULL AND NEW.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
			AND NEW.to_application_id IS NOT NULL THEN
				SELECT id
				INTO NEW.doc_flow_in_id
				FROM doc_flow_in
				WHERE from_application_id=NEW.to_application_id
				ORDER BY date_time DESC LIMIT 1;
			END IF;	
		END IF;		
		
		RETURN NEW;
		
	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			DELETE FROM doc_flow_out_processes WHERE doc_flow_out_id = OLD.id;
			DELETE FROM doc_flow_attachments WHERE doc_type='doc_flow_out' AND doc_id = OLD.id;
		END IF;	
		
		RETURN OLD;		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_process() OWNER TO ;

