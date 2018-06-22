-- Function: doc_flow_in_client_process()

-- DROP FUNCTION doc_flow_in_client_process();

CREATE OR REPLACE FUNCTION doc_flow_in_client_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN		
		IF const_client_lk_val() OR const_debug_val() THEN
			--Если это достоверность одновременно с ПД - сделать не одновременно
			--это при возврате заявления без рассмотрения
			UPDATE applications AS app
			SET cost_eval_validity_simult = FALSE
			FROM (
				SELECT t.id
				FROM applications t
				WHERE t.id=NEW.application_id
				AND coalesce(t.cost_eval_validity,FALSE) AND coalesce(t.cost_eval_validity_simult,FALSE)
				AND NEW.doc_flow_type_id=(pdfn_doc_flow_types_app_resp_return()->'keys'->>'id')::int
			) AS base
			WHERE app.id=base.id;
		END IF;
		
		RETURN NEW;		
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM doc_flow_in_client_reg_numbers WHERE doc_flow_in_client_id=OLD.id;
		RETURN OLD;
		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_client_process() OWNER TO ;

