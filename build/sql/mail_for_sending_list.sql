-- VIEW: mail_for_sending_list

--DROP VIEW mail_for_sending_list;

CREATE OR REPLACE VIEW mail_for_sending_list AS
	SELECT
		id,
		date_time,
		subject,
		from_addr,
		from_name,
		to_addr,
		to_name,
		sent,
		sent_date_time,
		email_type,
		coalesce((SELECT TRUE FROM mail_for_sending_attachments AS at WHERE at.mail_for_sending_id=mail_for_sending.id LIMIT 1),FALSE) AS attachments_exist,
		error_str
	FROM mail_for_sending
	ORDEr BY date_time DESC
	;
	
ALTER VIEW mail_for_sending_list OWNER TO ;
