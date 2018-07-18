-- Function: expert_works_change_mail(expert_works)

-- DROP FUNCTION expert_works_change_mail(expert_works);

CREATE OR REPLACE FUNCTION expert_works_change_mail(expert_works)
  RETURNS void AS
$$
		--Письмо отделу по поводу изменений
		INSERT INTO mail_for_sending
		(to_addr,to_name,body,subject,email_type)
		(WITH 
			templ AS (
				SELECT
					t.template AS v,
					t.mes_subject AS s
				FROM email_templates t
				WHERE t.email_type= 'expert_work_change'::email_types
			)
		SELECT
			departments.email::text,
			departments.name::text,
			sms_templates_text(
				ARRAY[
					ROW('contract_number', contr.expertise_result_number)::template_value,
					ROW('constr_name',contr.constr_name)::template_value,
					ROW('section_name',sec.section_name)::template_value,
					ROW('expert_name',emp.name)::template_value
				],
				(SELECT v FROM templ)
			) AS mes_body,		
			(SELECT s FROM templ),
			'expert_work_change'::email_types
		FROM contracts AS contr
		LEFT JOIN departments ON departments.id=contr.main_department_id
		LEFT JOIN applications AS app ON app.id=contr.application_id
		LEFT JOIN employees AS emp ON emp.id=$1.expert_id
		LEFT JOIN expert_sections AS sec ON
			sec.document_type=contr.document_type
			AND sec.construction_type_id=app.construction_type_id
			AND sec.section_id=$1.section_id
			AND sec.create_date=(
				SELECT max(sec2.create_date)
				FROM expert_sections AS sec2
				WHERE
					sec2.document_type=contr.document_type
					AND sec2.construction_type_id=app.construction_type_id
					AND sec2.create_date<=contr.date_time
			)
			
		WHERE
			contr.id=$1.contract_id
			AND departments.email IS NOT NULL
		);				

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION expert_works_change_mail(expert_works) OWNER TO ;
