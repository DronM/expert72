-- Function: file_name_explode(in_file_name text)

-- DROP FUNCTION file_name_explode(in_file_name text)

CREATE OR REPLACE FUNCTION file_name_explode(in_file_name text)
  RETURNS RECORD AS
$$
	WITH exploded_name AS (SELECT unnest(string_to_array(in_file_name,'.')) AS f_name)
	SELECT
		trim(( SELECT string_agg(name_parts.f_name,'.') AS f_name FROM (SELECT f_name FROM exploded_name OFFSET 0 LIMIT (SELECT count(*)-1 FROM exploded_name)) AS name_parts )) AS f_name,
		(SELECT trim(f_name) FROM exploded_name OFFSET (SELECT count(*)-1 FROM exploded_name) LIMIT 1) AS f_ext
	;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION file_name_explode(in_file_name text) OWNER TO ;
