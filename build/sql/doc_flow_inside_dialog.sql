-- VIEW: doc_flow_inside_dialog

DROP VIEW doc_flow_inside_dialog;

CREATE OR REPLACE VIEW doc_flow_inside_dialog AS
	SELECT
		t.*,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		contracts_ref(ct) AS contracts_ref,
		employees_ref(emp) AS employees_ref,
		
		json_build_array(
			json_build_object(
				'files',files.attachments
			)
		) AS files,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_inside_processes_chain(t.id) AS doc_flow_inside_processes_chain
		
		
	FROM doc_flow_inside AS t
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=t.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=t.contract_id
	LEFT JOIN employees AS emp ON emp.id=t.employee_id
	LEFT JOIN (
		SELECT
			t.doc_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size,
					'file_signed',t.file_signed,
					'file_uploaded','true',
					'file_path',t.file_path
				)
			) AS attachments			
		FROM doc_flow_attachments AS t
		WHERE t.doc_type='doc_flow_inside'::data_types
		GROUP BY t.doc_id		
	) AS files ON files.doc_id = t.id
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=t.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_inside_dialog OWNER TO ;
