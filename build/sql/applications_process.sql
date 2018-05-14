-- Function: applications_process()

-- DROP FUNCTION applications_process();

CREATE OR REPLACE FUNCTION applications_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN
			DELETE FROM doc_flow_in_client WHERE application_id = OLD.id;
			DELETE FROM doc_flow_out_client WHERE application_id = OLD.id;
			DELETE FROM application_document_files WHERE application_id = OLD.id;
		END IF;
		IF NOT const_client_lk_val() OR const_debug_val() THEN
			DELETE FROM doc_flow_in WHERE from_application_id = OLD.id;
			DELETE FROM doc_flow_out WHERE to_application_id = OLD.id;
		
			DELETE FROM application_processes WHERE application_id = OLD.id;
			DELETE FROM contacts WHERE parent_type='application_applicants'::data_types and parent_id = OLD.id;
			DELETE FROM contacts WHERE parent_type='application_customers'::data_types and parent_id = OLD.id;
			DELETE FROM contacts WHERE parent_type='application_contractors'::data_types and parent_id = OLD.id;
		END IF;
			
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION applications_process() OWNER TO ;

