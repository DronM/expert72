-- Function: document_templates_process()

-- DROP FUNCTION document_templates_process();

CREATE OR REPLACE FUNCTION document_templates_process()
  RETURNS trigger AS
$BODY$
BEGIN

	IF (TG_WHEN='BEFORE') THEN
		DELETE FROM expert_sections
		WHERE document_type=NEW.document_type
			AND construction_type_id=NEW.construction_type_id
			AND create_date=NEW.create_date;
			
		RETURN NEW;
	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION document_templates_process() OWNER TO ;

