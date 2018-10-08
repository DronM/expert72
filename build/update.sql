
-- ******************* update 07/10/2018 07:46:07 ******************

		ALTER TABLE file_verifications ADD COLUMN user_id int REFERENCES users(id);


-- ******************* update 07/10/2018 07:49:48 ******************

		ALTER TABLE doc_flow_attachments ADD COLUMN employee_id int REFERENCES employees(id);

