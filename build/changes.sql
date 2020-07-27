UPDATE applications
SET
expert_maintenance_service_type = (SELECT app.service_type FROM applications AS app WHERE app.id=applications.expert_maintenance_base_application_id),
expert_maintenance_expertise_type = (SELECT app.expertise_type FROM applications AS app WHERE app.id=applications.expert_maintenance_base_application_id)
where expert_maintenance_base_application_id IS NOT NULL



ALTER TABLE document_templates ADD COLUMN service_type service_types,ADD COLUMN expertise_type expertise_types;

VIEW: document_templates_list

ALTER TABLE applications ADD COLUMN documents jsonb;

contracts_dialog
applications_dialog

update applications
SET documents = applications_get_documents(applications)
where documents is NULL AND service_type<>'expert_maintenance' 

applications_process

contracts_next_number

f_regexpescape

doc_flow_in_dialog.sql
