-- Function: public.doc_flow_approvement_templates_process()

-- DROP FUNCTION public.doc_flow_approvement_templates_process();

CREATE OR REPLACE FUNCTION public.doc_flow_approvement_templates_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF
		((TG_OP='INSERT')
		OR (TG_OP='UPDATE' AND NEW.permissions<>OLD.permissions))
		AND (NOT const_client_lk_val() OR const_debug_val())
		THEN
			--permissions
			SELECT
				array_agg( ((sub.obj->'fields'->>'obj')::json->>'dataType')||((sub.obj->'fields'->>'obj')::json->'keys'->>'id') )
			INTO NEW.permission_ar
			FROM (
				SELECT jsonb_array_elements(NEW.permissions->'rows') AS obj
			) AS sub		
			;
			
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_flow_approvement_templates_process() OWNER TO ;

