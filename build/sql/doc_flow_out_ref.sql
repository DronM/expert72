-- Function: public.doc_flow_out_ref(doc_flow_out)

-- DROP FUNCTION public.doc_flow_out_ref(doc_flow_out);

CREATE OR REPLACE FUNCTION public.doc_flow_out_ref(doc_flow_out)
  RETURNS json AS
$BODY$
	SELECT json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Исходящий документ '|| coalesce('№'||$1.reg_number,$1.subject||' (без рег.номера)')||' от '||to_char($1.date_time,'DD/MM/YY'),
			'dataType','doc_flow_out'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_flow_out_ref(doc_flow_out)
  OWNER TO ;

