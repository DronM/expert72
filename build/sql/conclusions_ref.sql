-- Function: public.conclusions_ref(conclusions)

-- DROP FUNCTION public.conclusions_ref(conclusions);

CREATE OR REPLACE FUNCTION public.conclusions_ref(conclusions)
  RETURNS json AS
$BODY$
	SELECT
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr',(SELECT 'Заключение от '||to_char(t.date_time) FROM conclusions t WHERE t.id=$1.id)
		);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.conclusions_ref(conclusions)
  OWNER TO expert72;

