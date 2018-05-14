-- Function: person_init(text,bool)

--DROP FUNCTION person_init(text,bool);

/*
 * @param {text} person name
 * @param {bool} add spaces to middle name
 */
CREATE OR REPLACE FUNCTION person_init(text,bool)
  RETURNS TEXT AS
$BODY$
	SELECT
		first||
		CASE WHEN length(second)>0 THEN ' ' ||substr(second,1,1)||'.' ELSE '' END||
		CASE WHEN length(middle)>0 THEN CASE WHEN $2 THEN ' ' ELSE '' END ||substr(middle,1,1)||'.' ELSE '' END
	FROM parse_person_name($1)
	AS (first text,second text,middle text)
$BODY$
LANGUAGE sql IMMUTABLE COST 100;
ALTER FUNCTION person_init(text,bool) OWNER TO ;
