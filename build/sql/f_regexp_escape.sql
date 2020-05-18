CREATE OR REPLACE FUNCTION f_regexp_escape(text)
  RETURNS text  LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS
$func$
SELECT regexp_replace($1, '([!$()*+.:<=>?[\\\]^{|}-])', '\\\1', 'g')
$func$;

