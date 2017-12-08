-- Function: kladr_parse_addr(address jsonb)

-- DROP FUNCTION kladr_parse_addr(address jsonb);

CREATE OR REPLACE FUNCTION kladr_parse_addr(address jsonb)
  RETURNS text AS
$BODY$
	SELECT
		CASE WHEN ((address->>'region')::jsonb->>'RefType')::jsonb->>'keys' IS NOT NULL THEN ((address->>'region')::jsonb->>'RefType')::jsonb->>'descr' ELSE '' END
		||CASE WHEN ((address->>'raion')::jsonb->>'RefType')::jsonb->>'keys' IS NOT NULL THEN ', '|| (((address->>'raion')::jsonb->>'RefType')::jsonb->>'descr') ELSE '' END
		||CASE WHEN ((address->>'naspunkt')::jsonb->>'RefType')::jsonb->>'keys' IS NOT NULL THEN ', '|| (((address->>'naspunkt')::jsonb->>'RefType')::jsonb->>'descr') ELSE '' END
		||CASE WHEN ((address->>'gorod')::jsonb->>'RefType')::jsonb->>'keys' IS NOT NULL THEN ', '|| (((address->>'gorod')::jsonb->>'RefType')::jsonb->>'descr') ELSE '' END
		||CASE WHEN ((address->>'ulitsa')::jsonb->>'RefType')::jsonb->>'keys' IS NOT NULL THEN ', '|| (((address->>'ulitsa')::jsonb->>'RefType')::jsonb->>'descr') ELSE '' END
		||CASE WHEN address->>'dom' IS NOT NULL THEN ', '||(address->>'dom') ELSE '' END
		||CASE WHEN address->>'korpus' IS NOT NULL THEN ', '||(address->>'korpus') ELSE '' END
		||CASE WHEN address->>'kvartira' IS NOT NULL THEN ', '||(address->>'kvartira') ELSE '' END
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION kladr_parse_addr(address jsonb) OWNER TO ;

