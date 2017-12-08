-- FUNCTION: applications_client_list

--DROP FUNCTION applications_client_list(in_user_id int);

CREATE OR REPLACE FUNCTION applications_client_list(in_user_id int)
  RETURNS TABLE(
  	name text,
  	inn varchar(12),
  	kpp varchar(10),
  	ogrn varchar(20),
  	client_type client_types,
  	client_data jsonb
  )  AS
$BODY$

	SELECT DISTINCT ON (l.name)
		l.name,
		l.inn,
		l.kpp,
		l.ogrn,
		l.client_type,
		l.client_data
	FROM (
		SELECT DISTINCT ON (app.applicant->>'name')
			app.applicant->>'name' AS name,
			app.applicant->>'inn' AS inn,
			app.applicant->>'kpp' AS kpp,
			app.applicant->>'ogrn' AS ogrn,
			(app.applicant->>'client_type')::client_types AS client_type,
			app.applicant AS client_data
		FROM applications AS app
		WHERE app.user_id=in_user_id
	
		UNION ALL
	
		SELECT DISTINCT ON (app.customer->>'name')
			app.customer->>'name' AS name,
			app.customer->>'inn' AS inn,
			app.customer->>'kpp' AS kpp,
			app.customer->>'ogrn' AS ogrn,
			(app.customer->>'client_type')::client_types AS client_type,
			app.customer AS client_data
		FROM applications AS app
		WHERE app.user_id=in_user_id
		/*
		UNION ALL
		
		SELECT DISTINCT ON (contractor->>'name')
			contractor->>'name' AS name,
			contractor->>'inn' AS inn,
			contractor->>'kpp' AS kpp,
			contractor->>'ogrn' AS ogrn,
			(contractor->>'client_type')::client_types AS client_type,
			contractor AS client_data
		FROM jsonb_array_elements((SELECT ap.contractors FROM applications ap WHERE ap.user_id=in_user_id)) AS contractor		
		*/
	) AS l
	ORDER BY l.name
	;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_client_list(in_user_id int) OWNER TO ;
