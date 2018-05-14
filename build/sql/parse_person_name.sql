-- Function: parse_person_name(text)

--DROP FUNCTION parse_person_name(text);

/*
SELECT
	first,second,middle
FROM parse_person_name('Михалевич Андрей Александрович')
	AS (first text,second text,middle text)
*/

CREATE OR REPLACE FUNCTION parse_person_name(text)
  RETURNS RECORD AS
$BODY$
	SELECT
		CASE
			WHEN position(' ' in $1)=0 THEN
				--нет Имя,отчество
				ROW(capit_first_letter($1)::text,''::text,''::text)
			ELSE
				CASE
					WHEN position(' ' in substr($1,position(' ' in $1)+1 ))=0 THEN
						--нет отчество
						ROW(
							capit_first_letter(substr($1,1,position(' ' in $1))::text),
							capit_first_letter(substr($1,position(' ' in $1)+1)::text),
							''::text
						)
					ELSE
						--есть все
						ROW(
							capit_first_letter(substr($1,1,position(' ' in $1)-1)::text),
							
							capit_first_letter(
							substr($1,position(' ' in $1)+1,
							   position(' ' in 
								substr($1,position(' ' in $1)+1)
								)-1		
							)::text
							),
							
							capit_first_letter(
								substr(substr($1,position(' ' in $1)+1),position(' ' in substr($1,position(' ' in $1)+1))+1)::text
							)
						)								
				END
		END
$BODY$
LANGUAGE sql IMMUTABLE COST 100;
ALTER FUNCTION parse_person_name(text) OWNER TO ;
