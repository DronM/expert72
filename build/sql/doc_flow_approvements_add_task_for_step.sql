-- Function: doc_flow_approvements_add_task_for_step(doc_flow_approvements,int)

-- DROP FUNCTION doc_flow_approvements_add_task_for_step(doc_flow_approvements,int);

CREATE OR REPLACE FUNCTION doc_flow_approvements_add_task_for_step(doc_flow_approvements,int)
  RETURNS void AS
$$
	--задачи всем где step = $2	
	INSERT INTO doc_flow_tasks (
		register_doc,
		date_time,end_date_time,
		doc_flow_importance_type_id,
		employee_id,
		recipient,
		description,
		closed,
		close_doc,
		close_date_time
	)
	SELECT
		doc_flow_approvements_ref($1),
		now(),$1.end_date_time,
		$1.doc_flow_importance_type_id,
		$1.employee_id,
		employees_ref((SELECT e FROM employees e WHERE e.id=empl.employee_id)),
		
		$1.subject||
		(SELECT
			CASE WHEN $1.subject_doc->>'dataType'='doc_flow_out' THEN
				(SELECT
					CASE
						WHEN d_out.new_contract_number IS NOT NULL THEN ', контракт №'||new_contract_number
						WHEN d_out.to_contract_id IS NOT NULL THEN
							', контракт №'||(SELECT ct.contract_number FROM contracts ct WHERE ct.id=d_out.to_contract_id)
						WHEN d_out.to_application_id IS NOT NULL THEN
							', заявление №'||(SELECT app.id FROM applications app WHERE app.id=d_out.to_application_id)
						ELSE ''
					END
				FROM doc_flow_out AS d_out
				WHERE d_out.id=($1.subject_doc->'keys'->>'id')::int)			
				
			WHEN $1.subject_doc->>'dataType'='doc_flow_inside' THEN
				(SELECT
					CASE
						WHEN d_ins.contract_id IS NOT NULL THEN
							', контракт №'||(SELECT ct.contract_number FROM contracts ct WHERE ct.id=d_ins.contract_id)
						ELSE ''
					END
				FROM doc_flow_inside AS d_ins
				WHERE d_ins.id=($1.subject_doc->'keys'->>'id')::int)			
			ELSE ''
			END
		
		)
		,
		$1.closed,
		CASE WHEN $1.closed THEN doc_flow_approvements_ref($1) ELSE NULL END,
		CASE WHEN $1.closed THEN now() ELSE NULL END
	FROM (
	SELECT
		(jsonb_array_elements($1.recipient_list->'rows')->'fields'->'employee'->'keys'->>'id')::int AS employee_id,
		(jsonb_array_elements($1.recipient_list->'rows')->'fields'->>'step')::int AS step
	) AS empl
	WHERE empl.step=$2		
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION doc_flow_approvements_add_task_for_step(doc_flow_approvements,int) OWNER TO ;
