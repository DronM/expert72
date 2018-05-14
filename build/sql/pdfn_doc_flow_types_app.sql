-- Function: pdfn_doc_flow_types_app()

-- DROP FUNCTION pdfn_doc_flow_types_app();

CREATE OR REPLACE FUNCTION pdfn_doc_flow_types_app()
  RETURNS int AS
$$
	SELECT 1;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION pdfn_doc_flow_types_app() OWNER TO ;
