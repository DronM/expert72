-- VIEW: applications_customer_list

--DROP VIEW applications_customer_list;

CREATE OR REPLACE VIEW applications_customer_list AS
	SELECT
		DISTINCT (customer->>'name'::text) AS name
		
	FROM applications
	ORDER BY customer->>'name'::text
	;
	
ALTER VIEW applications_customer_list OWNER TO ;
