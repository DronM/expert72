INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES ('reset_pwd','������������ [user] ������� ������. ����� ������ [pwd]','����� ������','',array['user','pwd']);
INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES ('new_account','������� ����� ������� ������. ��������� ������� ������: �����: [user] ������: [pwd]','����� ������� ������','',array['user','pwd']);

INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES ('user_email_conf','������������ [user] ���������� ����������� ����� ����������� �����. ��������� �� ������: http://localhost/expert72/index.php?c=User_Controller&f=email_confirm&key=[key] ������ ����� ����������� � ������� �����.','������������� ������.�����.','',array['user','key']);

INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES (
	'new_app',
	'����� ��������� ���������� �� ��������. ���������:[applicant], ������: [constr_name]. ������ �� ��������� http://localhost/expert72/index.php?c=Application_Controller&f=get_object&t=ApplicationDialog&mode=edit&v=Child&id=[id]',
	'����� ���������',
	'',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"applicant","descr":"���������"}},{"fields":{"id":"constr_name","descr":"����� �������������"},{"fields":{"id":"id","descr":"������������� ���������"}}]'
	)	
);

INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES (
	'app_change',
	'������ �� ���������. ���������:[applicant], ������: [constr_name]. ������ �� ��������� http://localhost/expert72/index.php?c=Application_Controller&f=get_object&t=ApplicationDialog&mode=edit&v=Child&id=[id]',
	'������ �� ���������',
	'',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"applicant","descr":"���������"}},{"fields":{"id":"constr_name","descr":"����� �������������"},{"fields":{"id":"id","descr":"������������� ���������"}}]'
	)
);
INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'new_remind',
	'[content], http://localhost/expert72/index.php?c=Reminder_Controller&f=get_object&t=Reminder&v=Child&id=[id]',
	'����� �����������',
	'������������ ��� �������� ������ �����������, ���� � ���������� ��������� ���� "����������� ����������� �� email"',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"content","descr":"����������"}},{"fields":{"id":"id","descr":"������������� �����������"},{"fields":{"id":"id","descr":"������������� ���������"}}]'
	)
);

INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'out_mail_to_app',
	'��� ��������� ����� �������� ������. ����:[subject]. ������ http://localhost/expert72/index.php?c=DocFlowInClient_Controller&f=get_object&t=DocFlowInClientDialog&v=Child&id=[id]',
	'��������� ������ �� ���������/���������',
	'������������ ��� ����������� ������ ���������� ��������� �� ���������/���������, ���� � ���������� ��������� ���� "����������� ����������� �� email"',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"subject","descr":"����"}},{"fields":{"id":"id","descr":"������������� ���������� ���������"}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'contract_state_change',
	'�������� �[contract_number] �� [contract_date] ������� � ������ [state]',
	'����� ������� ���������',
	'������������ ��� ��������� ������� ���������"',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"contract_number","descr":"����� ���������"}},{"fields":{"id":"contract_date","descr":"���� ���������"},{"fields":{"id":"state","descr":"������"}}]'
	)
);


{"id":"ReportTemplateField_Model","rows":[{"fields":{"id":"applicant","descr":"���������"}},{"fields":{"id":"constr_name","descr":"����� �������������"},{"fields":{"id":"id","descr":"������������� ���������"}}]}


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'app_to_correction',
	'��������� [app_number] �� [app_date] ���������� �� ���������. ���������� ��������� ������ � ��������� ��������� �� �������� �� [end_date]',
	'��������� �� �������������',
	'������������ ��� �������� ��������� �� ��������������',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"app_number","descr":"����� ���������"}},{"fields":{"id":"app_date","descr":"���� ���������"}},{"fields":{"id":"end_date","descr":"���� ��������� �������� ���������"}}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)

VALUES (
	'contr_return',
	'������� ������������ ��������� �[number]. �������� �������� http://192.168.1.134/index.php?c=DocFlowIn_Controller&f=get_object&t=DocFlowInDialog&v=Child&id=[doc_in_id]',
	'������� ������������ ���������',
	'������������ � ����� ������ ��� �������� ������������ ���������',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"number","descr":"����� ���������"}},{"fields":{"id":"doc_in_id","descr":"������������� ������� ���������"}}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields

	)

VALUES (
	'expert_work_change',
	'��������� �� ���������� ��������� �[contract_number], ������ [constr_name] �� ������� [section_name], ������� [expert_name]',
	'��������� �� ��������� �����������',
	'������������ � ������� ����� ��������� ��� ����� ��������� � ������� ����������',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"contract_number","descr":"����� ���������"}},{"fields":{"id":"constr_name","descr":"������ ���������"}},{"fields":{"id":"section_name","descr":"������������ �������"}},{"fields":{"id":"expert_name","descr":"��� ��������"}}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields

	)

VALUES (
	'ca_update_error',
	'�� ����� ���������� ������ �������� ������������ ��������� ������: [error]',
	'������ ���������� ������ �������� ������������',
	'������������ �������������� ��� ������������� ��������������� ����������',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"error"}]'
	)
);



INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields

	)

VALUES (
	'warn_expert_work_end',
	'[end_date] ������������� ���� ���������� ����� �� ��������� [contract_number] �� ������� [constr_name]',
	'��������� ����� ���������� �����',
	'������������ ������� ���������',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"end_date","descr":"���� ��������� �����"}
			,{"fields":{"id":"contract_number","descr":"����� ���������"}
			,{"fields":{"id":"contract_date","descr":"���� ���������"}
			,{"fields":{"id":"user_name","descr":"��� ������������"}
			,{"fields":{"id":"applicant","descr":"��������"}
			,{"fields":{"id":"constr_name","descr":"������"}
			]'
	)
);



INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields

	)

VALUES (
	'warn_work_end',
	'[end_date] ������������� ���� ������ ���������� �� ��������� [contract_number] �� ������� [constr_name]',
	'��������� ����� ������ ����������',
	'������������ ������� ���������',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"end_date","descr":"���� ��������� �����"}
			,{"fields":{"id":"contract_number","descr":"����� ���������"}
			,{"fields":{"id":"contract_date","descr":"���� ���������"}
			,{"fields":{"id":"user_name","descr":"��� ������������"}
			,{"fields":{"id":"applicant","descr":"��������"}
			,{"fields":{"id":"constr_name","descr":"������"}
			]'
	)
);






