-- Function: public.applications_client_descr(jsonb)

-- DROP FUNCTION public.applications_client_descr(jsonb);

CREATE OR REPLACE FUNCTION public.applications_client_descr(jsonb)
  RETURNS text AS
$BODY$	
	SELECT
		CASE
			WHEN ($1->>'client_type')::client_types='enterprise'::client_types THEN
				($1->>'name')::text|| ' '|| (coalesce($1->>'inn',''))::text||
					CASE WHEN $1->>'inn' IS NOT NULL THEN '/'|| (coalesce($1->>'kpp',''))::text ELSE '' END||
					CASE WHEN $1->>'ogrn' IS NOT NULL THEN ' ОРГН:'||($1->>'ogrn')::text ELSE '' END
			WHEN ($1->>'client_type')::client_types='pboul'::client_types THEN
				($1->>'name_full')::text|| ', '|| (coalesce($1->>'ogrn',''))::text
			ELSE
				($1->>'name_full')::text
		END
	;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.applications_client_descr(jsonb)
  OWNER TO expert72;

