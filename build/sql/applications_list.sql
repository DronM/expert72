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
				END
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
		
		contr.contract_number
				
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
	
ALTER VIEW applications_list OWNER TO ;

