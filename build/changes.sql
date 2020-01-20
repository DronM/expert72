
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity';
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity_pd';
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity_eng_survey';
					ALTER TYPE expertise_types ADD VALUE 'cost_eval_validity_pd_eng_survey';
	/* function */
	CREATE OR REPLACE FUNCTION enum_expertise_types_val(expertise_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='pd'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации'
		WHEN $1='eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза результатов инженерных изысканий'
		WHEN $1='pd_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации и Государственная экспертиза результатов инженерных изысканий'
		WHEN $1='cost_eval_validity'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза достоверности сметной стоимости'
		WHEN $1='cost_eval_validity_pd'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации и Государственная экспертиза достоверности сметной стоимости'
		WHEN $1='cost_eval_validity_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза результатов инженерных изысканий и Государственная экспертиза достоверности сметной стоимости'
		WHEN $1='cost_eval_validity_pd_eng_survey'::expertise_types AND $2='ru'::locales THEN 'Государственная экспертиза проектной документации, Государственная экспертиза результатов инженерных изысканий, Государственная экспертиза достоверности сметной стоимости'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_expertise_types_val(expertise_types,locales) OWNER TO expert72;		
		
		
		
--applications_list
--application_processes_process()
--applications_dialog		
