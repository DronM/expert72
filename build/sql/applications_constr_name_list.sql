-- VIEW: applications_constr_name_list

--DROP VIEW applications_constr_name_list

CREATE OR REPLACE VIEW applications_constr_name_list AS
	SELECT
		DISTINCT constr_name AS name
		
	FROM applications
	ORDER BY constr_name
	;
	
ALTER VIEW applications_constr_name_list OWNER TO ;
