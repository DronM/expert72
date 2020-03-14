-- Function: public.pdfn_services_expert_maintenance()

-- DROP FUNCTION public.pdfn_services_expert_maintenance();

CREATE OR REPLACE FUNCTION public.pdfn_services_expert_maintenance()
  RETURNS json AS
$BODY$
	SELECT services_ref(services) FROM services WHERE id=5;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_services_expert_maintenance()
  OWNER TO ;

