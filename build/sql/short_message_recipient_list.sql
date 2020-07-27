-- VIEW: short_message_recipient_list

--DROP VIEW short_message_recipient_list;

CREATE OR REPLACE VIEW short_message_recipient_list AS
	SELECT	
		e.id AS recipient_id,	
		employees_ref(e) AS recipients_ref,
		departments_ref(d) AS departments_ref,
		e.name AS recipient_descr,
		d.name AS department_descr,
		person_init(e.name,FALSE) AS recipient_init,
		--ПРОБЛЕМА!!!
		coalesce(
			(SELECT logins.date_time_out IS NULL AND (now()-sessions.set_time)<'1 minute'::interval
			FROM logins
			LEFT JOIN sessions ON sessions.id=md5(session_id)
			WHERE logins.user_id=e.user_id AND logins.date_time_out IS NULL
			ORDER BY logins.date_time_in DESC LIMIT 1	
			),
		FALSE) AS is_online,
		
		short_message_recipient_states_ref(st) AS recipient_states_ref
		
	FROM employees AS e
	LEFT JOIN departments AS d ON d.id=e.department_id
	LEFT JOIN short_message_recipient_current_states AS cur_st ON cur_st.recipient_id=e.id
	LEFT JOIN short_message_recipient_states AS st ON st.id=cur_st.recipient_state_id
	ORDER BY d.name,e.name
	;
	
ALTER VIEW short_message_recipient_list OWNER TO ;
