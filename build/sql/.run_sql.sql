-- Function: document_templates_on_filter(id_date date, in_construction_type_id int, in_service_type service_types, in_expertise_type expertise_types)

-- DROP FUNCTION document_templates_on_filter(id_date date, in_construction_type_id int, in_service_type service_types, in_expertise_type expertise_types);

CREATE OR REPLACE FUNCTION document_templates_on_filter(id_date date, in_construction_type_id int, in_service_type service_types, in_expertise_type expertise_types)
  RETURNS JSONB AS
$$
	WITH
	w_list AS (	
		SELECT
			tmpl.document_type,
			tmpl.content::jsonb,
			CASE WHEN tmpl.service_type IS NULL THEN 0 ELSE 1 END AS w
	
		FROM document_templates AS tmpl
		LEFT JOIN (
			SELECT
				max(create_date) AS create_date,
				document_type,
				service_type,
				expertise_type,
				construction_type_id
			FROM document_templates		
			--*** added ***
			WHERE document_templates.create_date<=id_date
			GROUP BY document_type,service_type,expertise_type,construction_type_id
		) AS sub ON
			sub.create_date=tmpl.create_date
			AND sub.document_type=tmpl.document_type
			AND sub.service_type=tmpl.service_type
			AND sub.expertise_type=tmpl.expertise_type
			AND sub.construction_type_id=tmpl.construction_type_id		
		WHERE
			(in_construction_type_id IS NOT NULL)
			AND
			(tmpl.construction_type_id=in_construction_type_id
			AND tmpl.document_type IN (
				CASE WHEN (in_expertise_type='pd' OR in_expertise_type='pd_eng_survey' OR in_expertise_type='cost_eval_validity_pd' OR in_expertise_type='cost_eval_validity_pd_eng_survey')
					THEN 'pd'::document_types
					ELSE NULL
				END,
				CASE WHEN (in_expertise_type='eng_survey' OR in_expertise_type='pd_eng_survey' OR in_expertise_type='cost_eval_validity_eng_survey' OR in_expertise_type='cost_eval_validity_pd_eng_survey')
					THEN 'eng_survey'::document_types
					ELSE NULL
				END,
				CASE WHEN (in_expertise_type='cost_eval_validity' OR in_expertise_type='cost_eval_validity_pd' OR in_expertise_type='cost_eval_validity_eng_survey' OR in_expertise_type='cost_eval_validity_pd_eng_survey')
					THEN 'cost_eval_validity'::document_types
					ELSE NULL
				END,
				CASE WHEN in_service_type='cost_eval_validity' THEN 'cost_eval_validity'::document_types ELSE NULL END,
				CASE WHEN in_service_type='audit' THEN 'audit'::document_types ELSE NULL END,
				CASE WHEN in_service_type='modification' THEN 'modification'::document_types ELSE NULL END
				)
			AND (
				--Для экспертизы либо все пусто либо все совпадает
				(in_service_type = 'expertise'
				AND (
					(tmpl.service_type IS NULL AND tmpl.expertise_type IS NULL)
					OR (tmpl.service_type = in_service_type AND tmpl.expertise_type=in_expertise_type)
				    )
				)
				--для остального service_type пусто или совпадает
				OR (in_service_type <> 'expertise'
					AND (tmpl.service_type IS NULL OR tmpl.service_type = in_service_type)
				)	
			    )
			)
	)
		
	SELECT
		to_jsonb(array_agg(sub.documents))
	FROM	
	(SELECT DISTINCT ON (w_list.document_type)
		jsonb_build_object(
			'document_type',w_list.document_type,
			'construction_type_id',in_construction_type_id,
			'service_type',in_service_type,
			'expertise_type',in_expertise_type,
			'document',coalesce(
				(SELECT (t.content->'items')::jsonb FROM w_list AS t WHERE t.w=1 AND t.document_type=w_list.document_type)
				,(SELECT (t.content->'items')::jsonb FROM w_list AS t WHERE t.w=0 AND t.document_type=w_list.document_type)
			)
			
		) AS documents
	FROM w_list
	) AS sub
	;

$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION document_templates_on_filter(id_date date, in_construction_type_id int, in_service_type service_types, in_expertise_type expertise_types) OWNER TO expert72;

