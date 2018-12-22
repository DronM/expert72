-- VIEW: manuals_list

DROP VIEW manuals_list;

CREATE OR REPLACE VIEW manuals_list AS
	SELECT
		id,
		(SELECT string_agg(enum_role_types_val((s.r->'fields'->>'role_type')::role_types,'ru'),', ')
		FROM (
			SELECT jsonb_array_elements(roles->'rows') AS r
		) AS s	
		) AS roles_list
	FROM manuals
	ORDER BY id
	;
	
ALTER VIEW manuals_list OWNER TO ;
