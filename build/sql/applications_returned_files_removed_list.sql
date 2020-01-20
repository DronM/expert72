-- VIEW: applications_returned_files_removed_list

--DROP VIEW applications_returned_files_removed_list;

CREATE OR REPLACE VIEW applications_returned_files_removed_list AS
	SELECT
		t.application_id,
		t.date_time,
		applications_ref(app) AS applications_ref
		
	FROM applications_returned_files_removed AS t
	LEFT JOIN applications AS app ON app.id=t.application_id
	ORDER BY date_time DESC
	;
	
ALTER VIEW applications_returned_files_removed_list OWNER TO ;
