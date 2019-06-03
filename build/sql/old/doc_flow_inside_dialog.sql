-- VIEW: doc_flow_inside_dialog

DROP VIEW doc_flow_inside_dialog;

CREATE OR REPLACE VIEW doc_flow_inside_dialog AS
	SELECT
		doc_flow_inside.*,
		doc_flow_importance_types_ref (tp) AS doc_flow_importance_types_ref,
		contracts_ref(ct) AS contracts_ref,
		employees_ref(emp) AS employees_ref,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		
		doc_flow_inside_processes_chain(doc_flow_inside.id) AS doc_flow_inside_processes_chain,
		
		--****************************
		json_build_array(
			json_build_object(
				'files',att.attachments
			)
		) AS files
		---***************************
		
	FROM doc_flow_inside
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=doc_flow_inside.doc_flow_importance_type_id
	LEFT JOIN contracts AS ct ON ct.id=doc_flow_inside.contract_id
	LEFT JOIN employees AS emp ON emp.id=doc_flow_inside.employee_id
	
	LEFT JOIN 
		(SELECT
			t.doc_id,
			json_agg(json_build_object(
				'file_id',t.file_id,
				'file_name',t.file_name,
				'file_size',t.file_size,
				'file_signed',t.file_signed,
				'file_uploaded','true',
				'file_path',t.file_path,
				'signatures',sign.signatures
			))
			AS attachments			
		FROM doc_flow_attachments AS t
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=t.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				json_agg(files_t.signatures) AS signatures
			FROM			
			(SELECT
				f_sig.file_id,
				jsonb_build_object(
					'owner',u_certs.subject_cert,
					'cert_from',u_certs.date_time_from,
					'cert_to',u_certs.date_time_to,
					'sign_date_time',f_sig.sign_date_time,
					'check_result',ver.check_result,
					'check_time',ver.check_time,
					'error_str',ver.error_str,
					'employee_id',u_certs.employee_id,
					'verif_date_time',ver.date_time
				) As signatures
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=t.file_id
	WHERE t.doc_type='doc_flow_inside'::data_types
	GROUP BY t.doc_id
	) AS att ON att.doc_id=doc_flow_inside.id

	
	LEFT JOIN (
		SELECT
			t.doc_flow_inside_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_inside_processes t
		GROUP BY t.doc_flow_inside_id
	) AS h_max ON h_max.doc_id=doc_flow_inside.id
	LEFT JOIN doc_flow_inside_processes st
		ON st.doc_flow_inside_id=h_max.doc_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW doc_flow_inside_dialog OWNER TO ;
