-- Function: public.report_template_files_process()

-- DROP FUNCTION public.report_template_files_process();

CREATE OR REPLACE FUNCTION public.report_template_files_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT')
		OR (TG_OP='UPDATE' AND NEW.permissions<>OLD.permissions) THEN
			--permissions
			SELECT
				array_agg( ((sub.obj->'fields'->>'obj')::json->>'dataType')||((sub.obj->'fields'->>'obj')::json->'keys'->>'id') )
			INTO NEW.permission_ar
			FROM (
				SELECT jsonb_array_elements(NEW.permissions->'rows') AS obj
			) AS sub		
			;
			
			--views
			SELECT
				array_agg( ((sub.obj->'fields'->>'obj')::json->'keys'->>'id')::int )
			INTO NEW.view_ar
			FROM (
				SELECT jsonb_array_elements(NEW.views->'rows') AS obj
			) AS sub		
			;
			
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.report_template_files_process()
  OWNER TO expert72;

