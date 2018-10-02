-- View: user_view

--DROP VIEW user_profile;

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
		u.cades_load_timeout
	FROM users u;

ALTER TABLE user_profile OWNER TO ;
