-- VIEW: doc_flow_in_list

--DROP VIEW doc_flow_in_list;

CREATE OR REPLACE VIEW doc_flow_in_list AS
	SELECT
		doc_flow_in.id,
		doc_flow_in.date_time,
		doc_flow_in.reg_number,
		doc_flow_in.from_addr_name,
		doc_flow_in.subject,
		
		applications_ref(applications) AS from_applications_ref,
		doc_flow_in.from_application_id AS from_application_id,
		
		contracts_ref(contracts) AS from_contracts_ref,
		contracts.id AS from_contract_id,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		doc_flow_in.recipient,
		
		CASE
			WHEN doc_flow_in.from_application_id IS NOT NULL THEN applications_ref(applications)->>'descr'||', '||(applications.applicant->>'name')
			WHEN doc_flow_in.from_client_id IS NOT NULL THEN clients_ref(clients)->>'descr'
			ELSE doc_flow_in.from_addr_name::text
		END AS sender,
		
		CASE
			WHEN doc_flow_in.from_application_id IS NOT NULL THEN
				applications.constr_name
			ELSE ''
		END AS sender_construction_name,
		
		(SELECT
			string_agg(sections.section->>'name',', ')
		FROM (SELECT jsonb_array_elements(doc_flow_in.corrected_sections) AS section) AS sections
		) AS corrected_sections
		
	FROM doc_flow_in
	LEFT JOIN applications ON applications.id=doc_flow_in.from_application_id
	LEFT JOIN contracts ON contracts.application_id=applications.id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_in.doc_flow_type_id
	LEFT JOIN clients ON clients.id=doc_flow_in.from_client_id
	LEFT JOIN (
		SELECT
			t.doc_flow_in_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_in_processes t
		GROUP BY t.doc_flow_in_id
	) AS h_max ON h_max.doc_id=doc_flow_in.id
	LEFT JOIN doc_flow_in_processes st
		ON st.doc_flow_in_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	ORDER BY doc_flow_in.date_time DESC
	;
	
ALTER VIEW doc_flow_in_list OWNER TO ;
