-- VIEW: doc_flow_tasks_short_list

--DROP VIEW doc_flow_tasks_short_list;

CREATE OR REPLACE VIEW doc_flow_tasks_short_list AS
	SELECT
		t.id,
		
		t.recipient As recipient,
		
		t.register_doc AS register_docs_ref,
		
		format_interval_rus(date_trunc('minute',now()) - date_trunc('minute',t.date_time)) AS passed_time,
		t.description,
		t.closed,
		t.date_time,
		
		CASE WHEN t.closed THEN t.close_doc ELSE t.register_doc END AS docs_ref
		
	FROM doc_flow_tasks t
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW doc_flow_tasks_short_list OWNER TO ;
