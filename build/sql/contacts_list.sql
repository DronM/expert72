-- VIEW: contacts_list

--DROP VIEW contacts_list;

CREATE OR REPLACE VIEW contacts_list AS
	SELECT
		name,
		email,
		tel,
		post,
		firm_name,
		dep,
		contact,
		CASE WHEN firm_name IS NOT NULL THEN firm_name||' ' ELSE '' END ||
		CASE WHEN dep IS NOT NULL THEN dep||' ' ELSE '' END ||
		CASE WHEN post IS NOT NULL THEN post||' ' ELSE '' END ||
		CASE WHEN name IS NOT NULL THEN name||' ' ELSE '' END ||		
		CASE WHEN tel IS NOT NULL THEN format_cel_phone(tel::text) ELSE '' END||
		CASE WHEN email IS NOT NULL THEN '<'||email||'>' ELSE '' END
		AS contact_descr
	FROM contacts
	;
	
ALTER VIEW contacts_list OWNER TO ;
