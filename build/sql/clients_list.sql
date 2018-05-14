-- VIEW: clients_list

--DROP VIEW clients_list;

CREATE OR REPLACE VIEW clients_list AS
	SELECT
		clients.id ,
		clients.name,
		clients.inn,
		clients.kpp,
		clients.user_id
	FROM clients
	ORDER BY clients.name
	;
	
ALTER VIEW clients_list OWNER TO ;
