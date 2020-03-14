
			CREATE TYPE service_types AS ENUM (
				'expertise'			
			,
				'cost_eval_validity'			
			,
				'audit'			
			,
				'modification'			
			,
				'modified_documents'			
			,
				'expert_maintenance'			
			);
			ALTER TYPE service_types OWNER TO expert72;
	/* function */
	CREATE OR REPLACE FUNCTION enum_service_types_val(service_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='expertise'::service_types AND $2='ru'::locales THEN 'Государственная экспертиза'
		WHEN $1='cost_eval_validity'::service_types AND $2='ru'::locales THEN 'Проверка достоверности сметной стоимости'
		WHEN $1='audit'::service_types AND $2='ru'::locales THEN 'Аудит цен'
		WHEN $1='modification'::service_types AND $2='ru'::locales THEN 'Модификация'
		WHEN $1='modified_documents'::service_types AND $2='ru'::locales THEN 'Модифицированная документация'
		WHEN $1='expert_maintenance'::service_types AND $2='ru'::locales THEN 'Экспертное сопровождение'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	


ALTER TABLE applications ADD COLUMN service_type service_types;
ALTER TABLE applications ADD COLUMN expert_maintenance_base_application_id int REFERENCES applications(id),ADD COLUMN expert_maintenance_contract_data jsonb;

ALTER TABLE services ADD COLUMN service_type service_types;

UPDATE services set service_type='expertise' WHERE id=1;
UPDATE services set service_type='cost_eval_validity' WHERE id=2;
UPDATE services set service_type='audit' WHERE id=4;
UPDATE services set service_type='modification' WHERE id=3;

INSERT INTO services ( id, name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type)
VALUES (
6,'Измененная документация', 'bank',40,'/ИД',20,'modified_documents'
);

INSERT INTO services (id, name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type)
VALUES (
5,'Экспертное сопровождение', 'bank',40,'/ЭС',20,'expert_maintenance'
);


update applications set service_type='cost_eval_validity' where cost_eval_validity=TRUE
update applications set service_type='expertise' where expertise_type is not null
update applications set service_type='audit' where audit
update applications set service_type='modification' where modification


--contract servic type
ALTER TABLE contracts ADD COLUMN service_type service_types;
CREATE INDEX contracts_service_type_idx
ON contracts(service_type);
update contracts set service_type = (select app.service_type from applications app where app.id=contracts.application_id)


--PRINT
ALTER TABLE applications ADD COLUMN app_print jsonb;
update applications set app_print=app_print_expertise where app_print_expertise is not null
update applications set app_print=app_print_cost_eval where app_print_cost_eval is not null AND (cost_eval_validity or expertise_type='cost_eval_validity')

CREATE OR REPLACE FUNCTION public.pdfn_services_expert_maintenance()
  RETURNS json AS
$BODY$
	SELECT services_ref(services) FROM services WHERE id=5;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_services_expert_maintenance()
  OWNER TO expert72;

CREATE OR REPLACE FUNCTION public.pdfn_services_expert_maintenance()
  RETURNS json AS
$BODY$
	SELECT services_ref(services) FROM services WHERE id=5;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION public.pdfn_services_expert_maintenance()
  OWNER TO expert72;


--

INSERT INTO views
(id,c,f,t,section,descr,limited)
VALUES (
'20018',
'Contract_Controller',
'get_expert_maintenance_list',
'ContractExpertMaintenanceList',
'Документы',
'Контракты по экспертному сопровождению',
FALSE
);
INSERT INTO views
(id,c,f,t,section,descr,limited)
VALUES (
'20019',
'Contract_Controller',
'get_modified_documents_list',
'ContractModifiedDocumentsList',
'Документы',
'Контракты по измененной документации',
FALSE
);

CREATE INDEX applicatios_base_application_idx
  ON public.applications
  USING btree
  (base_application_id);




ALTER TABLE services ADD COLUMN expertise_type expertise_types;
DROP INDEX IF EXISTS services_service_expertise_idx;
CREATE UNIQUE INDEX services_service_expertise_idx
ON services(service_type,expertise_type);
		
ALTER TABLE public.services ALTER COLUMN name TYPE character varying(250);
ALTER TABLE public.services ALTER COLUMN name SET NOT NULL;

ALTER SEQUENCE services_id_seq RESTART WITH 7;

INSERT INTO public.services(
            name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type, expertise_type)
    VALUES ('Государственная экспертиза результатов инженерных изысканий', 'bank', 30, null, 30, 
            'expertise', 'eng_survey');
INSERT INTO public.services(
            name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type, expertise_type)
    VALUES ('Государственная экспертиза проектной документации и результатов инженерных изысканий', 'bank', 30, null, 30, 
            'expertise', 'pd_eng_survey');
INSERT INTO public.services(
            name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type, expertise_type)
    VALUES ('Государственная экспертиза достоверности', 'bank', 30, null, 30, 
            'expertise', 'cost_eval_validity');
INSERT INTO public.services(
            name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type, expertise_type)
    VALUES ('Государственная экспертиза ПД и достоверности', 'bank', 30, null, 30, 
            'expertise', 'cost_eval_validity_pd');
INSERT INTO public.services(
            name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type, expertise_type)
    VALUES ('Государственная экспертиза достоверностии результатов инжененрных изысканий', 'bank', 30, null, 30, 
            'expertise', 'cost_eval_validity_eng_survey');
INSERT INTO public.services(
            name, date_type, work_day_count, contract_postf, expertise_day_count, 
            service_type, expertise_type)
    VALUES ('Государственная экспертиза ПД, достоверностии и результатов инжененрных изысканий', 'bank', 30, null, 30, 
            'expertise', 'cost_eval_validity_pd_eng_survey');

ALTER TABLE public.services ALTER COLUMN service_type SET NOT NULL;		


INSERT INTO public.doc_flow_types(
            id, name, num_prefix, doc_flow_types_type_id)
    VALUES (18, 'Экспертиза измененной документации', 'Зв-', 'out');


--***********************************
--applications_dialog.sql
--contracts_dialog.sql
--applications_list
--applications_modified_documents_list
--applications_print
--application_processes_process()
--contracts_list

--contracts_next_number
--doc_flow_out_client_process.sql

--doc_flow_examinations_dialog

--pdfn_doc_flow_types_app_expertise();
