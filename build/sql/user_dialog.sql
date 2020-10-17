-- VIEW: user_dialog

DROP VIEW user_dialog;

CREATE OR REPLACE VIEW user_dialog AS
	SELECT
		users.id,
		users.name,
		users.name_full,
		users.banned,
		users.email,
		users.role_id,
		time_zone_locales_ref(time_zone_locales) AS time_zone_locales_ref,
		users.phone_cel,
		users.color_palette,
		users.reminders_to_email,
		users.private_file,
		users.allow_ext_contracts
		
	FROM users
	LEFT JOIN time_zone_locales ON time_zone_locales.id=users.time_zone_locale_id
	;
	
ALTER VIEW user_dialog OWNER TO ;
