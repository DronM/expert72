-- Function: contacts_get_persons(in_parent_id int, in_parent_type data_types)

-- DROP FUNCTION contacts_get_persons(in_parent_id int, in_parent_type data_types);

CREATE OR REPLACE FUNCTION contacts_get_persons(in_parent_id int, in_parent_type data_types)
  RETURNS json AS
$$
	SELECT
		json_build_object(
			'id','ClientResponsablePerson_Model',
			'rows',
			coalesce(
				json_agg(
					json_build_object(
						'fields',
						json_build_object(
							'id',contacts.parent_ind,
							'name',contacts.name,
							'post',contacts.post,
							'email',contacts.email,
							'tel',contacts.tel,
							'person_type',contacts.person_type,
							'dep',contacts.dep
						)
					)
				),
				'[]'
			)
		)
	FROM contacts
	WHERE contacts.parent_id=$1 AND contacts.parent_type = $2;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION contacts_get_persons(in_parent_id int, in_parent_type data_types) OWNER TO ;
