UPDATE public.const_client_download_file_types SET val_type='JSON'

DROP VIEW out_mail_list;
DROP VIEW out_mail_dialog;
ALTER TABLE out_mail DROP COLUMN to_addr;
ALTER TABLE out_mail DROP COLUMN to_name;
ALTER TABLE out_mail ADD COLUMN to_addr_name  varchar(250);
	DROP INDEX IF EXISTS out_mail_to_addr_name_idx;
	CREATE INDEX out_mail_to_addr_name_idx
	ON out_mail
	(lower(to_addr_name));



-- ******************* update 11/12/2017 18:04:45 ******************
DELETE FROM out_mail_attachments;
DELETE FROM out_mail;
DROP INDEX IF EXISTS out_mail_reg_number_idx;
	CREATE UNIQUE INDEX out_mail_reg_number_idx
	ON out_mail
	(reg_number);