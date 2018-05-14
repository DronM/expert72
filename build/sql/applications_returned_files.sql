-- VIEW: applications_returned_files

--DROP VIEW applications_returned_files;

CREATE OR REPLACE VIEW applications_returned_files AS
	SELECT
		app.id
	FROM applications AS app
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_processes t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=app.id
	LEFT JOIN application_processes st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	WHERE st.state='returned' AND
	(
		(app.expertise_type IS NOT NULL AND st.date_time <= (now()-'3 months'::interval) )
		OR app.expertise_type IS NULL
	)
	;
	
ALTER VIEW applications_returned_files OWNER TO ;
