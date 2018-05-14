-- Function: applications_modif_primary_chain(in_id integer)

-- DROP FUNCTION applications_modif_primary_chain(in_id integer);

CREATE OR REPLACE FUNCTION applications_modif_primary_chain(in_id integer)
  RETURNS json AS
$$
	WITH RECURSIVE
		forward_ord AS (
			SELECT id,modif_primary_application_id, applications_ref(applications) AS app_ref
			FROM applications
			WHERE id = in_id
			
			UNION ALL

			SELECT app.id,app.modif_primary_application_id, applications_ref(app) AS app_ref
			FROM applications AS app
			JOIN forward_ord ON app.modif_primary_application_id = forward_ord.id
		),
	
		backward_ord AS (
			SELECT id,modif_primary_application_id, applications_ref(applications) AS app_ref
			FROM applications
			WHERE id = in_id
/*
			UNION ALL

			SELECT app.id,app.modif_primary_application_id, applications_ref(app) AS app_ref
			FROM applications AS app
			JOIN backward_ord ON app.id = backward_ord.modif_primary_application_id
*/			
		)

	SELECT
		json_build_object(
			'forward_ord',NULL,--(SELECT array_to_json(array_agg(app_ref)) FROM forward_ord),
			'backward_ord',(SELECT array_to_json(array_agg(app_ref)) FROM backward_ord)
		)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_modif_primary_chain(in_id integer) OWNER TO ;
