-- VIEW: user_view

DROP VIEW user_view;

CREATE OR REPLACE VIEW user_view AS
	SELECT
		u.*,
		tzl.name AS user_time_locale,
		employees_ref(emp) AS employees_ref
	FROM users u
	LEFT JOIN time_zone_locales tzl ON tzl.id=u.time_zone_locale_id
	LEFT JOIN employees emp ON emp.user_id=u.id
	;
	
ALTER VIEW user_view OWNER TO ;
