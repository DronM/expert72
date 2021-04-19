-- Function: public.conclusion_dictionary_detail_ref(conclusion_dictionary_detail)

-- DROP FUNCTION public.conclusion_dictionary_detail_ref(conclusion_dictionary_detail);

CREATE OR REPLACE FUNCTION public.conclusion_dictionary_detail_ref(conclusion_dictionary_detail)
  RETURNS json AS
$BODY$
	SELECT
		json_build_object(	
			'keys',json_build_object(
				'code',$1.code,'conclusion_dictionary_name',$1.conclusion_dictionary_name
				),	
			'descr',$1.descr||' ('||$1.code||')'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.conclusion_dictionary_detail_ref(conclusion_dictionary_detail)
  OWNER TO expert72;

