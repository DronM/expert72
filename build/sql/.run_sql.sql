-- VIEW: document_templates_list

DROP VIEW document_templates_list;

CREATE OR REPLACE VIEW document_templates_list AS
	SELECT
		tmpl.id,
		tmpl.document_type,
		tmpl.service_type,
		tmpl.expertise_type,
		tmpl.create_date,
		tmpl.construction_type_id,
		construction_types_ref(ct) AS construction_types_ref,		
		tmpl.comment_text		
		
	FROM document_templates AS tmpl
	LEFT JOIN construction_types AS ct ON ct.id=tmpl.construction_type_id
	ORDER BY
		tmpl.document_type,
		tmpl.service_type,
		ct.id,
		tmpl.create_date DESC
	;
	
ALTER VIEW document_templates_list OWNER TO expert72;
