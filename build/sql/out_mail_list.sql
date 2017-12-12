-- VIEW: out_mail_list

--DROP VIEW out_mail_list;

CREATE OR REPLACE VIEW out_mail_list AS
	SELECT
		out_mail.id,
		out_mail.reg_number,
		out_mail.date_time, 
		out_mail.subject,
		employees_ref(employees) AS employees_ref,
		applications_ref(applications) AS applications_ref,
		users_ref(users) AS to_users_ref,
		out_mail.to_addr_name,
		out_mail.sent,
		(at.cnt>0) AS attachments_exist
	FROM out_mail
	LEFT JOIN employees ON employees.id=out_mail.employee_id
	LEFT JOIN users ON users.id=out_mail.to_user_id
	LEFT JOIN applications ON applications.id=out_mail.application_id
	LEFT JOIN (
		SELECT t.out_mail_id,count(*) AS cnt
		FROM out_mail_attachments AS t
		GROUP BY t.out_mail_id
	) AS at ON at.out_mail_id=out_mail.id
	ORDER BY out_mail.date_time DESC
	;
	
ALTER VIEW out_mail_list OWNER TO ;
