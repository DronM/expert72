-- VIEW: offices_list

--DROP VIEW applications_list;
--DROP VIEW offices_list;

CREATE OR REPLACE VIEW offices_list AS
	SELECT
		offices.*,
		clients_ref(clients) AS clients_ref,
		kladr_parse_addr(clients.post_address) AS address
	FROM offices
	LEFT JOIN clients ON clients.id=offices.client_id
	ORDER BY id
	;
	
ALTER VIEW offices_list OWNER TO ;
