-- VIEW: out_mail_list

DROP VIEW out_mail_dialog;

CREATE OR REPLACE VIEW out_mail_dialog AS
	SELECT
		out_mail.*,
		employees_ref(employees) AS employees_ref,
		applications_ref(applications) AS applications_ref,
		users_ref(users) AS to_users_ref,
		files.attachments AS files		
	FROM out_mail
	LEFT JOIN employees ON employees.id=out_mail.employee_id
	LEFT JOIN users ON users.id=out_mail.to_user_id
	LEFT JOIN applications ON applications.id=out_mail.application_id
	LEFT JOIN (
		SELECT
			t.out_mail_id,
			json_agg(
				json_build_object(
					'file_id',t.file_id,
					'file_name',t.file_name,
					'file_size',t.file_size
				)
			) AS attachments			
		FROM out_mail_attachments AS t
		GROUP BY t.out_mail_id	
	) AS files ON files.out_mail_id = out_mail.id
	;
	
ALTER VIEW out_mail_dialog OWNER TO ;
