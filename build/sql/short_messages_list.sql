-- VIEW: short_messages_list

DROP VIEW short_messages_list;

CREATE OR REPLACE VIEW short_messages_list AS
	SELECT
		m.id,
		doc_flow_importance_types_ref(tp) AS doc_flow_importance_types_ref,
		employees_ref(e) AS recipients_ref,
		e.id AS recipient_id,
		employees_ref(to_e) AS to_recipients_ref,
		to_e.id AS to_recipient_id, 
		rem.date_time,
		(rem.viewed_dt IS NOT NULL) AS viewed,
		rem.viewed_dt AS view_date_time,
		rem.content,
		rem.files
	FROM short_messages AS m
	LEFT JOIN reminders AS rem ON rem.register_docs_ref->>'dataType'='short_messages' AND (rem.register_docs_ref->'keys'->>'id')::int=m.id
	LEFT JOIN doc_flow_importance_types AS tp ON tp.id=rem.doc_flow_importance_type_id
	LEFT JOIN employees AS e ON e.id=m.recipient_id
	LEFT JOIN employees AS to_e ON to_e.id=m.to_recipient_id
	ORDER BY m.date_time
	;
	
ALTER VIEW short_messages_list OWNER TO ;
