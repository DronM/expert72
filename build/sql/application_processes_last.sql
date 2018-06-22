-- Function: application_processes_last(in_application_id int)

-- DROP FUNCTION application_processes_last(in_application_id int);

CREATE OR REPLACE FUNCTION application_processes_last(in_application_id int)
  RETURNS application_states AS
$$
	SELECT
		state
	FROM application_processes
	WHERE application_id=in_application_id
	ORDER BY date_time DESC
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION application_processes_last(in_application_id int) OWNER TO ;
