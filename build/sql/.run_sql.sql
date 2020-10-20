-- VIEW: variant_storages_list

DROP VIEW variant_storages_list;

--ALTER TABLE variant_storages ADD COLUMN id serial
/*ALTER TABLE public.variant_storages ADD COLUMN id serial;
ALTER TABLE public.variant_storages DROP CONSTRAINT variant_storages_pkey;
ALTER TABLE public.variant_storages ADD CONSTRAINT variant_storages_pkey PRIMARY KEY (id);
*/

CREATE OR REPLACE VIEW variant_storages_list AS
	SELECT
		id,
		user_id,
		storage_name,
		variant_name
	FROM variant_storages
	;
	
ALTER VIEW variant_storages_list OWNER TO expert72;

