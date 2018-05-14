-- Function: public.doc_flow_in_ref(doc_flow_in)

-- DROP FUNCTION public.doc_flow_in_ref(doc_flow_in);

CREATE OR REPLACE FUNCTION public.doc_flow_examinations_ref(doc_flow_examinations)
  RETURNS json AS
$BODY$
	SELECT 
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Рассмотрение №'||$1.id||' от '||to_char($1.date_time,'DD/MM/YY'),
			'dataType','doc_flow_examinations'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_flow_examinations_ref(doc_flow_examinations)
  OWNER TO expert72;

