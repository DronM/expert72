-- Function: doc_flow_out_client_out_attrs(in_pplication_id int)

-- DROP FUNCTION doc_flow_out_client_out_attrs(in_application_id int);

CREATE OR REPLACE FUNCTION doc_flow_out_client_out_attrs(in_application_id int)
  RETURNS jsonb AS
$$
	WITH last_doc AS (
		SELECT
		
			coalesce(df_out.allow_new_file_add,FALSE) AS allow_new_file_add,
			(SELECT
				array_agg(checked_sections.section_id)
			FROM
			(	(SELECT
					(sec.sections->'fields'->>'id')::int AS section_id
				FROM (
				SELECT
					jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
				) AS sec
				WHERE (sec.sections->'fields'->>'checked')::bool
				)
				UNION ALL
				(SELECT
					(subsec.sections->'fields'->>'id')::int AS section_id
				FROM
				(	SELECT
						jsonb_array_elements(sec.sections->'items') sections
					FROM (
						SELECT
							jsonb_array_elements(df_out.allow_edit_sections->'sections') sections
					) AS sec
					WHERE sec.sections->'items' IS NOT NULL
				) AS subsec
				WHERE (subsec.sections->'fields'->>'checked')::bool
				)
			) AS checked_sections						
			) AS allow_edit_sections
		FROM doc_flow_out AS df_out
		WHERE
			df_out.to_application_id=$1
			AND (SELECT pr.state
				FROM doc_flow_out_processes pr
				WHERE pr.doc_flow_out_id=df_out.id
				ORDER BY pr.date_time DESC
				LIMIT 1
			)='registered'
			--!!!Только замечания экспертизы!!!
			AND df_out.doc_flow_type_id = (pdfn_doc_flow_types_contr()->'keys'->>'id')::int
		ORDER BY df_out.date_time DESC
		LIMIT 1
	)
	SELECT
		jsonb_build_object(
			'allow_new_file_add',
				CASE
				WHEN (SELECT ct.allow_new_file_add FROM contracts ct WHERE ct.application_id=in_application_id LIMIT 1) THEN TRUE
				ELSE (SELECT last_doc.allow_new_file_add FROM last_doc)
				END,
			'allow_edit_sections',
				(SELECT last_doc.allow_edit_sections FROM last_doc)						
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_client_out_attrs(in_application_id int) OWNER TO ;
