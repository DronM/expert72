-- VIEW: expert_conclusions_list

--DROP VIEW expert_conclusions_list;

CREATE OR REPLACE VIEW expert_conclusions_list AS
	SELECT
		t.id
		,contracts_ref(ct) AS contracts_ref
		,employees_ref(emp) AS experts_ref
		,t.date_time
		,t.last_modified
		,t.expert_id
		,t.contract_id
		,t.conclusion_type
		,t.conclusion_type_descr
		
	FROM expert_conclusions AS t
	LEFT JOIN contracts AS ct ON ct.id = t.contract_id
	LEFT JOIN employees AS emp ON emp.id = t.expert_id
	ORDER BY t.date_time DESC	
	;
	
ALTER VIEW expert_conclusions_list OWNER TO ;
