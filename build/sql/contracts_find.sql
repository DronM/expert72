-- Function: contracts_find(in_contract_ext_id varchar(36), in_contract_number text, in_contract_date date)

-- DROP FUNCTION contracts_find(in_contract_ext_id varchar(36), in_contract_number text, in_contract_date date);

CREATE OR REPLACE FUNCTION contracts_find(in_contract_ext_id varchar(36), in_contract_number text, in_contract_date date)
  RETURNS int AS
$$
DECLARE
	res int;
BEGIN
	SELECT id INTO res FROM contracts WHERE contract_ext_id=in_contract_ext_id;
	IF res IS NULL THEN		
		SELECT id INTO res FROM contracts WHERE contract_number=in_contract_number AND contract_date=in_contract_date;
		IF res IS NULL THEN		
			UPDATE contracts SET contract_ext_id=in_contract_ext_id WHERE id=res;
		END IF;		
	END IF;
	
	RETURN res;
END;	
$$
  LANGUAGE plpgsql VOLATILE COST 100;
ALTER FUNCTION contracts_find(in_contract_ext_id varchar(36), in_contract_number text, in_contract_date date) OWNER TO ;
