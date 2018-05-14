-- Function: public.pdfn_doc_flow_types_app_resp()

-- DROP FUNCTION public.pdfn_doc_flow_types_app_resp();

CREATE OR REPLACE FUNCTION public.pdfn_doc_flow_types_app_resp()
  RETURNS integer AS
$BODY$
	SELECT 2;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_doc_flow_types_app_resp() OWNER TO ;

