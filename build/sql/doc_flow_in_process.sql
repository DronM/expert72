-- Function: doc_flow_in_process()

-- DROP FUNCTION doc_flow_in_process();

CREATE OR REPLACE FUNCTION doc_flow_in_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF
			(const_client_lk_val() OR const_debug_val())
			AND NEW.reg_number IS NULL
			AND (
				--заявление || ответы на замечания
				NEW.doc_flow_type_id=1 OR NEW.doc_flow_type_id=3
			)
		THEN
			--назначим номер
			NEW.reg_number = doc_flow_in_next_num(NEW.doc_flow_type_id);
		END IF;
		
		RETURN NEW;

	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM doc_flow_in_processes WHERE doc_flow_in_id = OLD.id;
		DELETE FROM doc_flow_out WHERE doc_flow_in_id = OLD.id;
		DELETE FROM doc_flow_attachments WHERE doc_type='doc_flow_in' AND doc_id = OLD.id;
				
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_process() OWNER TO ;

