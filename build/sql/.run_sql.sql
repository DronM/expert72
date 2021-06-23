-- VIEW: conclusions_dialog

DROP VIEW conclusions_dialog;

CREATE OR REPLACE VIEW conclusions_dialog AS
	SELECT
		t.id
		,t.create_dt
		,t.comment_text
		,t.contract_id
		,contracts_ref(ct) AS contracts_ref
		,t.employee_id
		,employees_ref(emp) AS employees_ref
		,t.content
		
	FROM conclusions AS t
	LEFT JOIN contracts AS ct ON ct.id = t.contract_id
	LEFT JOIN employees AS emp ON emp.id = t.employee_id
	;
	
ALTER VIEW conclusions_dialog OWNER TO expert72;
