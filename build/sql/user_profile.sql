-- View: user_view

DROP VIEW user_profile;

CREATE OR REPLACE VIEW user_profile AS 
	SELECT
		u.id,
		u.name,
		u.name_full,
		u.email,
		u.phone_cel,
		u.color_palette,
		u.reminders_to_email,
		u.cades_chunk_size,
		u.cades_load_timeout,
		u.win_message_style,
		CASE WHEN u.role_id<>'client' THEN emp.id
		ELSE NULL
		END AS employee_id
		
	FROM users u
	LEFT JOIN employees AS emp ON emp.user_id=u.id;

ALTER TABLE user_profile OWNER TO ;
