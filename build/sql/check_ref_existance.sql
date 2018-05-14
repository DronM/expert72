-- Function: check_ref_existance(JSONB,data_types[])

-- DROP FUNCTION check_ref_existance(JSONB,data_types[]);

CREATE OR REPLACE FUNCTION check_ref_existance(JSONB,data_types[])
  RETURNS boolean AS
$BODY$
DECLARE
	res boolean;
BEGIN
	IF NOT ( ($1->>'dataType')::data_types =ANY($2) ) THEN
		RETURN FALSE;
	END IF;
	
	EXECUTE format('SELECT TRUE FROM %I WHERE %s',
		$1->>'dataType',
		(SELECT  string_agg(t.key||'='||t.value,' AND ') FROM jsonb_each_text($1->'keys') AS t)
		
	) INTO res;
	
	RETURN res;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION check_ref_existance(JSONB,data_types[]) OWNER TO ;
