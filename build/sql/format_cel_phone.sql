-- Function: format_cel_phone(text)

-- DROP FUNCTION format_cel_phone(text);

CREATE OR REPLACE FUNCTION format_cel_phone(text)
  RETURNS text AS
$BODY$
	SELECT 
		CASE
			WHEN char_length($1)<10 THEN $1
			ELSE
			'+7-'||substr($1,1,3)||'-'||substr($1,4,3)||'-'||substr($1,7,2)||'-'||substr($1,9,2)
		END;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION format_cel_phone(text) OWNER TO ;

