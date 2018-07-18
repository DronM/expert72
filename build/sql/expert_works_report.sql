
SELECT
	contr.id,
	contr.expertise_result_number,
	contr.constr_name,
	contr.work_start_date,
	contr.expert_work_end_date,
	contr.expertise_sections,
	(
	SELECT
		json_agg(json_build_object(
			'date_time',doc_flow_in.date_time,
			'reg_number',doc_flow_in.reg_number
		))
		
	FROM doc_flow_in
	WHERE doc_flow_in.from_application_id=app.id AND doc_flow_in.doc_flow_type_id=(pdfn_doc_flow_types_contr_resp()->'keys'->>'id')::int	
	) AS doc_flow_in,
	
	(
	SELECT
		json_agg(json_build_object(
			'date_time',doc_flow_out.date_time,
			'reg_number',doc_flow_out.reg_number
		))
	FROM doc_flow_out
	LEFT JOIN doc_flow_registrations AS reg ON reg.subject_doc->>'dataType'='doc_flow_out' AND (reg.subject_doc->'keys'->>'id')::int=doc_flow_out.id
	where to_contract_id=contr.id AND reg.id IS NOT NULL
	
	) AS doc_flow_out
	
FROM contracts_dialog AS contr
LEFT JOIN applications AS app ON app.id=contr.application_id
WHERE contr.expertise_result_date IS NULL AND contr.work_start_date IS NOT NULL
ORDER BY contr.constr_name

