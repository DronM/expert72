-- VIEW: application_processes_list

--DROP VIEW application_processes_list;

CREATE OR REPLACE VIEW application_processes_list AS
	SELECT
		proc.*,
		contracts.id As contract_id,
		contracts_ref(contracts) AS contracts_ref,
		applications_ref((SELECT applications FROM applications WHERE applications.id=proc.application_id)) AS applications_ref,
		empl.id AS employee_id,
		employees_ref(empl) AS employees_ref
		
	FROM application_processes AS proc
	LEFT JOIN contracts ON contracts.application_id=proc.application_id
	LEFT JOIN employees AS empl ON empl.user_id=proc.user_id
	;
	
ALTER VIEW application_processes_list OWNER TO ;
