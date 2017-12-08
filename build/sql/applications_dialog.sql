-- VIEW: applications_dialog

--DROP VIEW applications_dialog;

CREATE OR REPLACE VIEW applications_dialog AS
	SELECT
		d.id,
		d.create_dt,
		d.expertise_type,
		d.estim_cost_type,
		d.fund_source,
		d.applicant,
		d.customer,
		d.contractors,
		d.constr_name,
		d.constr_address,
		d.constr_technical_features,
		d.constr_construction_type,
		d.constr_total_est_cost,
		d.constr_land_area,
		d.constr_total_area,		
		d.office_id,
		
		st.state AS application_state,
		st.date_time AS application_state_dt,
		CASE
			WHEN st.state='sent' THEN
				bank_day_next(st.date_time::date,(SELECT const_application_check_days_val()))
			ELSE NULL
		END AS application_state_end_date,
		
		(SELECT doc_tmpl.content
		FROM application_pd_templates AS doc_tmpl
		WHERE doc_tmpl.date_time <= d.create_dt
		ORDER BY doc_tmpl.date_time DESC
		LIMIT 1 
		) AS documents_pd,
		(SELECT doc_tmpl.content
		FROM application_dost_templates AS doc_tmpl
		WHERE doc_tmpl.date_time <= d.create_dt
		ORDER BY doc_tmpl.date_time DESC
		LIMIT 1 
		) AS documents_dost
		
		
	FROM applications AS d
	LEFT JOIN offices ON offices.id=d.office_id
	LEFT JOIN (
		SELECT
			t.application_id,
			max(t.date_time) AS date_time
		FROM application_state_history t
		GROUP BY t.application_id
	) AS h_max ON h_max.application_id=d.id
	LEFT JOIN application_state_history st
		ON st.application_id=h_max.application_id AND st.date_time = h_max.date_time
	
	;
	
ALTER VIEW applications_dialog OWNER TO ;

