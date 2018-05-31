-- VIEW: doc_flow_out_dialog

DROP VIEW doc_flow_out_dialog;

CREATE OR REPLACE VIEW doc_flow_out_dialog AS
	SELECT
		doc_flow_out.*,
		clients_ref(clients) AS to_clients_ref,
		users_ref(users) AS to_users_ref,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_in_ref(doc_flow_in) AS doc_flow_in_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		employees_ref(employees) AS employees_ref,
		employees_ref(employees2) AS signed_by_employees_ref,
		
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		
		contracts_ref(contracts) AS to_contracts_ref,
		
		doc_flow_out_processes_chain(doc_flow_out.id) AS doc_flow_out_processes_chain
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN contracts ON contracts.id=doc_flow_out.to_contract_id
	LEFT JOIN users ON users.id=doc_flow_out.to_user_id
	LEFT JOIN clients ON clients.id=doc_flow_out.to_client_id
	LEFT JOIN doc_flow_in ON doc_flow_in.id=doc_flow_out.doc_flow_in_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN employees AS employees2 ON employees2.id=doc_flow_out.signed_by_employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true'
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_out'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = doc_flow_out.id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_out_dialog OWNER TO ;
