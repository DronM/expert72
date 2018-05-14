-- Function: applications_new_flow_content()

-- DROP FUNCTION applications_new_flow_content(json);

CREATE OR REPLACE FUNCTION applications_new_flow_content(json)
  RETURNS text AS
$$
	SELECT
		'Просим провести: '||
		CASE
			WHEN $1->>'expertise_type'='pd' THEN 'экспертизу проектной документации'
			WHEN $1->>'expertise_type'='eng_survey' THEN 'экспертизу результатов инженерных изысканий'
			WHEN $1->>'expertise_type'='pd_eng_survey' THEN 'экспертизу проектной документации, экспертизу результатов инженерных изысканий'
			ELSE ''
		END||
		CASE
			WHEN $1->>'cost_eval_validity'='true' THEN
				CASE
					WHEN $1->>'expertise_type'='pd' OR $1->>'expertise_type'='eng_survey' OR $1->>'expertise_type'='pd_eng_survey'
						THEN ', '
					ELSE ''
				END||
				CASE WHEN $1->>'cost_eval_validity_simult'='true' THEN 'одновременно с государственной экспертизой проверку достоверности определения сметной стоимости'
					ELSE 'проверку достоверности определения сметной стоимости'
				END
			ELSE ''
		END||
		CASE
			WHEN $1->>'modification'='true' THEN
				CASE
					WHEN $1->>'expertise_type'='pd' OR $1->>'expertise_type'='eng_survey'
					OR $1->>'expertise_type'='pd_eng_survey'
					OR $1->>'cost_eval_validity'='true'
						THEN ', '
					ELSE ''
				END||'модификацию'
			ELSE ''
		END||
		CASE
			WHEN $1->>'audit'='true' THEN
				CASE
					WHEN $1->>'expertise_type'='pd' OR $1->>'expertise_type'='eng_survey'
					OR $1->>'expertise_type'='pd_eng_survey'
					OR $1->>'cost_eval_validity'='true'
					OR $1->>'modification'='true'
						THEN ', '
					ELSE ''
				END||'аудит цен'
			ELSE ''
		END
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_new_flow_content(json) OWNER TO ;
