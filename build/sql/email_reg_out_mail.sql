-- Function: email_reg_out_mail(in_out_mail_id int)

--DROP FUNCTION email_reg_out_mail(in_out_mail_id int);

CREATE OR REPLACE FUNCTION email_reg_out_mail(in_out_mail_id int)
  RETURNS RECORD  AS
$BODY$
	SELECT
		'' AS mes_body,		
		
		CASE WHEN mail.to_addr_name LIKE '%<%>%' THEN
			trim(substring(mail.to_addr_name FROM position('<' in mail.to_addr_name)+1 FOR position('>' in mail.to_addr_name)-position('<' in mail.to_addr_name)-1))
		ELSE
			mail.to_addr_name
		END AS email,
		mail.subject AS mes_subject,
		''::text AS firm,
		
		CASE WHEN mail.to_addr_name LIKE '%<%>%' THEN
			trim(substring(mail.to_addr_name FROM 1 FOR position('<' in mail.to_addr_name)-1))
		ELSE
			''
		END AS client
	FROM out_mail AS mail
	WHERE mail.id=$1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_reg_out_mail(in_out_mail_id int) OWNER TO ;
