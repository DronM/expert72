CREATE OR REPLACE FUNCTION grant_all_views(schema_name TEXT, role_name TEXT)
RETURNS VOID AS $func$
DECLARE view_name TEXT;
BEGIN
  FOR view_name IN
    SELECT viewname FROM pg_views WHERE schemaname = schema_name
  LOOP
    EXECUTE 'GRANT ALL PRIVILEGES ON ' || schema_name || '.' || view_name || ' TO ' || role_name || ';';
  END LOOP;

END; $func$ LANGUAGE PLPGSQL;
ALTER FUNCTION grant_all_views(schema_name TEXT, role_name TEXT) OWNER TO ;
