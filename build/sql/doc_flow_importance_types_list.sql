-- VIEW: doc_flow_importance_types_list

--DROP VIEW doc_flow_importance_types_list;

CREATE OR REPLACE VIEW doc_flow_importance_types_list AS
	SELECT
		id ,
		name,
		approve_interval
	FROM doc_flow_importance_types
	ORDER BY name
	;
	
ALTER VIEW doc_flow_importance_types_list OWNER TO ;
