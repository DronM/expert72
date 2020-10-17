-- Function: doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool)

-- DROP FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool);

CREATE OR REPLACE FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool)
  RETURNS text AS
$$
	WITH
		pref AS (
			SELECT
				num_prefix||
					CASE WHEN in_ext_contract THEN const_ext_contract_doc_pref_val() ELSE '' END
				AS n
			FROM doc_flow_types
			WHERE id = in_doc_flow_type_id
		)
	SELECT
		(SELECT n FROM pref) || (coalesce(
						max( substr(reg_number,length( (SELECT n FROM pref) )+1)::int )
						,0)+1
					)::text
	FROM doc_flow_in
	WHERE substr(reg_number,1,length((SELECT n FROM pref)))=(SELECT n FROM pref)
		AND substr(reg_number,length((SELECT n FROM pref))+1) ~ '^[0-9\.]+$'
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_next_num(in_doc_flow_type_id int, in_ext_contract bool) OWNER TO ;
