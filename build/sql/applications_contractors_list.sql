-- VIEW: applications_contractors_list

--DROP VIEW applications_contractors_list;

CREATE OR REPLACE VIEW applications_contractors_list AS
	SELECT 
		DISTINCT sub.contractors->>'name' AS name
	FROM (
		SELECT jsonb_array_elements(contractors) AS contractors
		FROM applications
		WHERE contractors IS NOT NULL
	) AS sub
	;
	
ALTER VIEW applications_contractors_list OWNER TO ;
