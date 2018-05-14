-- Function: contacts_insert(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json,in_firm text)

-- DROP FUNCTION contacts_insert(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json,in_firm text)

CREATE OR REPLACE FUNCTION contacts_insert(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json,in_firm text)
  RETURNS void AS
$$
BEGIN
--RAISE EXCEPTION 'NAME=%',in_contact->>'name';
	INSERT INTO contacts (
		parent_id,
		parent_type,
		parent_ind,
		name,
		email,
		tel,
		post,
		firm_name,
		dep,
		person_type
		) VALUES (
			in_parent_id,
			in_parent_type,
			in_parent_ind,
			in_contact->>'name',
			in_contact->>'email',
			in_contact->>'tel',
			in_contact->>'post',
			in_firm,
			in_contact->>'dep',
			(in_contact->>'person_type')::responsable_person_types
		)
	ON CONFLICT
	DO NOTHING;
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION contacts_insert(in_parent_id int, in_parent_type data_types, in_parent_ind int, in_contact json,in_firm text) OWNER TO ;
