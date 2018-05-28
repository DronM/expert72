CREATE USER expert72 WITH PASSWORD '159753';
CREATE DATABASE expert72;
GRANT ALL PRIVILEGES ON DATABASE expert72 TO expert72;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO expert72;

ПРОСТОЙ DUMP!!!
sudo service postgresql stop
sudo service postgresql start
psql -U postgres
DROP database expert72;
CREATE DATABASE expert72;
GRANT ALL ON SCHEMA public TO expert72;
GRANT ALL ON DATABASE expert72 TO expert72;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO expert72;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO expert72;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO expert72;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO expert72;

psql -U expert72 -d expert72 -f expert.dmp
159753



ИСПРАВИТЬ КПП "7203321348 КПП 7"
psql -d expert72 -U expert72 -f /home/andrey/\!Экспертиза/ЛК/cl.sql

DELETE FROM contacts;
delete from contracts;
delete from applications;
delete from clients where id<>4;

DELETE FROM doc_flow_approvements;
DELETE FROM doc_flow_examinations;
DELETE FROM doc_flow_in;
DELETE FROM doc_flow_out;
DELETE FROM doc_flow_in_client;
DELETE FROM doc_flow_out_client;

DELETE FROM doc_flow_registrations;
DELETE FROM doc_flow_tasks;
DELETE FROM mail_for_sending;
DELETE FROM morpher;
DELETE FROM reminders;
--DELETE FROM report_template_files;
--DELETE FROM report_templates;
DELETE FROM sessions;
DELETE FROM user_email_confirmations;

--ЗАМЕНА
'{\'id\':\'LinkedContractList_Model\',\'rows\':[]}'
'{"id":"LinkedContractList_Model","rows":[]}'

--ПЕРЕЗАПУСТИТЬ ПЕРЕЗ ЗАГРУЗКОЙ
SELECT setval('contracts_id_seq', 1);
SELECT setval('applications_id_seq', 1);
SELECT setval('client_payments_id_seq', 1);
-- Trigger: contacts_before_trigger on public.contacts

--*** УБРАТЬ ТРИГГЕР ПЕРЕД ЗАПУСКОМ ЗАГРУЗКИ *****
DROP TRIGGER contacts_before_trigger ON public.contacts;
CREATE TRIGGER contacts_before_trigger
  BEFORE INSERT
  ON public.contacts
  FOR EACH ROW
  EXECUTE PROCEDURE public.contacts_process();








INSERT INTO client_payments
(contract_id,pay_date,total)
(select id,date_time,payment2 from contracts where payment2>0)
INSERT INTO client_payments
(contract_id,pay_date,total)
(select id,date_time+'1 day',payment from contracts where payment>0)


COPY tmp_logins FROM '/home/andrey/logins.csv' (FORMAT csv, DELIMITER '@')



INSERT INTO public.users(
            name,
            role_id,
            tmp_pwd,
            pwd,
            time_zone_locale_id,
            email, 
            locale_id,
            pers_data_proc_agreement,
            create_dt,
            email_confirmed, 
            comment_text,
            banned,
            name_full, reminders_to_email,
            tmp_inn)
(
SELECT DISTINCT ON (t.login,t.email)
t.login AS name,
'client' AS role_id,
random_string(6) AS tmp_pwd,
'111' AS pwd,
1 AS time_zone_locale_id,
t.email AS email,
'ru' AS locale_id,
TRUE AS pers_data_proc_agreement,
now()::date AS create_dt,
TRUE AS email_confirmed,
'Перенесено из старого ЛК' AS comment_text,
FALSE AS banned,
t.ruk_fio AS name_full,
TRUE AS reminders_to_email,
t.inn AS tmp_inn
FROM tmp_logins AS t

    )





update contracts
set user_id=sub.user_id
FROM (
select contracts.id AS contract_id,contracts.application_id,users.id AS user_id
from contracts
left join clients ON clients.id=contracts.client_id
left join users ON users.tmp_inn=clients.inn
where users.tmp_inn IS NOT NULL AND users.id IN (
	SELECT u1.id
	FROM users AS u1
	LEFT JOIN users AS u2 ON u1.tmp_inn=u2.tmp_inn AND u1.id<>u2.id
	WHERE u2.name IS NULL
)
) AS sub
WHERE id=sub.contract_id


update applications
set user_id=sub.user_id
FROM (
select contracts.id AS contract_id,contracts.application_id,users.id AS user_id
from contracts
left join clients ON clients.id=contracts.client_id
left join users ON users.tmp_inn=clients.inn
where users.tmp_inn IS NOT NULL AND users.id IN (
	SELECT u1.id
	FROM users AS u1
	LEFT JOIN users AS u2 ON u1.tmp_inn=u2.tmp_inn AND u1.id<>u2.id
	WHERE u2.name IS NULL
)
) AS sub
WHERE id=sub.application_id


--*** ДЛЯ ВСЕХ ЗАПОЛНИТЬ  linked_contracts *****
--"{"id":"LinkedContractList_Model","rows":[{"fields":{"id":1,"contracts_ref":{"keys":{"id":2},"descr":"Контракт №0001/15 от 12/01/15"}}}]}"
UPDATE contracts
SET linked_contracts=sel.linked_contracts
FROM
(SELECT
	contr1.id,
	json_build_object(
	'id',
	'LinkedContractList_Model',
	'rows',
	array_agg(
		json_build_object(
			'fields',
			json_build_object(
				'id',
				contr1.rank,
				'contracts_ref',
				contracts_ref(contr2)
			)
		)
	)
	) AS linked_contracts
	/*,
	contr1.expertise_result_number,
	contr1.document_type
	*/
FROM (
	SELECT
		*,
		rank() over (PARTITION BY id ORDER BY expertise_result_number) AS rank
	FROM (
	select
		id,	
		jsonb_array_elements(linked_contracts2)->>'number' AS expertise_result_number,
		(jsonb_array_elements(linked_contracts2)->>'document_type')::document_types AS document_type
	from contracts
	where linked_contracts2 is not null-- limit 10
	) AS sub

) AS contr1
LEFT JOIN contracts AS contr2 ON contr2.expertise_result_number=contr1.expertise_result_number AND contr2.document_type=contr1.document_type
GROUP BY contr1.id
) AS sel
WHERE sel.id=contracts.id 


--*** ВРОДЕ НЕ НАДО *****
/*
update contracts
set linked_contracts='{"id":"LinkedContractList_Model","rows":[]}'
where linked_contracts is null
*/


--*** ДЛЯ ВСЕХ Добавить слэш!!! *****
update contracts
set contract_number=cor.corrected_contract_number
FROM(
select contract_number AS old_number,
regexp_replace(contract_number,'\D+.*$','')||'/Д' AS corrected_contract_number
FROM contracts
where document_type='cost_eval_validity' AND substring(contract_number from length(contract_number)-1 FOR length(contract_number))<>'/Д'
AND length(contract_number)<5
ORDER BY date_time desc
) AS cor
WHERE cor.old_number=contract_number;


--***************************************************
update contracts
set
	constr_name=app.constr_name,
	constr_address=app.constr_address,
	constr_technical_features=app.constr_technical_features

FROM (
SELECT
	applications.id,
	applications.constr_name,
	applications.constr_address,
	applications.constr_technical_features					
	
FROM applications
) As app
WHERE app.id=contracts.application_id
