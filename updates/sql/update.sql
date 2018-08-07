-- ******************* update 04/08/2018 06:39:08 ******************

					ALTER TYPE email_types ADD VALUE 'ca_update_error';
	/* function */
	CREATE OR REPLACE FUNCTION enum_email_types_val(email_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='new_account'::email_types AND $2='ru'::locales THEN 'Новый акаунт'
		WHEN $1='reset_pwd'::email_types AND $2='ru'::locales THEN 'Установка пароля'
		WHEN $1='user_email_conf'::email_types AND $2='ru'::locales THEN 'Подтверждение пароля'
		WHEN $1='out_mail'::email_types AND $2='ru'::locales THEN 'Исходящее письмо'
		WHEN $1='new_app'::email_types AND $2='ru'::locales THEN 'Новое заявление'
		WHEN $1='app_change'::email_types AND $2='ru'::locales THEN 'Ответы на замечания'
		WHEN $1='new_remind'::email_types AND $2='ru'::locales THEN 'Новая задача'
		WHEN $1='out_mail_to_app'::email_types AND $2='ru'::locales THEN 'Исходящее письмо по заявлению/контракту'
		WHEN $1='contract_state_change'::email_types AND $2='ru'::locales THEN 'Смена статуса контракта'
		WHEN $1='app_to_correction'::email_types AND $2='ru'::locales THEN 'Возврат заявления на корректировку'
		WHEN $1='contr_return'::email_types AND $2='ru'::locales THEN 'Возврат подписанного контракта'
		WHEN $1='expert_work_change'::email_types AND $2='ru'::locales THEN 'Изменния по локальным заключениям'
		WHEN $1='ca_update_error'::email_types AND $2='ru'::locales THEN 'Ошибка обновления головных сертификатов'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_email_types_val(email_types,locales) OWNER TO expert72;		
		
-- ******************* update 04/08/2018 06:43:15 ******************

					ALTER TYPE email_types ADD VALUE 'ca_update_error';
	/* function */
	CREATE OR REPLACE FUNCTION enum_email_types_val(email_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='new_account'::email_types AND $2='ru'::locales THEN 'Новый акаунт'
		WHEN $1='reset_pwd'::email_types AND $2='ru'::locales THEN 'Установка пароля'
		WHEN $1='user_email_conf'::email_types AND $2='ru'::locales THEN 'Подтверждение пароля'
		WHEN $1='out_mail'::email_types AND $2='ru'::locales THEN 'Исходящее письмо'
		WHEN $1='new_app'::email_types AND $2='ru'::locales THEN 'Новое заявление'
		WHEN $1='app_change'::email_types AND $2='ru'::locales THEN 'Ответы на замечания'
		WHEN $1='new_remind'::email_types AND $2='ru'::locales THEN 'Новая задача'
		WHEN $1='out_mail_to_app'::email_types AND $2='ru'::locales THEN 'Исходящее письмо по заявлению/контракту'
		WHEN $1='contract_state_change'::email_types AND $2='ru'::locales THEN 'Смена статуса контракта'
		WHEN $1='app_to_correction'::email_types AND $2='ru'::locales THEN 'Возврат заявления на корректировку'
		WHEN $1='contr_return'::email_types AND $2='ru'::locales THEN 'Возврат подписанного контракта'
		WHEN $1='expert_work_change'::email_types AND $2='ru'::locales THEN 'Изменния по локальным заключениям'
		WHEN $1='ca_update_error'::email_types AND $2='ru'::locales THEN 'Ошибка обновления головных сертификатов'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_email_types_val(email_types,locales) OWNER TO expert72;		
		
-- ******************* update 04/08/2018 06:43:26 ******************
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



-- ******************* update 04/08/2018 06:47:16 ******************
-- Function: email_ca_update_error(error_str text)

--DROP FUNCTION email_ca_update_error(error_str text);

CREATE OR REPLACE FUNCTION email_ca_update_error(error_str text)
  RETURNS RECORD  AS
$BODY$
	WITH 
		templ AS (
		SELECT t.template AS v,t.mes_subject AS s
		FROM email_templates t
		WHERE t.email_type='ca_update_error'
		)	
	SELECT
		sms_templates_text(
			ARRAY[
				ROW('error',$1)::template_value
			],
			(SELECT v FROM templ)
		)
		AS mes_body,		
		u.email::text AS email,
		(SELECT s FROM templ) AS mes_subject,
		''::text AS firm,
		u.name::text AS client
	FROM users u
	WHERE u.role_id='admin' AND u.email IS NOT NULL;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION email_ca_update_error(error_str text) OWNER TO expert72;