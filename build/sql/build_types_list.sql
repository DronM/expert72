-- VIEW: build_types_list

--DROP VIEW build_types_list;

CREATE OR REPLACE VIEW build_types_list AS
	SELECT
		l.id
		,l.name
		,conclusion_dictionary_detail_ref(dict) AS document_types_ref
		
	FROM build_types AS l
	LEFT JOIN conclusion_dictionary_detail AS dict ON l.dt_code = dict.code AND dict.conclusion_dictionary_name='tConstractionType'
	ORDER BY l.name
	;
	
ALTER VIEW build_types_list OWNER TO ;
