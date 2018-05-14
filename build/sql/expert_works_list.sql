-- VIEW: expert_works_list

--DROP VIEW expert_works_list;

CREATE OR REPLACE VIEW expert_works_list AS
	SELECT
		expert_works.*,
		employees_ref(employees) AS experts_ref
	FROM expert_works
	LEFT JOIN employees ON employees.id=expert_works.expert_id
	ORDER BY expert_works.contract_id,expert_works.section_id,expert_works.date_time DESC,employees.name
	;
	
ALTER VIEW expert_works_list OWNER TO ;
