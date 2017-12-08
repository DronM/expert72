-- View: user_view

--DROP VIEW user_profile;

CREATE OR REPLACE VIEW user_profile AS 
	SELECT
		u.id,
		u.name,
		u.email,
		u.phone_cel
	FROM users u;

ALTER TABLE user_profile OWNER TO ;
