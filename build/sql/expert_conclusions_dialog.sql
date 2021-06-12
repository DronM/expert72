-- VIEW: expert_conclusions_dialog

--DROP VIEW expert_conclusions_dialog;

CREATE OR REPLACE VIEW expert_conclusions_dialog AS
	SELECT
		t.id
		,contracts_ref(ct) AS contracts_ref
		,employees_ref(emp) AS experts_ref
		,t.date_time
		,t.last_modified
		
		,t.conclusion
		,t.expert_id
		,t.conclusion_type
		,t.conclusion_type_descr
		
		--global for filter
		,ct.main_expert_id AS contract_main_expert_id
		
	FROM expert_conclusions AS t
	LEFT JOIN contracts AS ct ON ct.id = t.contract_id
	LEFT JOIN employees AS emp ON emp.id = t.expert_id
	;
	
ALTER VIEW expert_conclusions_dialog OWNER TO ;
