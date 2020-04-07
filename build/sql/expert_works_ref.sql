-- Function: public.doc_flow_in_ref(doc_flow_in)

-- DROP FUNCTION public.doc_flow_in_ref(doc_flow_in);

CREATE OR REPLACE FUNCTION public.expert_works_ref(expert_works)
  RETURNS json AS
$BODY$
	SELECT 
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Локальное закл. от '||to_char($1.date_time,'DD/MM/YY'),
			'dataType','expert_works'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.expert_works_ref(expert_works)
  OWNER TO expert72;

