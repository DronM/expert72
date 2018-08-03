-- VIEW: offices_bank_acc_list

-- DROP VIEW offices_bank_acc_list;

CREATE OR REPLACE VIEW offices_bank_acc_list AS
	SELECT
		off.acc->>'acc_number' AS acc_number,
		off.acc->>'bank_descr' AS bank_descr
	FROM (
	SELECT
		jsonb_array_elements(clients.bank_accounts->'rows')->'fields' AS acc
	FROM clients WHERE clients.id IN (SELECT o.client_id FROM offices o)
	) AS off
	;
	
ALTER VIEW offices_bank_acc_list OWNER TO ;
