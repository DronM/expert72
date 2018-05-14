-- Function: doc_flow_in_next_num(int)

-- DROP FUNCTION doc_flow_in_next_num(int);

CREATE OR REPLACE FUNCTION doc_flow_in_next_num(int)
  RETURNS text AS
$$
	WITH
		pref AS (SELECT num_prefix AS n FROM doc_flow_types WHERE id = $1)
	SELECT
		(SELECT n FROM pref) || (coalesce(max(substr(reg_number,length((SELECT n FROM pref))+1)::int),0)+1)::text
	FROM doc_flow_in
	WHERE substr(reg_number,1,length((SELECT n FROM pref)))=(SELECT n FROM pref)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_next_num(int) OWNER TO ;
