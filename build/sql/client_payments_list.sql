-- VIEW: client_payments_list

--DROP VIEW client_payments_list;

CREATE OR REPLACE VIEW client_payments_list AS
	SELECT
		pm.id,
		clients_ref(cl) AS clients_ref,
		contracts_ref(contr) AS contracts_ref,
		pm.pay_date,
		pm.total,
		contr.client_id,
		pm.contract_id,
		pm.pay_docum_date,
		pm.pay_docum_number
		
	FROM client_payments AS pm	
	LEFT JOIN contracts AS contr ON contr.id=pm.contract_id
	LEFT JOIN clients AS cl ON cl.id=contr.client_id
	ORDER BY pm.pay_date DESC
	;
	
ALTER VIEW client_payments_list OWNER TO ;
