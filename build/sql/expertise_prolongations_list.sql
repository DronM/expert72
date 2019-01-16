-- VIEW: expertise_prolongations_list

--DROP VIEW expertise_prolongations_list;

CREATE OR REPLACE VIEW expertise_prolongations_list AS
	SELECT
		t.*,
		employees_ref(e) AS employees_ref,
		contracts_ref(ct) AS contracts_ref
	FROM expertise_prolongations AS t
	LEFT JOIN employees AS e ON e.id=t.employee_id
	LEFT JOIN contracts AS ct ON ct.id=t.contract_id
	;
	
ALTER VIEW expertise_prolongations_list OWNER TO ;
