-- Function: document_templates_all_list_for_date(in_date date)

-- DROP FUNCTION document_templates_all_list_for_date(in_date date);

CREATE OR REPLACE FUNCTION document_templates_all_list_for_date(in_date date)
  RETURNS TABLE(
  	document_type document_types,
  	service_type service_types,
  	construction_type_id int,
  	documents json
  ) AS
$$
	SELECT	DISTINCT ON (tmpl.document_type,tmpl.service_type,tmpl.construction_type_id)
		tmpl.document_type,
		tmpl.service_type,
		tmpl.construction_type_id,		
		json_build_object(
			'document_type',tmpl.document_type,
			'document_id',tmpl.document_type||'_'||tmpl.construction_type_id,
			'document',tmpl.content->'items'
		) AS documents
	
	FROM document_templates AS tmpl
	LEFT JOIN (
		SELECT
			max(create_date) AS create_date,
			document_type,
			service_type,
			construction_type_id
		FROM document_templates
		
		--*** added ***
		WHERE document_templates.create_date<=$1
		
		GROUP BY document_type,service_type,construction_type_id
	) AS sub ON
		sub.create_date=tmpl.create_date
		AND sub.document_type=tmpl.document_type
		AND sub.service_type=tmpl.service_type
		AND sub.construction_type_id=tmpl.construction_type_id
	;

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION document_templates_all_list_for_date(in_date date) OWNER TO ;
