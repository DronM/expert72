-- Function: public.pdfn_doc_flow_types_app_expertise()

-- DROP FUNCTION public.pdfn_doc_flow_types_app_expertise();

CREATE OR REPLACE FUNCTION public.pdfn_doc_flow_types_app_expertise()
  RETURNS json AS
$BODY$
	SELECT doc_flow_types_ref(doc_flow_types) FROM doc_flow_types WHERE id=18;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_doc_flow_types_app_expertise()
  OWNER TO expert72;

