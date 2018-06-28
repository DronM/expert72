-- Function: applications_split(in_application_id int, in_document_type document_types)

-- DROP FUNCTION applications_split(in_application_id int, in_document_type document_types);

/**
 * @param{int} in_application_id Ид заявления от которого надо отщипнуть услугу
 * @param{document_types} in_document_type услуга, которую надо отшипнуть
 * Отщипляет услугу от заявления, создает новое завление, как копию, оставляю новую услугу, новая услуга выбирается из старого заявления
 * все файлы также переносятся
 */
CREATE OR REPLACE FUNCTION applications_split(in_application_id int, in_document_type document_types)
  RETURNS bigint AS
$BODY$
DECLARE
	v_new_app_id int;
	v_user_id int;
BEGIN
	-- new service
	INSERT INTO applications(
		user_id, create_dt,
		expertise_type,
		contractors, applicant, 
		customer, constr_name, constr_address, constr_technical_features, 
		total_cost_eval, filled_percent, office_id, fund_source_id, construction_type_id, 
		cost_eval_validity,
		cost_eval_validity_simult,
		primary_application_id, 
		primary_application_reg_number, build_type_id,
		modification, 
		audit,
		modif_primary_application_id,
		modif_primary_application_reg_number, 
		developer,
		app_print_expertise,
		app_print_cost_eval,
		app_print_modification, 
		app_print_audit,
		limit_cost_eval,
		auth_letter,
		auth_letter_file,
		base_application_id
	)
	(SELECT
		app.user_id, now(),
		NULL,
		app.contractors, app.applicant, 
		app.customer, app.constr_name, app.constr_address, app.constr_technical_features, 
		app.total_cost_eval, app.filled_percent, app.office_id, app.fund_source_id, app.construction_type_id, 
		CASE WHEN in_document_type='cost_eval_validity' THEN app.cost_eval_validity ELSE FALSE END,
		CASE WHEN in_document_type='cost_eval_validity' THEN app.cost_eval_validity_simult ELSE NULL END,
		app.primary_application_id, 
		app.primary_application_reg_number, app.build_type_id,
		CASE WHEN in_document_type='modification' THEN app.modification ELSE FALSE END,
		CASE WHEN in_document_type='audit' THEN app.audit ELSE FALSE END,
		CASE WHEN in_document_type='modification' THEN app.modif_primary_application_id ELSE NULL END,
		CASE WHEN in_document_type='modification' THEN app.modif_primary_application_reg_number ELSE NULL END,
		app.developer,
		NULL,
		CASE WHEN in_document_type='cost_eval_validity' THEN app.app_print_cost_eval ELSE NULL END,
		CASE WHEN in_document_type='modification' THEN app.app_print_modification ELSE NULL END,
		CASE WHEN in_document_type='audit' THEN app.app_print_audit ELSE NULL END,
		CASE WHEN in_document_type='cost_eval_validity' THEN app.limit_cost_eval ELSE NULL END,
		app.auth_letter,
		app.auth_letter_file,
		in_application_id
		
	FROM applications AS app WHERE app.id=in_application_id
	)
	RETURNING id,user_id
	INTO v_new_app_id,v_user_id;
	
	--Add new app files modify original files
	UPDATE application_document_files
	SET application_id=v_new_app_id
	WHERE application_id=in_application_id AND document_type=in_document_type;
	/*
	INSERT INTO application_document_files (
		file_id, application_id, document_id, document_type, date_time, 
            file_name, file_path, file_signed, deleted, deleted_dt, file_size
	)
	(SELECT
		app_f.file_id,--md5(app_f.file_name||app_f.date_time::text),
		v_new_app_id,
		app_f.document_id,
		app_f.document_type,
		app_f.date_time, 
		app_f.file_name, app_f.file_path, app_f.file_signed, app_f.deleted, app_f.deleted_dt, app_f.file_size
	FROM application_document_files AS app_f
	WHERE app_f.application_id=in_application_id AND app_f.document_type=in_document_type
	);	
	--remove original app files
	DELETE FROM application_document_files WHERE application_id=in_application_id AND document_type=in_document_type;
	*/
	
	--Изменение оригинального документа
	UPDATE applications
	SET
		cost_eval_validity = CASE WHEN in_document_type='cost_eval_validity' THEN FALSE ELSE cost_eval_validity END,
		cost_eval_validity_simult = CASE WHEN in_document_type='cost_eval_validity' THEN NULL ELSE cost_eval_validity_simult END,
		modification = CASE WHEN in_document_type='modification' THEN FALSE ELSE modification END,
		modif_primary_application_id = CASE WHEN in_document_type='modification' THEN NULL ELSE modif_primary_application_id END,
		modif_primary_application_reg_number = CASE WHEN in_document_type='modification' THEN NULL ELSE modif_primary_application_reg_number END,
		audit = CASE WHEN in_document_type='audit' THEN FALSE ELSE audit END,
		app_print_modification = CASE WHEN in_document_type='modification' THEN NULL ELSE app_print_modification END,
		app_print_audit = CASE WHEN in_document_type='audit' THEN NULL ELSE app_print_audit END,
		app_print_cost_eval = CASE WHEN in_document_type='cost_eval_validity' THEN NULL ELSE app_print_cost_eval END,
		limit_cost_eval = CASE WHEN in_document_type='cost_eval_validity' THEN NULL ELSE limit_cost_eval END,
		derived_application_id = v_new_app_id
	WHERE id=in_application_id;
	
	--pass new app to process
	INSERT INTO application_processes (application_id,state,user_id) VALUES (v_new_app_id,'sent',v_user_id);
	
	RETURN v_new_app_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION applications_split(in_application_id int, in_document_type document_types) OWNER TO ;
