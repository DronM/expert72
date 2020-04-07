-- VIEW: application_modified_documents_list

--DROP VIEW application_modified_documents_list;
/**
 * Все как в applications_list кроме условия!!!
 */
CREATE OR REPLACE VIEW application_modified_documents_list AS
	SELECT
		l.id,
		l.user_id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		st.end_date_time AS application_state_end_date,
		
		l.filled_percent,
		off.address AS office_descr,
		l.office_id,
		
		--'Заявление №'||l.id||' от '||to_char(l.create_dt,'DD/MM/YY') AS select_descr,
		applications_ref(l)->>'descr' AS select_descr,
		
		applicant->>'name' AS applicant_name,
		customer->>'name' AS customer_name,
		
		(
			CASE
			WHEN l.service_type='expert_maintenance' THEN 'Экспертное сопровождение'
			WHEN l.service_type='modified_documents' THEN 'Измененная документация'
			WHEN l.service_type='audit' THEN 'Аудит'
			WHEN l.service_type='modification' THEN 'Модификация'
			WHEN l.expertise_type='pd' AND coalesce(l.cost_eval_validity,FALSE)=FALSE THEN 'ПД'
			WHEN l.expertise_type='cost_eval_validity' OR coalesce(l.cost_eval_validity,FALSE) THEN 'Достоверность'
			WHEN l.expertise_type='cost_eval_validity_pd' THEN 'ПД,Достоверность'
			WHEN l.expertise_type='pd_eng_survey' THEN 'ПД,РИИ'
			WHEN l.expertise_type='cost_eval_validity_pd_eng_survey' THEN 'ПД,РИИ,Достоверность'
			WHEN l.expertise_type='cost_eval_validity_eng_survey' THEN 'РИИ,Достоверность'
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
		contr.expertise_result_date,
		
		l.base_application_id
				
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

	
ALTER VIEW application_modified_documents_list OWNER TO ;