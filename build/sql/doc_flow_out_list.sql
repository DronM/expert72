-- VIEW: doc_flow_out_list

--DROP VIEW doc_flow_out_list;

CREATE OR REPLACE VIEW doc_flow_out_list AS
	SELECT
		doc_flow_out.id,
		doc_flow_out.date_time,
		doc_flow_out.reg_number,
		doc_flow_out.to_addr_names,
		doc_flow_out.subject,
		applications_ref(applications) AS to_applications_ref,
		doc_flow_out.to_application_id AS to_application_id,
		doc_flow_types_ref(doc_flow_types) AS doc_flow_types_ref,
		employees_ref(employees) AS employees_ref,
		person_init(employees.name::text,FALSE) AS employee_short_name,

		st.state AS state,
		st.date_time AS state_dt,
		st.end_date_time AS state_end_dt,
		st.register_doc AS state_register_doc,
		
		(applications.applicant->>'name')::text||' '||(applications.applicant->>'inn')::text AS applicant_descr,
		
		applications.constr_name AS to_constr_name,
		
		doc_flow_out.content
		
	FROM doc_flow_out
	LEFT JOIN applications ON applications.id=doc_flow_out.to_application_id
	LEFT JOIN doc_flow_types ON doc_flow_types.id=doc_flow_out.doc_flow_type_id
	LEFT JOIN employees ON employees.id=doc_flow_out.employee_id
	LEFT JOIN (
		SELECT
			t.doc_flow_out_id AS doc_id,
			max(t.date_time) AS date_time
		FROM doc_flow_out_processes t
		GROUP BY t.doc_flow_out_id
	) AS h_max ON h_max.doc_id=doc_flow_out.id
	LEFT JOIN doc_flow_out_processes st
		ON st.doc_flow_out_id=h_max.doc_id AND st.date_time = h_max.date_time
	WHERE coalesce(doc_flow_out.ext_contract,FALSE)=FALSE
	ORDER BY doc_flow_out.date_time DESC
	;
	
ALTER VIEW doc_flow_out_list OWNER TO ;
