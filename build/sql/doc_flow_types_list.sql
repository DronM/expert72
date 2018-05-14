-- VIEW: doc_flow_types_list

--DROP VIEW doc_flow_types_list;

CREATE OR REPLACE VIEW doc_flow_types_list AS
	SELECT
		doc_flow_types.id,
		doc_flow_types.name,
		doc_flow_types.def_interval,
		doc_flow_types.doc_flow_types_type_id,
		doc_flow_types.num_prefix
	FROM doc_flow_types
	ORDER BY doc_flow_types.doc_flow_types_type_id
	;
	
ALTER VIEW doc_flow_types_list OWNER TO ;
