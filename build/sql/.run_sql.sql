-- Function: document_templates_process()

-- DROP FUNCTION document_templates_process();

CREATE OR REPLACE FUNCTION document_templates_process()
  RETURNS trigger AS
$BODY$
BEGIN

	IF (TG_WHEN='BEFORE') THEN
		DELETE FROM expert_sections
		WHERE document_type=OLD.document_type
			AND construction_type_id=OLD.construction_type_id
			AND create_date=OLD.create_date;
			
		RETURN OLD;
	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION document_templates_process() OWNER TO expert72;

