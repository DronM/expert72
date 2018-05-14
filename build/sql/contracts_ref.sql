-- Function: public.contracts_ref(contracts)

-- DROP FUNCTION public.contracts_ref(contracts);

CREATE OR REPLACE FUNCTION public.contracts_ref(contracts)
  RETURNS json AS
$BODY$
	SELECT
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Контракт №'||coalesce($1.expertise_result_number,coalesce($1.reg_number,$1.id::text))||' от '||to_char($1.date_time,'DD/MM/YY'),
			'dataType','contracts'
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.contracts_ref(contracts)
  OWNER TO expert72;

