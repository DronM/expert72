-- Function: doc_flow_in_processes_chain(doc_flow_in_id integer)

-- DROP FUNCTION doc_flow_in_processes_chain(doc_flow_in_id integer);

CREATE OR REPLACE FUNCTION doc_flow_in_processes_chain(doc_flow_in_id integer)
  RETURNS json AS
$$
	WITH base_doc AS (
		SELECT
			doc_flow_in_ref(doc_flow_in)::jsonb AS doc,
			date_time,
			CASE WHEN from_application_id IS NOT NULL THEN
				applications_ref((SELECT applications FROM applications WHERE applications.id=doc_flow_in.from_application_id))::jsonb
			ELSE NULL
			END AS app,
			
			CASE WHEN from_application_id IS NOT NULL THEN
				(SELECT applicant->>'name' FROM applications WHERE applications.id=doc_flow_in.from_application_id)
			ELSE NULL
			END AS app_descr
			
		
		FROM doc_flow_in
		WHERE id=$1
	)
	SELECT
		json_agg(json_build_object(
			'doc',sub.doc,
			'state_descr',sub.state_descr
		))
	FROM (
	
		(SELECT
			register_doc AS doc,
			3 AS step,
			date_time,
			enum_doc_flow_in_states_val(state,'ru') AS state_descr
		FROM doc_flow_in_processes WHERE doc_flow_in_id=$1 ORDER BY date_time ASC)
		UNION
		(SELECT
			doc,
			2 AS step,date_time,
			''  AS state_descr
		FROM base_doc)
		UNION
		(SELECT
			app,
			1 AS step,
			date_time,
			app_descr  AS state_descr
		FROM base_doc)
		ORDER BY step,date_time
	) AS sub
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_in_processes_chain(doc_flow_in_id integer) OWNER TO ;
