-- Function: capit_first_letter(text)

--DROP FUNCTION capit_first_letter(text);

CREATE OR REPLACE FUNCTION capit_first_letter(text)
  RETURNS text AS
$BODY$
	SELECT 
		upper(substr($1,1,1)) ||
		lower(substr($1,2));	
$BODY$
LANGUAGE sql IMMUTABLE COST 100;
ALTER FUNCTION capit_first_letter(text) OWNER TO ;
