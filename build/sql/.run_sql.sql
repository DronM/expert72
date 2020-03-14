-- Function: form_product_types_positions(in_form_product_type_id int)

-- DROP FUNCTION form_product_types_positions(in_form_product_type_id int);

CREATE OR REPLACE FUNCTION form_product_types_positions(in_form_product_type_id int)
  RETURNS jsonb AS
$$
	SELECT 
		jsonb_agg(
			replace(substring(sub.o::text,2,length(sub.o::text)-2),'\"','"')::jsonb||jsonb_build_object('item',row_to_json(t))
		) AS positions
	FROM 	
	(
	SELECT
		jsonb_array_elements(item_positions) AS o
	FROM form_product_types
	WHERE id=in_form_product_type_id
	) AS sub
	LEFT JOIN form_product_items_list AS t ON (t.position->>'id')::int=(replace(substring(sub.o::text,2,length(sub.o::text)-2),'\"','"')::json->>'id')::int
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION form_product_types_positions(in_form_product_type_id int) OWNER TO expert72;
