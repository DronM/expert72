-- VIEW: clients_dialog

--DROP VIEW clients_dialog;

CREATE OR REPLACE VIEW clients_dialog AS
	SELECT
		clients.*,
		contacts_get_persons(clients.id,'clients') AS responsable_persons
	FROM clients
	;
	
ALTER VIEW clients_dialog OWNER TO ;
