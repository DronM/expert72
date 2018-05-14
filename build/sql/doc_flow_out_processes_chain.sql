-- Function: doc_flow_out_processes_chain(doc_flow_out_id integer)

-- DROP FUNCTION doc_flow_out_processes_chain(doc_flow_out_id integer);

CREATE OR REPLACE FUNCTION doc_flow_out_processes_chain(doc_flow_out_id integer)
  RETURNS json AS
$$
	WITH
		base_doc AS (
			SELECT
				doc_flow_out_ref(doc_flow_out)::jsonb AS doc_flow_out_ref,
				doc_flow_out.date_time,
				doc_flow_in_id,
				CASE WHEN doc_flow_in IS NOT NULL THEN
					doc_flow_in_ref(doc_flow_in)::jsonb
				ELSE NULL
				END AS doc_flow_in_ref,
				
				CASE WHEN doc_flow_in.from_application_id IS NOT NULL THEN
					applications_ref(applications)::jsonb
				WHEN doc_flow_out.to_application_id IS NOT NULL THEN applications_ref(to_app)::jsonb
				ELSE NULL
				END AS applications_ref,
				
				CASE WHEN to_contract_id IS NOT NULL THEN
					contracts_ref(contracts)::jsonb
				ELSE NULL
				END AS contracts_ref,
				
				CASE WHEN doc_flow_in.from_application_id IS NOT NULL THEN
					applications.applicant->>'name'
				WHEN to_contract_id IS NOT NULL THEN
					(SELECT ct_app.applicant->>'name' FROM applications AS ct_app
					WHERE ct_app.id=(SELECT ct.application_id FROM contracts AS ct WHERE ct.id=to_contract_id)
					)
				ELSE NULL
				END AS client_descr
				
				
		
			FROM doc_flow_out
			LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
			LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
			LEFT JOIN applications AS to_app ON to_app.id=doc_flow_out.to_application_id
			LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
			WHERE doc_flow_out.id=$1
		)
	SELECT
		json_agg(json_build_object(
			'doc',sub.doc,
			'state_descr',sub.state_descr
		))
	FROM (
	
		(SELECT
			CASE WHEN contracts_ref IS NOT NULL THEN contracts_ref ELSE applications_ref END AS doc,
			1 AS step,
			date_time,
			client_descr  AS state_descr
		FROM base_doc)

		UNION
		(SELECT
			doc_flow_out_ref AS doc,
			2 AS step,
			date_time,
			''  AS state_descr
		FROM base_doc)
		
		
		UNION ALL
		(SELECT
			register_doc AS doc,
			3 AS step,
			date_time,
			enum_doc_flow_out_states_val(state,'ru')
			
		FROM doc_flow_out_processes WHERE doc_flow_out_id=$1 ORDER BY date_time ASC)
		
		
		ORDER BY step,date_time
	) AS sub
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_out_processes_chain(doc_flow_out_id integer) OWNER TO ;
