-- VIEW: doc_flow_importance_types_dialog

--DROP VIEW doc_flow_importance_types_dialog;

CREATE OR REPLACE VIEW doc_flow_importance_types_dialog AS
	SELECT
		*
	FROM doc_flow_importance_types
	;
	
ALTER VIEW doc_flow_importance_types_dialog OWNER TO ;
