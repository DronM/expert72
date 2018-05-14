-- Function: public.offices_ref(offices)

-- DROP FUNCTION public.offices_ref(offices);

CREATE OR REPLACE FUNCTION public.offices_ref(offices)
  RETURNS json AS
$BODY$
	SELECT
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',(SELECT clients.name||' '||kladr_parse_addr(clients.post_address) FROM offices LEFT JOIN clients ON clients.id=offices.client_id WHERE offices.id=$1.id)
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.offices_ref(offices)
  OWNER TO expert72;

