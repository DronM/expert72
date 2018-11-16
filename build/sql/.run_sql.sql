-- VIEW: applications_dialog_lk

--DROP VIEW contracts_dialog_lk;
--DROP VIEW applications_dialog_lk;

CREATE OR REPLACE VIEW applications_dialog_lk AS
	SELECT
		d.id,
		d.create_dt,
		d.user_id,
		d.expertise_type,
		
		--Для контроллера
		( (d.expertise_type IS NOT NULL OR NOT d.cost_eval_validity OR NOT d.modification OR NOT d.audit) AND d.construction_type_id IS NOT NULL) AS document_exists,
		
		coalesce(d.cost_eval_validity,FALSE) AS cost_eval_validity,
		d.cost_eval_validity_simult,
		fund_sources_ref(fund_sources) AS fund_sources_ref,
		construction_types_ref(construction_types) AS construction_types_ref,
		d.applicant,
		d.customer,
		d.contractors,
		d.developer,
		coalesce(contr.constr_name,d.constr_name) AS constr_name,
		coalesce(contr.constr_address,d.constr_address) AS constr_address,
		
		coalesce(contr.constr_technical_features,d.constr_technical_features) As constr_technical_features,
		coalesce(contr.constr_technical_features_in_compound_obj,d.constr_technical_features_in_compound_obj) AS constr_technical_features_in_compound_obj,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		offices_ref(offices) AS offices_ref,
		build_types_ref(build_types) AS build_types_ref,
		coalesce(d.modification,FALSE) AS modification,
		coalesce(d.audit,FALSE) AS audit,
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_id<>d.id THEN applications_primary_chain(d.id)
		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		greatest(st.state,st_lk.state) AS application_state,
		greatest(st.date_time,st_lk.date_time) AS application_state_dt,
		greatest(st.end_date_time,st_lk.end_date_time) AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
					CASE WHEN d.modification THEN 'modification'::document_types ELSE NULL END,
					CASE WHEN d.audit THEN 'audit'::document_types ELSE NULL END			
					)
				)
		)) AS documents,
		
		applications_ref(d)->>'descr' AS select_descr,
		
		d.app_print_expertise,
		d.app_print_cost_eval,
		d.app_print_modification,
		d.app_print_audit,
		
		applications_ref(b_app) AS base_applications_ref,
		applications_ref(d_app) AS derived_applications_ref,
		
		applications_ref(d) AS applications_ref,
		d.primary_application_id,
		d.primary_application_reg_number,
		d.modif_primary_application_id,
		d.modif_primary_application_reg_number,
		
		d.pd_usage_info,
		
		users_ref(users) AS users_ref,
		
		d.auth_letter,
		d.auth_letter_file,
		
		folders.files AS doc_folders,
		
		contr.work_start_date,
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date,
		
		d.filled_percent
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN users ON users.id=d.user_id
	LEFT JOIN contracts AS contr ON contr.application_id=d.id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN build_types ON build_types.id=d.build_type_id
	LEFT JOIN applications AS b_app ON b_app.id=d.base_application_id
	LEFT JOIN applications AS d_app ON d_app.id=d.derived_application_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=d.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
		
	--*****
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes_lk t
		GROUP BY t.application_id
	) AS h_max_lk ON h_max_lk.application_id=d.id
	LEFT JOIN application_processes_lk st_lk
		ON st_lk.application_id=h_max_lk.application_id AND st_lk.date_time = h_max_lk.date_time	
	--*****
		
	LEFT JOIN
		(
		SELECT
			doc_att.application_id,
			json_agg(
				json_build_object(
					'fields',json_build_object('id',doc_att.folder_id,'descr',doc_att.folder_descr),
					'parent_id',NULL,
					'files',doc_att.files
				)
			) AS files
		FROM
		
		(SELECT
			adf.application_id,
			adf.file_path AS folder_descr,
			app_fd.id AS folder_id,
			json_agg(
				json_build_object(
					'file_id',adf.file_id,
					'file_name',adf.file_name,
					'file_size',adf.file_size,
					'file_signed',adf.file_signed,
					'file_uploaded','true',
					'file_path',adf.file_path,
					'date_time',adf.date_time,
					'signatures',--sign.signatures
					CASE
						WHEN sign.signatures IS NULL AND f_ver.file_id IS NOT NULL THEN
							jsonb_build_array(
								jsonb_build_object(
									'sign_date_time',f_ver.date_time,
									'check_result',f_ver.check_result,
									'error_str',f_ver.error_str
								)
							)
						ELSE sign.signatures
					END,
					'file_signed_by_client',adf.file_signed_by_client,
					'require_client_sig',app_fd.require_client_sig
				)
			) AS files
		FROM application_document_files adf
		LEFT JOIN application_doc_folders AS app_fd ON app_fd.name=adf.file_path
		LEFT JOIN doc_flow_out AS adf_out ON adf_out.to_application_id=adf.application_id AND adf_out.doc_flow_type_id=(pdfn_doc_flow_types_app_resp()->'keys'->>'id')::int
		--LEFT JOIN doc_flow_attachments AS adf_att ON adf_att.doc_type='doc_flow_out' AND adf_att.doc_id=adf_out.id AND adf_att.file_name=adf.file_name
		LEFT JOIN file_verifications_lk AS f_ver ON f_ver.file_id=adf.file_id
		LEFT JOIN (
			SELECT
				files_t.file_id,
				jsonb_agg(files_t.signatures) AS signatures
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
					'error_str',ver.error_str
				) AS signatures
			FROM file_signatures_lk AS f_sig
			LEFT JOIN file_verifications_lk AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates_lk AS u_certs ON u_certs.id=f_sig.user_certificate_id
			ORDER BY f_sig.sign_date_time
			) AS files_t
			GROUP BY files_t.file_id
		) AS sign ON sign.file_id=f_ver.file_id
		WHERE adf.document_type='documents'
		GROUP BY adf.application_id,adf.file_path,app_fd.id
		ORDER BY app_fd.id)  AS doc_att	
		
		GROUP BY doc_att.application_id
	) AS folders ON folders.application_id=d.id
	;
	
ALTER VIEW applications_dialog_lk OWNER TO expert72_office;

