-- VIEW: client_list

DROP VIEW user_list;

CREATE OR REPLACE VIEW user_list AS
	SELECT
		users.id,
		users.name,
		users.name_full,
		users.email,
		phone_cel
	FROM users
	ORDER BY users.name
	;
	
ALTER VIEW user_list OWNER TO ;
