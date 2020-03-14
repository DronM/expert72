-- Function: public.pdfn_services_modified_documents()

-- DROP FUNCTION public.pdfn_services_modified_documents();

CREATE OR REPLACE FUNCTION public.pdfn_services_modified_documents()
  RETURNS json AS
$BODY$
	SELECT services_ref(services) FROM services WHERE id=6;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_services_modified_documents()
  OWNER TO ;

