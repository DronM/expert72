-- ******************* update 22/05/2018 10:45:35 ******************

					ALTER TYPE role_types ADD VALUE 'accountant';
	/* function */
	CREATE OR REPLACE FUNCTION enum_role_types_val(role_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='admin'::role_types AND $2='ru'::locales THEN 'Администратор'
		WHEN $1='client'::role_types AND $2='ru'::locales THEN 'Клиент'
		WHEN $1='lawyer'::role_types AND $2='ru'::locales THEN 'Юрист отдела приема'
		WHEN $1='expert'::role_types AND $2='ru'::locales THEN 'Эксперт'
		WHEN $1='boss'::role_types AND $2='ru'::locales THEN 'Руководитель'
		WHEN $1='accountant'::role_types AND $2='ru'::locales THEN 'Бухгалтер'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_role_types_val(role_types,locales) OWNER TO expert72;		
		
-- ******************* update 22/05/2018 10:49:04 ******************

		ALTER TABLE client_payments_list ADD COLUMN pay_docum_date date,ADD COLUMN pay_docum_number  varchar(20);


-- ******************* update 22/05/2018 10:49:13 ******************

		ALTER TABLE client_payments ADD COLUMN pay_docum_date date,ADD COLUMN pay_docum_number  varchar(20);


-- ******************* update 22/05/2018 10:50:00 ******************
-- VIEW: client_payments_list

--DROP VIEW client_payments_list;

CREATE OR REPLACE VIEW client_payments_list AS
	SELECT
		pm.id,
		clients_ref(cl) AS clients_ref,
		contracts_ref(contr) AS contracts_ref,
		pm.pay_date,
		pm.total,
		contr.client_id,
		pm.contract_id,
		pm.pay_docum_date,
		pm.pay_docum_number
		
	FROM client_payments AS pm	
	LEFT JOIN contracts AS contr ON contr.id=pm.contract_id
	LEFT JOIN clients AS cl ON cl.id=contr.client_id
	ORDER BY pm.pay_date DESC
	;
	
ALTER VIEW client_payments_list OWNER TO expert72;