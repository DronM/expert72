-- VIEW: employees_dialog

--DROP VIEW public.employees_dialog;

CREATE OR REPLACE VIEW public.employees_dialog AS
	SELECT
		t.id
		,t.name
		,t.picture_info
		,public.users_ref(users_join) AS users_ref
		,public.posts_ref(posts_join) AS posts_ref
		,public.departments_ref(departments_join) AS departments_ref
		,t.snils
		,(users_join.role_id='expert' OR users_join.role_id='expert_ext' OR users_join.role_id='boss' OR users_join.role_id='admin' OR users_join.role_id='lawyer') AS is_expert
	FROM public.employees AS t
	LEFT JOIN public.users AS users_join ON
		t.user_id=users_join.id
	LEFT JOIN public.departments AS departments_join ON
		t.department_id=departments_join.id
	LEFT JOIN public.posts AS posts_join ON
		t.post_id=posts_join.id
		
	ORDER BY
		t.id
	;
	
ALTER VIEW employees_dialog OWNER TO expert72;
