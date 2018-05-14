-- Function: applications_new_flow_subject()

-- DROP FUNCTION applications_new_flow_subject(json);

CREATE OR REPLACE FUNCTION applications_new_flow_subject(json)
  RETURNS text AS
$$
	SELECT
		'Новое заявление: '||
		CASE
			WHEN $1->>'expertise_type'='pd' THEN 'ПД'
			WHEN $1->>'expertise_type'='eng_survey' THEN 'РИИ'
			WHEN $1->>'expertise_type'='pd_eng_survey' THEN 'ПД, РИИ'
			ELSE ''
		END||
		CASE
			WHEN $1->>'cost_eval_validity'='true' THEN
				CASE
					WHEN $1->>'expertise_type'='pd' OR $1->>'expertise_type'='eng_survey' OR $1->>'expertise_type'='pd_eng_survey'
						THEN ', '
					ELSE ''
				END||
				CASE WHEN $1->>'cost_eval_validity_simult'='true' THEN 'достоверность одновременно с ПД'
					ELSE 'достоверность'
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
				END||'модификация'
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
				END||'аудит'
			ELSE ''
		END
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_new_flow_subject(json) OWNER TO ;
