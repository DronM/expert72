
-- ******************* update 03/10/2018 14:11:13 ******************
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

-- ******************* update 03/10/2018 16:20:54 ******************
-- VIEW: applications_constr_name_list

--DROP VIEW applications_constr_name_list

CREATE OR REPLACE VIEW applications_constr_name_list AS
	SELECT
		DISTINCT constr_name AS name
		
	FROM applications
	ORDER BY constr_name
	;
	
ALTER VIEW applications_constr_name_list OWNER TO expert72;

-- ******************* update 03/10/2018 17:43:57 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30004',
		'Contract_Controller',
		NULL,
		'RepQuarter',
		'Отчеты',
		'Квартальный отчет',
		FALSE
		);
	