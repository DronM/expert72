-- VIEW: user_view_lk

--DROP VIEW user_view_lk;

CREATE OR REPLACE VIEW user_view_lk AS
	SELECT
		u.*,
		tzl.name AS user_time_locale,
		employees_ref(emp) AS employees_ref,
		departments_ref(dep) AS departments_ref,
		(emp.id=dep.boss_employee_id) department_boss,
		
		CASE WHEN st.id IS NULL THEN pdfn_short_message_recipient_states_free()
		ELSE short_message_recipient_states_ref(st)
		END AS recipient_states_ref
	FROM users_lk u
	LEFT JOIN time_zone_locales tzl ON tzl.id=u.time_zone_locale_id
	LEFT JOIN employees emp ON emp.user_id=u.id
	LEFT JOIN departments dep ON dep.id=emp.department_id
	LEFT JOIN short_message_recipient_current_states cur_st ON cur_st.recipient_id=emp.id
	LEFT JOIN short_message_recipient_states st ON st.id=cur_st.recipient_state_id
	;
	
ALTER VIEW user_view_lk OWNER TO ;
