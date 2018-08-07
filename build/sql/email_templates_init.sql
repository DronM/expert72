INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES ('reset_pwd','Пользователю [user] изменен пароль. Новый пароль [pwd]','Новый пароль','',array['user','pwd']);
INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES ('new_account','Создана новая учетная запись. Параметры учетной записи: логин: [user] пароль: [pwd]','Новая учетная запись','',array['user','pwd']);

INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES ('user_email_conf','Пользователю [user] необходимо подтвердить адрес электронной почты. Перейдите по ссылке: http://localhost/expert72/index.php?c=User_Controller&f=email_confirm&key=[key] Ссылка будет действовать в течении суток.','Подтверждение электр.почты.','',array['user','key']);

INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES (
	'new_app',
	'Новое заявление отправлено на проверку. Заявитель:[applicant], объект: [constr_name]. Ссылка на заявление http://localhost/expert72/index.php?c=Application_Controller&f=get_object&t=ApplicationDialog&mode=edit&v=Child&id=[id]',
	'Новое заявление',
	'',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"applicant","descr":"Заявитель"}},{"fields":{"id":"constr_name","descr":"Адрес строительства"},{"fields":{"id":"id","descr":"Идентификатор заявления"}}]'
	)	
);

INSERT INTO email_templates (email_type,template,mes_subject,comment_text,fields) VALUES (
	'app_change',
	'Ответы на замечания. Заявитель:[applicant], объект: [constr_name]. Ссылка на заявление http://localhost/expert72/index.php?c=Application_Controller&f=get_object&t=ApplicationDialog&mode=edit&v=Child&id=[id]',
	'Ответы на замечания',
	'',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"applicant","descr":"Заявитель"}},{"fields":{"id":"constr_name","descr":"Адрес строительства"},{"fields":{"id":"id","descr":"Идентификатор заявления"}}]'
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
	'Новое напоминание',
	'Отправляется при создании нового напоминания, если у сотрудника выставлен флаг "Дублировать напоминания на email"',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"content","descr":"Содержание"}},{"fields":{"id":"id","descr":"Идентификатор напоминания"},{"fields":{"id":"id","descr":"Идентификатор заявления"}}]'
	)
);

INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'out_mail_to_app',
	'Вам поступило новое входящее письмо. Тема:[subject]. Ссылка http://localhost/expert72/index.php?c=DocFlowInClient_Controller&f=get_object&t=DocFlowInClientDialog&v=Child&id=[id]',
	'Исходящее письмо по заявлению/контракту',
	'Отправляется при регистрации нового исходящего документа по заявлению/контракту, если у получателя выставлен флаг "Дублировать напоминания на email"',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"subject","descr":"Тема"}},{"fields":{"id":"id","descr":"Идентификатор исходящего документа"}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'contract_state_change',
	'Контракт №[contract_number] от [contract_date] перешел в статус [state]',
	'Смена статуса контракта',
	'Отправляется при изменении статуса контракта"',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"contract_number","descr":"Номер контракта"}},{"fields":{"id":"contract_date","descr":"Дата контракта"},{"fields":{"id":"state","descr":"Статус"}}]'
	)
);


{"id":"ReportTemplateField_Model","rows":[{"fields":{"id":"applicant","descr":"Заявитель"}},{"fields":{"id":"constr_name","descr":"Адрес строительства"},{"fields":{"id":"id","descr":"Идентификатор заявления"}}]}


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)
VALUES (
	'app_to_correction',
	'Заявление [app_number] от [app_date] возвращено на доработку. Необходимо исправить ошибки и отправить заявление на проверку до [end_date]',
	'Заявление на корректировку',
	'Отправляется при возврате заявления на редактирование',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"app_number","descr":"Номер заявления"}},{"fields":{"id":"app_date","descr":"Дата заявления"}},{"fields":{"id":"end_date","descr":"Дата окончания проверки заявления"}}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields
	)

VALUES (
	'contr_return',
	'Возврат подписанного контракта №[number]. Входящие документ http://192.168.1.134/index.php?c=DocFlowIn_Controller&f=get_object&t=DocFlowInDialog&v=Child&id=[doc_in_id]',
	'Возврат подписанного контракта',
	'Отправляется в отдел приема при возврате подписанного контракта',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"number","descr":"Номер контракта"}},{"fields":{"id":"doc_in_id","descr":"Идентификатор входящо документа"}}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields

	)

VALUES (
	'expert_work_change',
	'Изменение по экспертизе контракта №[contract_number], объект [constr_name] по разделу [section_name], эксперт [expert_name]',
	'Изменение по локальным заключениям',
	'Отправляется в главный отдел контракта при любом изменении в таблице экспертизы',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"contract_number","descr":"Номер контракта"}},{"fields":{"id":"constr_name","descr":"Объект контракта"}},{"fields":{"id":"section_name","descr":"Наименование раздела"}},{"fields":{"id":"expert_name","descr":"ФИО эксперта"}}]'
	)
);


INSERT INTO email_templates (
	email_type,
	template,
	mes_subject,comment_text,fields

	)

VALUES (
	'ca_update_error',
	'Во время обновления списка головных сертификатов произошла ошибка: [error]',
	'Ошибка обновления списка головных сертификатов',
	'Отправляется администратору при возникновении автоматического обновления',
	json_build_object(
		'id','ReportTemplateField_Model',
		'rows','[{"fields":{"id":"error"}]'
	)
);




