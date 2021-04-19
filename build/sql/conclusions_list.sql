-- VIEW: conclusions_list

DROP VIEW conclusions_list;

CREATE OR REPLACE VIEW conclusions_list AS
	SELECT
		t.id
		,t.create_dt
		,t.comment_text
		,t.contract_id
		,contracts_ref(ct) AS contracts_ref
		,t.employee_id
		,employees_ref(emp) AS employees_ref
		
	FROM conclusions AS t
	LEFT JOIN contracts AS ct ON ct.id = t.contract_id
	LEFT JOIN employees AS emp ON emp.id = t.employee_id
	ORDER BY t.create_dt DESC
	;
	
ALTER VIEW conclusions_list OWNER TO ;
