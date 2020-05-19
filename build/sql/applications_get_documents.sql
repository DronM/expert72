-- Function: applications_get_documents(in_application applications)

 DROP FUNCTION applications_get_documents(in_application applications);

CREATE OR REPLACE FUNCTION applications_get_documents(in_application applications)
  RETURNS JSONB AS
$$
	
	SELECT
		CASE WHEN in_application.service_type='modified_documents' THEN
			(SELECT
				document_templates_on_filter(
					in_application.create_dt::date,
					b_app.construction_type_id,
					b_app.expert_maintenance_service_type,
					b_app.expert_maintenance_expertise_type
				)				
			FROM applications AS b_app
			WHERE b_app.id = in_application.base_application_id
			)
		ELSE
			(SELECT document_templates_on_filter(
				in_application.create_dt::date,
				in_application.construction_type_id,
				in_application.service_type,
				in_application.expertise_type
				/*
				CASE
					WHEN in_application.expertise_type IS NULL AND in_application.service_type='cost_eval_validity' THEN 'cost_eval_validity'
					ELSE in_application.expertise_type
				END	
				*/
			))			
		END	
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION applications_get_documents(in_application applications) OWNER TO ;
