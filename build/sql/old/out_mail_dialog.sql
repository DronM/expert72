-- VIEW: out_mail_list

--DROP VIEW out_mail_dialog;

CREATE OR REPLACE VIEW out_mail_dialog AS
	SELECT
		out_mail.*,
		employees_ref(employees) AS employees_ref,
		applications_ref(applications) AS applications_ref,
		users_ref(users) AS to_users_ref,
		files.attachments AS files,
		mail_types_ref(mail_types) AS mail_types_ref,
		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt
				
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
	
	LEFT JOIN mail_types ON mail_types.id=out_mail.mail_type_id
	LEFT JOIN (
		SELECT t.out_mail_id,count(*) AS cnt
		FROM out_mail_attachments AS t
		GROUP BY t.out_mail_id
	) AS at ON at.out_mail_id=out_mail.id
	LEFT JOIN (
		SELECT
			t.out_mail_id,
			max(t.date_time) AS date_time
		FROM out_mail_state_history t
		GROUP BY t.out_mail_id
	) AS h_max ON h_max.out_mail_id=out_mail.id
	LEFT JOIN out_mail_state_history st
		ON st.out_mail_id=h_max.out_mail_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW out_mail_dialog OWNER TO ;
