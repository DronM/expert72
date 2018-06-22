-- Function: doc_flow_inside_processes_chain(doc_flow_inside_id integer)

-- DROP FUNCTION doc_flow_inside_processes_chain(doc_flow_inside_id integer);

CREATE OR REPLACE FUNCTION doc_flow_inside_processes_chain(doc_flow_inside_id integer)
  RETURNS json AS
$$
	WITH
		base_doc AS (
			SELECT
				doc_flow_inside_ref(doc_flow_inside)::jsonb AS doc_flow_inside_ref,
				doc_flow_inside.date_time,
				
				applications_ref(applications)::jsonb as applications_ref,
				
				contracts_ref(contracts)::jsonb AS contracts_ref,
				
				clients.name AS client_descr
		
			FROM doc_flow_inside
			LEFT JOIN contracts ON contracts.id=doc_flow_inside.contract_id
			LEFT JOIN applications ON applications.id=contracts.application_id
			LEFT JOIN clients ON clients.id=contracts.client_id
			WHERE doc_flow_inside.id=$1
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
			doc_flow_inside_ref AS doc,
			2 AS step,
			date_time,
			''  AS state_descr
		FROM base_doc)
		
		
		UNION ALL
		(SELECT
			register_doc AS doc,
			3 AS step,
			date_time,
			enum_doc_flow_inside_states_val(state,'ru')
			
		FROM doc_flow_inside_processes WHERE doc_flow_inside_id=$1 ORDER BY date_time ASC)
		
		
		ORDER BY step,date_time
	) AS sub
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_inside_processes_chain(doc_flow_inside_id integer) OWNER TO ;
