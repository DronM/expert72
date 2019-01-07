
-- ******************* update 02/01/2019 05:59:21 ******************

		ALTER TABLE applications ADD COLUMN exp_cost_eval_validity bool
			DEFAULT FALSE;


-- ******************* update 02/01/2019 08:00:42 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
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
		
		d.filled_percent,
		d.exp_cost_eval_validity
		
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
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
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
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
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
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 02/01/2019 08:43:13 ******************
-- VIEW: applications_list

DROP VIEW applications_list;

CREATE OR REPLACE VIEW applications_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		/*
		CASE
			WHEN st.state='sent' THEN
				bank_day_next(st.date_time::date,(SELECT const_application_check_days_val()))
			ELSE NULL
		END AS application_state_end_date,
		*/
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE WHEN l.expertise_type IS NOT NULL THEN
				CASE WHEN l.expertise_type='pd' THEN 'ПД'
				WHEN l.expertise_type='eng_survey' THEN 'РИИ'
				ELSE 'ПД и РИИ'
				END||
				CASE WHEN l.exp_cost_eval_validity THEN ',Достоверность' ELSE '' END
			ELSE ''
			END||
			CASE WHEN l.cost_eval_validity THEN
				CASE WHEN l.expertise_type IS NOT NULL THEN ',' ELSE '' END || 'Достоверность'
			ELSE ''
			END||
			CASE WHEN l.modification THEN
				CASE WHEN l.expertise_type IS NOT NULL OR l.cost_eval_validity THEN ',' ELSE '' END|| 'Модификация'
			ELSE ''
			END||
			CASE WHEN l.audit THEN
				CASE WHEN l.expertise_type IS NOT NULL OR l.cost_eval_validity OR l.modification THEN ',' ELSE '' END|| 'Аудит'
			ELSE ''
			END
		) AS service_list,
		
		(
		SELECT json_agg(doc_flow_in_client_ref(in_docs))
		FROM doc_flow_in_client AS in_docs
		WHERE in_docs.application_id=l.id AND NOT coalesce(in_docs.viewed,FALSE)
		) AS unviewed_in_docs,
		
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date
				
	FROM applications AS l
	LEFT JOIN offices_list AS off ON off.id=l.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=l.id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=l.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
		
	ORDER BY l.user_id,l.create_dt DESC
	;
	
ALTER VIEW applications_list OWNER TO expert72;


-- ******************* update 02/01/2019 08:43:27 ******************
-- VIEW: applications_list

DROP VIEW applications_list;

CREATE OR REPLACE VIEW applications_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		/*
		CASE
			WHEN st.state='sent' THEN
				bank_day_next(st.date_time::date,(SELECT const_application_check_days_val()))
			ELSE NULL
		END AS application_state_end_date,
		*/
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE WHEN l.expertise_type IS NOT NULL THEN
				CASE WHEN l.expertise_type='pd' THEN 'ПД'
				WHEN l.expertise_type='eng_survey' THEN 'РИИ'
				ELSE 'ПД и РИИ'
				END||
				CASE WHEN l.exp_cost_eval_validity THEN ', Достоверность' ELSE '' END
			ELSE ''
			END||
			CASE WHEN l.cost_eval_validity THEN
				CASE WHEN l.expertise_type IS NOT NULL THEN ',' ELSE '' END || 'Достоверность'
			ELSE ''
			END||
			CASE WHEN l.modification THEN
				CASE WHEN l.expertise_type IS NOT NULL OR l.cost_eval_validity THEN ',' ELSE '' END|| 'Модификация'
			ELSE ''
			END||
			CASE WHEN l.audit THEN
				CASE WHEN l.expertise_type IS NOT NULL OR l.cost_eval_validity OR l.modification THEN ',' ELSE '' END|| 'Аудит'
			ELSE ''
			END
		) AS service_list,
		
		(
		SELECT json_agg(doc_flow_in_client_ref(in_docs))
		FROM doc_flow_in_client AS in_docs
		WHERE in_docs.application_id=l.id AND NOT coalesce(in_docs.viewed,FALSE)
		) AS unviewed_in_docs,
		
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date
				
	FROM applications AS l
	LEFT JOIN offices_list AS off ON off.id=l.office_id
	LEFT JOIN contracts AS contr ON contr.application_id=l.id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=l.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
		
	ORDER BY l.user_id,l.create_dt DESC
	;
	
ALTER VIEW applications_list OWNER TO expert72;


-- ******************* update 02/01/2019 09:15:08 ******************
-- VIEW: applications_print

--DROP VIEW applications_print;

CREATE OR REPLACE VIEW applications_print AS
	SELECT
		d.id,
		d.user_id,
		format_date_rus(d.create_dt::DATE,FALSE) AS date_descr,
		d.expertise_type,
		d.cost_eval_validity,
		d.cost_eval_validity_simult,
		
		fund_sources.name AS fund_sources_descr,
		
		--applicant
		d.applicant AS applicant,
		banks_format((d.applicant->>'bank')::jsonb) AS applicant_bank,
		kladr_parse_addr((d.applicant->>'post_address')::jsonb) AS applicant_post_address,
		kladr_parse_addr((d.applicant->>'legal_address')::jsonb) AS applicant_legal_address,
		
		--customer
		d.customer AS customer,
		banks_format((d.customer->>'bank')::jsonb) AS customer_bank,
		kladr_parse_addr((d.customer->>'post_address')::jsonb) AS customer_post_address,
		kladr_parse_addr((d.customer->>'legal_address')::jsonb) AS customer_legal_address,
		
		--contractors
		array_to_json((SELECT ARRAY(SELECT app_contractors_parse(d.contractors)))) AS contractors,
				
		d.constr_name,
		kladr_parse_addr(d.constr_address) AS constr_address,
		d.constr_technical_features,
		construction_types.name AS construction_types_descr,
		
		d.total_cost_eval,
		d.limit_cost_eval,
		
		clients.name_full AS office_client_name_full,
		contacts_get_persons(clients.id,'clients') AS office_responsable_persons,
		
		d.pd_usage_info,
		--developer
		d.developer AS developer,
		banks_format((d.developer->>'bank')::jsonb) AS developer_bank,
		kladr_parse_addr((d.developer->>'post_address')::jsonb) AS developer_post_address,
		kladr_parse_addr((d.developer->>'legal_address')::jsonb) AS developer_legal_address,
		
		d.auth_letter,
		d.exp_cost_eval_validity
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN clients ON clients.id=offices.client_id
	LEFT JOIN construction_types ON construction_types.id=d.construction_type_id
	LEFT JOIN fund_sources ON fund_sources.id=d.fund_source_id
	;
	
ALTER VIEW applications_print OWNER TO expert72;


-- ******************* update 07/01/2019 08:25:59 ******************
-- VIEW: applications_dialog

--DROP VIEW contracts_dialog;
--DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

		CASE WHEN d.modif_primary_application_id IS NOT NULL AND d.modif_primary_application_id<>d.id THEN applications_modif_primary_chain(d.id)
		WHEN d.modif_primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.modif_primary_application_reg_number)
		ELSE NULL
		END AS modif_primary_application,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		array_to_json((
			SELECT array_agg(l.documents) FROM document_templates_all_list_for_date(d.create_dt::date) l
			WHERE
				(d.construction_type_id IS NOT NULL)
				AND
				(l.construction_type_id=d.construction_type_id AND
				l.document_type IN (
					CASE WHEN d.expertise_type='pd' OR d.expertise_type='pd_eng_survey' THEN 'pd'::document_types ELSE NULL END,
					CASE WHEN d.expertise_type='eng_survey' OR d.expertise_type='pd_eng_survey' THEN 'eng_survey'::document_types ELSE NULL END,
					CASE WHEN d.cost_eval_validity OR d.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
		
		d.filled_percent,
		d.exp_cost_eval_validity
		
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
		LEFT JOIN file_verifications AS f_ver ON f_ver.file_id=adf.file_id
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
			FROM file_signatures AS f_sig
			LEFT JOIN file_verifications AS ver ON ver.file_id=f_sig.file_id
			LEFT JOIN user_certificates AS u_certs ON u_certs.id=f_sig.user_certificate_id
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
	
ALTER VIEW applications_dialog OWNER TO expert72;


-- ******************* update 07/01/2019 08:27:08 ******************
-- VIEW: applications_dialog_lk

--DROP VIEW contracts_dialog_lk;
DROP VIEW applications_dialog_lk;

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
		
		CASE WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NULL THEN
			--applications_primary_chain(d.id)
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					)
			)
		WHEN d.primary_application_id IS NOT NULL AND d.primary_application_reg_number IS NOT NULL THEN
			json_build_object(
				'backward_ord',json_build_array(
					applications_ref((SELECT pa FROM applications pa WHERE pa.id=d.primary_application_id))
					),
				'primary_application_reg_number',d.primary_application_reg_number
			)

		WHEN d.primary_application_reg_number IS NOT NULL THEN json_build_object('primary_application_reg_number',d.primary_application_reg_number)
		ELSE NULL
		END
		AS primary_application,

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
					CASE WHEN d.cost_eval_validity OR d.exp_cost_eval_validity THEN 'cost_eval_validity'::document_types ELSE NULL END,
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
	
ALTER VIEW applications_dialog_lk OWNER TO expert72;


-- ******************* update 07/01/2019 08:39:03 ******************
-- Function: application_processes_process()

-- DROP FUNCTION application_processes_process();

CREATE OR REPLACE FUNCTION application_processes_process()
  RETURNS trigger AS
$BODY$
DECLARE
	i json;
	ind int;
	v_applicant json;
	v_customer json;
	v_contractors json;
	v_application_state application_states;
	v_application_state_dt timestampTZ;
BEGIN

	IF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		IF NEW.state='checking' AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер 
			SELECT
				d.applicant,
				d.customer,
				d.contractors,
				st.state,
				st.date_time
			INTO
				v_applicant,
				v_customer,
				v_contractors,
				v_application_state,
				v_application_state_dt
			FROM applications AS d
			LEFT JOIN (
				SELECT
					t.application_id,
					max(t.date_time) AS date_time
				FROM application_processes t
				WHERE t.application_id=NEW.application_id AND t.date_time<>NEW.date_time
				GROUP BY t.application_id
			) AS h_max ON h_max.application_id=d.id
			LEFT JOIN application_processes st
				ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time							
			WHERE d.id = NEW.application_id;
	
			--*** Contacts ***************
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_applicants'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_customers'::data_types;
			DELETE FROM contacts WHERE parent_id=NEW.application_id AND parent_type = 'application_contractors'::data_types;
		
			PERFORM contacts_add_persons(NEW.application_id,'application_applicants'::data_types,1,v_applicant);
		
			PERFORM contacts_add_persons(NEW.application_id,'application_customers'::data_types,1,v_customer);

			ind = 0;
			FOR i IN SELECT * FROM json_array_elements((SELECT v_contractors))
			LOOP
				PERFORM contacts_add_persons(NEW.application_id,'application_contractors'::data_types,ind*100,i);
				ind = ind+ 1;
			END LOOP;
			--*** Contacts ***************
		
			-- Если отправка из статуса correcting то уведомление отделу приема
			--RAISE EXCEPTION 'main_lk STate=%',v_application_state;
			IF v_application_state = 'correcting' THEN
				--все поля из рассмотрения, которое должно быть с прошлой отправки
				INSERT INTO doc_flow_tasks (
					register_doc,
					date_time,end_date_time,
					doc_flow_importance_type_id,
					employee_id,
					recipient,
					description
				)
				(SELECT
					doc_flow_examinations_ref(ex),
					now(),ex.end_date_time,
					ex.doc_flow_importance_type_id,
					ex.employee_id,
					ex.recipient,
					'Исправление по заявлению '||
					CASE
						WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
						WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
						WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
						WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД и РИИ, Достоверность'
						WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
						WHEN app.cost_eval_validity THEN 'Достоверность'
						WHEN app.modification THEN 'Модификация'
						WHEN app.audit THEN 'Аудит'
					END||', '||app.constr_name||' от '||to_char(v_application_state_dt,'DD/MM/YY')
				FROM doc_flow_examinations ex
				LEFT JOIN doc_flow_in ON doc_flow_in.id=(ex.subject_doc->'keys'->>'id')::int AND ex.subject_doc->>'dataType'='doc_flow_in'
				LEFT JOIN applications AS app ON app.id=doc_flow_in.from_application_id
				WHERE doc_flow_in.from_application_id=NEW.application_id
				LIMIT 1
				)
				;
			END IF;
			
		ELSIF NEW.state='sent' AND (const_client_lk_val() OR const_debug_val()) THEN
			--client lk
			--Делаем исх. письмо клиента.
			--В заявлении только одна услуга
			INSERT INTO doc_flow_out_client (
				date_time,
				user_id,
				application_id,
				subject,
				content,
				doc_flow_out_client_type,
				sent
			)
			(SELECT 
				now(),
				app.user_id,
				NEW.application_id,
				'Новое заявление: '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'ПД, Достоверность'
					WHEN app.expertise_type='pd'::expertise_types THEN 'ПД'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'РИИ, Достоверность'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'РИИ'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'ПД и РИИ, Достоверность'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'ПД и РИИ'
					WHEN app.cost_eval_validity THEN 'Достоверность'
					WHEN app.modification THEN 'Модификация'
					WHEN app.audit THEN 'Аудит'
				END||', '||app.constr_name
				,
				app.applicant->>'name'||' просит провести '||
				CASE
					WHEN app.expertise_type='pd'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='pd'::expertise_types THEN 'экспертизу проектной документации'
					WHEN app.expertise_type='eng_survey'::expertise_types AND app.exp_cost_eval_validity  THEN 'экспертизу результатов инженерных изысканий и проверку достоверности определения сметной стоимости'
					WHEN app.expertise_type='eng_survey'::expertise_types THEN 'экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types THEN 'экспертизу проектной документации и экспертизу результатов инженерных изысканий'
					WHEN app.expertise_type='pd_eng_survey'::expertise_types AND app.exp_cost_eval_validity THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий, проверку достоверности определения сметной стоимости'
					WHEN app.cost_eval_validity THEN 'проверку достоверности определения сметной стоимости'
					WHEN app.modification THEN 'модификацию.'
					WHEN app.audit THEN 'аудит'
				END||' по объекту '||app.constr_name
				,
				'app',
				TRUE
			
			FROM applications AS app
			WHERE app.id = NEW.application_id
			LIMIT 1
			--Вдруг как то пролезли 2 услуги???
			);
			
		ELSIF (NEW.state='waiting_for_pay' OR NEW.state='expertise')
		AND (NOT const_client_lk_val() OR const_debug_val()) THEN
			--Главный сервер контракт или оплата
			--письмо об изменении состояния
			INSERT INTO mail_for_sending
			(to_addr,to_name,body,subject,email_type)
			(WITH 
				templ AS (
					SELECT
						t.template AS v,
						t.mes_subject AS s
					FROM email_templates t
					WHERE t.email_type= 'contract_state_change'::email_types
				)
			SELECT
				users.email,
				users.name_full,
				sms_templates_text(
					ARRAY[
						ROW('contract_number', contr.contract_number)::template_value,
						ROW('contract_date',to_char(contr.contract_date,'DD/MM/YY'))::template_value,
						ROW('state',enum_application_states_val(NEW.state,'ru'))::template_value
					],
					(SELECT v FROM templ)
				) AS mes_body,		
				(SELECT s FROM templ),
				'contract_state_change'::email_types
			FROM contracts AS contr
			LEFT JOIN applications AS app ON app.id=contr.application_id
			LEFT JOIN users ON users.id=app.user_id
			WHERE
				contr.application_id=NEW.application_id
				--email_confirmed					
			);				
			
		END IF;
				
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_process() OWNER TO expert72;


-- ******************* update 07/01/2019 08:49:11 ******************
-- VIEW: contracts_list

--DROP VIEW contracts_list;

CREATE OR REPLACE VIEW contracts_list AS
	SELECT
		t.id,
		t.date_time,
		t.application_id,
		applications_ref(applications) AS applications_ref,
		
		t.client_id,
		clients.name AS client_descr,
		--clients_ref(clients) AS clients_ref,
		coalesce(t.constr_name,applications.constr_name) AS constr_name,
		
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,

		t.employee_id,
		employees_ref(employees) AS employees_ref,
		
		t.reg_number,
		t.expertise_type,
		t.document_type,
		
		contracts_ref(t) AS self_ref,
		
		t.permission_ar,
		t.main_expert_id,
		t.main_department_id,
		m_exp.name AS main_expert_descr,
		--employees_ref(m_exp) AS main_experts_ref,
		
		t.contract_number,
		t.contract_date,
		t.expertise_result_number,
		
		t.comment_text,
		
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_date,
		
		t.for_all_employees,
		CASE
			WHEN (coalesce(pm.cnt,0)=0) THEN 'no_pay'
			WHEN st.state='returned' OR st.state='closed_no_expertise' THEN 'returned'
			WHEN t.expertise_result IS NULL AND t.expertise_result_date<=now()::date THEN 'no_result'
			ELSE NULL
		END AS state_for_color,
		
		applications.exp_cost_eval_validity
		
	FROM contracts AS t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN employees AS m_exp ON m_exp.id=t.main_expert_id
	LEFT JOIN clients ON clients.id=t.client_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=t.application_id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	LEFT JOIN (
		SELECT
			client_payments.contract_id,
			count(*) AS cnt
		FROM client_payments
		GROUP BY client_payments.contract_id
	) AS pm ON pm.contract_id=t.id
	;
	
ALTER VIEW contracts_list OWNER TO expert72;

-- ******************* update 07/01/2019 08:55:44 ******************
-- VIEW: contracts_dialog

--DROP VIEW contracts_dialog;

CREATE OR REPLACE VIEW contracts_dialog AS
	SELECT
		t.id,
		t.date_time,		
		employees_ref(employees) AS employees_ref,
		t.reg_number,
		t.expertise_type,
		t.document_type,
		t.expertise_result_number,
		
		--applications
		app.applications_ref,
		applications_client_descr(app.applicant) AS applicant_descr,
		applications_client_descr(app.customer) AS customer_descr,
		applications_client_descr(app.developer) AS developer_descr,
		
		(SELECT
			json_build_object(
				'id','ContractorList_Model',
				'rows',json_agg(
					json_build_object(
						'fields',
						json_build_object(
							'name',
							sub.contractors->>'name'||
							coalesce(' '||(sub.contractors->>'inn')::text,'')||
							coalesce('/'||(sub.contractors->>'kpp')::text,'')
						)
					)
				)
			)
		FROM (
			SELECT
				jsonb_array_elements(contractors) AS contractors
			FROM applications app_contr WHERE app_contr.id=app.id
		) AS sub		
		)
		AS contractors_list,
		
		app.construction_types_ref,
		t.constr_name AS constr_name,
		--kladr_parse_addr(t.constr_address) AS constr_address,
		t.constr_address,
		t.constr_technical_features,
		t.constr_technical_features_in_compound_obj,
		app.total_cost_eval,
		app.limit_cost_eval,
		app.build_types_ref,
		app.cost_eval_validity_simult,
		app.fund_sources_ref,
		coalesce(t.primary_contract_reg_number,app.primary_application_reg_number) AS primary_contract_reg_number,
		app.modif_primary_application_reg_number AS modif_primary_contract_reg_number,
		contracts_ref(prim_contr) AS primary_contracts_ref,
		contracts_ref(modif_prim_contr) AS modif_primary_contracts_ref,
		app.cost_eval_validity,
		app.modification,
		app.audit,
		app.documents,
		--***********************
		
		t.contract_number,
		t.contract_date,		
		t.expertise_cost_budget,
		t.expertise_cost_self_fund,
		
		t.work_start_date,
		t.work_end_date,
		t.akt_number,
		t.akt_date,
		coalesce(t.akt_total,0) As akt_total,
		t.akt_ext_id,
		t.invoice_date,
		t.invoice_number,
		t.invoice_ext_id,
		t.expertise_day_count,
		t.kadastr_number,
		t.grad_plan_number,
		t.area_document,
		t.expertise_result,
		t.expertise_result_date,
		
		t.comment_text,
		
		expertise_reject_types_ref(rt) AS expertise_reject_types_ref,		
		
		departments_ref(dp) AS main_departments_ref,
		employees_ref(exp_empl) AS main_experts_ref,
		
		t.permissions,
		
		(
			SELECT
				json_agg(sec_rows.sec_data)
			FROM (
				SELECT
					json_build_object(
						'section_id',sec.section_id,
						'section_name',sec.section_name,
						'experts_list',
						(SELECT
							string_agg(
								coalesce(expert_works.comment_text,'') ||
								'(' || person_init(employees.name,FALSE) || to_char(expert_works.date_time,'DD/MM/YY') || ')'
								,', '
							)
						FROM(
							SELECT
								expert_works.expert_id,
								expert_works.section_id,
								max(expert_works.date_time) AS date_time
							FROM expert_works
							WHERE expert_works.contract_id=t.id AND expert_works.section_id=sec.section_id
							GROUP BY expert_works.expert_id,expert_works.section_id
						) AS ew_last
						LEFT JOIN expert_works ON
							expert_works.date_time=ew_last.date_time
							AND expert_works.expert_id=ew_last.expert_id
							AND expert_works.section_id=ew_last.section_id
						LEFT JOIN employees ON employees.id=expert_works.expert_id	
						)
						
					) AS sec_data
				FROM expert_sections AS sec
				WHERE sec.document_type=t.document_type AND construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
				AND sec.create_date=(
					SELECT max(sec2.create_date)
					FROM expert_sections AS sec2
					WHERE sec2.document_type=t.document_type
						AND sec2.construction_type_id=(app.construction_types_ref->'keys'->>'id')::int
						AND sec2.create_date<=t.date_time
				)
				ORDER BY sec.section_index				
			) AS sec_rows
		) AS expertise_sections,
		
		t.application_id,
		
		t.contract_ext_id,
		
		t.contract_return_date,
		
		t.linked_contracts,
		
		t.cost_eval_validity_pd_order,
		t.date_type,
		t.argument_document,
		t.order_document,
		app.auth_letter,
		
		t.expert_work_day_count,
		t.expert_work_end_date,
		
		app.doc_folders,
		
		t.for_all_employees,
		t.in_estim_cost,
		t.in_estim_cost_recommend,
		t.cur_estim_cost,
		t.cur_estim_cost_recommend,
		
		t.result_sign_expert_list,
		
		t.experts_for_notification,
		
		t.contract_return_date_on_sig,
		
		app.exp_cost_eval_validity
		
	FROM contracts t
	LEFT JOIN applications_dialog AS app ON app.id=t.application_id
	LEFT JOIN employees ON employees.id=t.employee_id
	LEFT JOIN expertise_reject_types AS rt ON rt.id=t.expertise_reject_type_id
	LEFT JOIN departments AS dp ON dp.id=t.main_department_id
	LEFT JOIN employees AS exp_empl ON exp_empl.id=t.main_expert_id
	LEFT JOIN contracts AS prim_contr ON prim_contr.id=t.primary_contract_id
	LEFT JOIN contracts AS modif_prim_contr ON modif_prim_contr.id=t.modif_primary_contract_id
	--LEFT JOIN clients ON clients.id=t.client_id
	;
	
ALTER VIEW contracts_dialog OWNER TO expert72;
