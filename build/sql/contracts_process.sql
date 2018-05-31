-- Function: contracts_process()

-- DROP FUNCTION contracts_process();

CREATE OR REPLACE FUNCTION contracts_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT')
		OR (TG_OP='UPDATE' AND NEW.permissions<>OLD.permissions) THEN
			SELECT
				array_agg( ((sub.obj->'fields'->>'obj')::json->>'dataType')||((sub.obj->'fields'->>'obj')::json->'keys'->>'id') )
			INTO NEW.permission_ar
			FROM (
				SELECT jsonb_array_elements(NEW.permissions->'rows') AS obj
			) AS sub		
			;
		END IF;
		/*
		IF TG_OP='UPDATE' THEN
			RAISE EXCEPTION 'Updating contracts linked_contracts=%',NEW.linked_contracts;
		END IF;
		*/
		/*		
		--ГЕНЕРАЦИЯ НОМЕРА ЭКСПЕРТНОГО ЗАКЛЮЧЕНИЯ
		IF TG_OP='INSERT' THEN
			SELECT
				coalesce(max(regexp_replace(ct.expertise_result_number,'\D+.*$','')::int),0)+1,
				coalesce(max(regexp_replace(ct.contract_number,'\D+.*$','')::int),0)+1
			INTO NEW.expertise_result_number,NEW.contract_number
			FROM contracts AS ct
			WHERE
				ct.document_type=NEW.document_type
				AND extract(year FROM NEW.date_time)=extract(year FROM now())
			;
			NEW.expertise_result_number = substr('0000',1,4-length(NEW.expertise_result_number)) || NEW.expertise_result_number
				|| '/'||(extract(year FROM now())-2000)::text;
			NEW.contract_number = 
				CASE
					WHEN NEW.document_type='pd' THEN NEW.contract_number
					WHEN NEW.document_type='cost_eval_validity' THEN NEW.contract_number||'/'||'Д'
					WHEN NEW.document_type='modification' THEN NEW.contract_number||'/'||'М'
					WHEN NEW.document_type='audit' THEN NEW.contract_number||'/'||'А'
					ELSE ''
				END
				;
			NEW.contract_date = now()::date;
		END IF;
		*/
		
		RETURN NEW;
		
	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM client_payments WHERE contract_id = OLD.id;
		DELETE FROM expert_works WHERE contract_id = OLD.id;
		DELETE FROM doc_flow_out WHERE to_contract_id = OLD.id;
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contracts_process() OWNER TO ;
