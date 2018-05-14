-- Function: check_id_existance(data_types,int)

-- DROP FUNCTION check_id_existance(data_types,int);

CREATE OR REPLACE FUNCTION check_id_existance(data_types,int)
  RETURNS boolean AS
$BODY$
DECLARE
	res boolean;
BEGIN
	IF $1 IS NOT NULL AND $2 IS NOT NULL AND $2>0 THEN
		EXECUTE format('SELECT TRUE FROM %I WHERE id=%s',$1,$2) INTO res;
	ELSE
		res = TRUE;
	END IF;
	/*
	IF coalesce(res,FALSE) = FALSE THEN
		RAISE EXCEPTION 'q=%',format('SELECT TRUE FROM %I WHERE id=%s',$1,$2);
	END IF;
	*/
	RETURN coalesce(res,FALSE);	 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION check_id_existance(data_types,int) OWNER TO ;
