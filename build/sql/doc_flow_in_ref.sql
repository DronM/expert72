-- Function: public.doc_flow_in_ref(doc_flow_in)

-- DROP FUNCTION public.doc_flow_in_ref(doc_flow_in);

CREATE OR REPLACE FUNCTION public.doc_flow_in_ref(doc_flow_in)
  RETURNS json AS
$BODY$
	SELECT 
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Входящий документ '||coalesce('№'||$1.reg_number,$1.subject||' (без рег.номера)')||' от '||to_char($1.date_time,'DD/MM/YY'),
			'dataType','doc_flow_in'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_flow_in_ref(doc_flow_in)
  OWNER TO expert72;

