-- Function: contacts_add_persons(in_applocation_id int, in_parent_type data_types, in_parent_ind int, in_contact json)

-- DROP FUNCTION contacts_add_persons(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json)

CREATE OR REPLACE FUNCTION contacts_add_persons(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json)
  RETURNS void AS
$$
DECLARE
	i json;
    	ind int;
BEGIN
	
	ind = in_parent_ind;
	--HEAD
	IF (in_contact->'responsable_person_head' IS NOT NULL) THEN
		PERFORM contacts_insert(in_parent_id, in_parent_type, ind, (in_contact->>'responsable_person_head')::json,in_contact->>'name');
	END IF;
	
	--OTHER CONTACTS
	FOR i IN SELECT * FROM json_array_elements((SELECT (in_contact->>'responsable_persons')::json->'rows'))
	LOOP
		ind = ind + 1;
		PERFORM contacts_insert(in_parent_id, in_parent_type, ind,(i->>'fields')::json,in_contact->>'name');
	END LOOP;		

END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contacts_add_persons(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json) OWNER TO ;
