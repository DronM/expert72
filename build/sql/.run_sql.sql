-- VIEW: doc_flow_in_client_dialog

--DROP VIEW doc_flow_in_client_dialog;

CREATE OR REPLACE VIEW doc_flow_in_client_dialog AS
	SELECT
		t.id,
		t.date_time,
		t.reg_number,
		t.subject,
		t.user_id,
		t.viewed,
		applications_ref(applications) AS applications_ref,
		t.comment_text,
		t.content,
		json_build_array(
			json_build_object(
				'files',t.files
			)
		) AS files,
		regs.reg_number AS reg_number_out
		
	FROM doc_flow_in_client t
	LEFT JOIN applications ON applications.id=t.application_id
	LEFT JOIN doc_flow_in_client_reg_numbers AS regs ON regs.doc_flow_in_client_id=t.id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_in_client_dialog OWNER TO expert72;
