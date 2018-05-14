-- VIEW: document_templates_all_json_list

--DROP VIEW document_templates_all_json_list;

CREATE OR REPLACE VIEW document_templates_all_json_list AS
	SELECT array_to_json(array_agg(tb.documents)) AS documents
	FROM document_templates_all_list tb
;
	
ALTER VIEW document_templates_all_json_list OWNER TO ;
