-- VIEW: doc_flow_out_client_list

DROP VIEW doc_flow_out_client_list;

CREATE OR REPLACE VIEW doc_flow_out_client_list AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		applications_ref(applications) AS applications_ref,
		t.application_id,
		t.sent,
		cl_in_regs.reg_number AS reg_number_in
		
	FROM doc_flow_out_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_out_client_reg_numbers AS cl_in_regs ON cl_in_regs.application_id=t.application_id AND cl_in_regs.doc_flow_out_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_list OWNER TO ;
