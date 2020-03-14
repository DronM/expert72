-- VIEW: applications_for_expert_maintenance_list

--DROP VIEW applications_for_expert_maintenance_list;

CREATE OR REPLACE VIEW applications_for_expert_maintenance_list AS
	SELECT
		l.id,
		l.create_dt,
		applications_ref(l)->>'descr'||',контр.№'||contr.contract_number||',эксп.закл.№'||contr.expertise_result_number AS select_descr,
		l.user_id,
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
		contr.contract_number,
		contr.contract_date,
		contr.expertise_result_number,
		contr.expertise_result_date
		
	FROM applications AS l
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
	WHERE (st.state = 'archive' OR 	st.state = 'closed' OR st.state = 'expertise')
		AND l.service_type <> 'expert_maintenance'
		AND l.service_type <> 'modified_documents'
	
	ORDER BY l.user_id,l.create_dt DESC
	;
	
ALTER VIEW applications_for_expert_maintenance_list OWNER TO ;

