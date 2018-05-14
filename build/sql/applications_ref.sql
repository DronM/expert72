--DROP FUNCTION applications_ref(applications)

--Refrerece type
CREATE OR REPLACE FUNCTION applications_ref(applications)
  RETURNS json AS
$$
	SELECT 
		json_build_object(	
			'keys',json_build_object(
				'id',$1.id    
				),	
			'descr','Заявление №'||$1.id||' от '||to_char($1.create_dt,'DD/MM/YY'),
			'dataType','applications'
		)
	;
$$
  LANGUAGE sql VOLATILE COST 100;
ALTER FUNCTION applications_ref(applications) OWNER TO ;	

