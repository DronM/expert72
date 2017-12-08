-- VIEW: user_dialog

--DROP VIEW user_dialog;

CREATE OR REPLACE VIEW user_dialog AS
	SELECT
		users.*,
		time_zone_locales.descr AS time_zone_locale_descr
	FROM users
	LEFT JOIN time_zone_locales ON time_zone_locales.id=users.time_zone_locale_id
	;
	
ALTER VIEW user_dialog OWNER TO ;
