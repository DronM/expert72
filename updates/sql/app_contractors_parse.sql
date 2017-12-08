-- Function: app_contractors_parse(jsonb)

--DROP FUNCTION app_contractors_parse(jsonb);

CREATE OR REPLACE FUNCTION app_contractors_parse(jsonb)
  RETURNS SETOF jsonb AS
$BODY$
DECLARE
    contractor jsonb;
    --res jsonb[];
BEGIN
  FOR contractor IN SELECT * FROM jsonb_array_elements($1)
  LOOP  	
	RETURN NEXT row_to_json(t)
		FROM
		(SELECT
			contractor AS contractor,
			banks_format((contractor->>'bank')::jsonb) AS bank,
			kladr_parse_addr((contractor->>'post_address')::jsonb) AS post_address,
			kladr_parse_addr((contractor->>'legal_address')::jsonb) AS legal_address
		) AS t
	;  	
  	
    --RAISE NOTICE 'BankFormated=%, Bank=%', banks_parse((contractor->>'bank')::jsonb),contractor->'bank';
    --RAISE NOTICE 'post_address=%',kladr_parse_addr((contractor->>'post_address')::jsonb);
    --RAISE NOTICE 'legal_address=%',kladr_parse_addr((contractor->>'legal_address')::jsonb);
    --RAISE NOTICE 'contractor=%',contractor;
  END LOOP;
  
  --SELECT array_to_json(res);
  
END;
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100;
  
ALTER FUNCTION app_contractors_parse(jsonb) OWNER TO ;
