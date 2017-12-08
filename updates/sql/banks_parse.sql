-- Function: banks_parse(jsonb)

-- DROP FUNCTION banks_parse(jsonb);

CREATE OR REPLACE FUNCTION banks_parse(jsonb)
  RETURNS record AS
$$
	SELECT
		$1->>'acc_number' AS acc_number,
		banks.bik AS bank_bik,
		banks.name AS bank_name,
		banks.korshet AS bank_korshet,
		banks.adres AS bank_adres,
		banks.gor AS bank_gor
	FROM banks
	WHERE banks.bik=$1->'bank'->'RefType'->'keys'->>'bik'
	--WHERE banks.bik=((($1->>'bank')::jsonb->>'RefType')::jsonb->>'keys')::jsonb->>'bik'
	;
$$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION banks_parse(jsonb) OWNER TO ;
