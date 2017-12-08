-- VIEW: applications_list

--DROP VIEW applications_list;

CREATE OR REPLACE VIEW applications_list AS
	SELECT
		l.id,
		l.create_dt,
		l.constr_name,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		CASE
			WHEN st.state='sent' THEN
				bank_day_next(st.date_time::date,(SELECT const_application_check_days_val()))
			ELSE NULL
		END AS application_state_end_date,
		
		l.filled_percent,
		off.address AS office_descr
		
	FROM applications AS l
	LEFT JOIN offices_list AS off ON off.id=l.office_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_state_history t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=l.id
	LEFT JOIN application_state_history st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
		
	ORDER BY l.user_id,l.create_dt DESC
	;
	
ALTER VIEW applications_list OWNER TO ;

